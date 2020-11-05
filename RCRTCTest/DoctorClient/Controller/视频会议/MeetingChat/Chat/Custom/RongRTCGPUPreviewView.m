//
//  RongRTCVideoPreviewView.h
//  RongRTCVideoPreviewView
//
//  Created by jfdreamyang on 2019/1/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RongRTCGPUPreviewView.h"
#import <AVFoundation/AVUtilities.h>
#import <mach/mach_time.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

NSString *const kRongGPUImageGeneralVertexShaderString = SHADER_STRING
(
 attribute vec4 position;//（x,y,z,1）
 attribute vec2 texCoord;
 uniform float preferredRotation;
 varying vec2 texCoordVarying;
 
 void main()
{
    mat4 rotationMatrix = mat4(cos(preferredRotation), -sin(preferredRotation), 0.0, 0.0,
                               sin(preferredRotation),  cos(preferredRotation), 0.0, 0.0,
                               0.0,                        0.0, 1.0, 0.0,
                               0.0,                        0.0, 0.0, 1.0);
    gl_Position = position * rotationMatrix;
    texCoordVarying = texCoord;
}
);

NSString *const kRongGPUImageYUVFrameShaderString = SHADER_STRING
(
 varying highp vec2 texCoordVarying;
 precision mediump float;
 
 uniform float lumaThreshold;
 uniform float chromaThreshold;
 uniform sampler2D SamplerY;
 uniform sampler2D SamplerUV;
 uniform mat3 colorConversionMatrix;
 
 void main()
{
    mediump vec3 yuv;
    lowp vec3 rgb;
    yuv.x = (texture2D(SamplerY, texCoordVarying).r - (16.0/255.0))* lumaThreshold;
    yuv.yz = (texture2D(SamplerUV, texCoordVarying).rg - vec2(0.5, 0.5))* chromaThreshold;
    rgb = colorConversionMatrix * yuv;
    gl_FragColor = vec4(rgb,1);
}
);

NSString *const kRongGPUImageGeneralFragmentShaderString = SHADER_STRING
(
 varying highp vec2 texCoordVarying;
 uniform sampler2D SamplerRGB;
 void main()
 {
     gl_FragColor = texture2D(SamplerRGB, texCoordVarying);
 }
 );


enum
{
	UNIFORM_Y,
	UNIFORM_UV,
	UNIFORM_LUMA_THRESHOLD,
	UNIFORM_CHROMA_THRESHOLD,
	UNIFORM_ROTATION_ANGLE,
	UNIFORM_COLOR_CONVERSION_MATRIX,
	NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
	ATTRIB_VERTEX,
	ATTRIB_TEXCOORD,
	NUM_ATTRIBUTES
};

// Color Conversion Constants (YUV to RGB) including adjustment from 16-235/16-240 (video range)

// BT.601, which is the standard for SDTV.
static const GLfloat kColorConversion601[] = {
		1.164,  1.164, 1.164,
		  0.0, -0.392, 2.017,
		1.596, -0.813,   0.0,
};

// BT.709, which is the standard for HDTV.
static const GLfloat kColorConversion709[] = {
		1.164,  1.164, 1.164,
		  0.0, -0.213, 2.112,
		1.793, -0.533,   0.0,
};

@interface RongRTCGPUPreviewView ()
{
	GLint _backingWidth;
	GLint _backingHeight;

	EAGLContext *_glContext;
    
    // yuv 格式所用纹理
	CVOpenGLESTextureRef _lumaTexture;
	CVOpenGLESTextureRef _chromaTexture;
    
    
    GLuint _texture;
    
    // rgb 格式所用纹理
    CVOpenGLESTextureRef _rgvTexture;
    
	CVOpenGLESTextureCacheRef _videoTextureCache;
	
	GLuint _frameBufferHandle;
	GLuint _colorBufferHandle;
	
	const GLfloat *_preferredConversion;
}

@property GLuint program;

- (void)setupBuffers;
- (void)cleanUpTextures;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type sourceString:(NSString *)sourceString;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end

@implementation RongRTCGPUPreviewView

+ (Class)layerClass
{
	return [CAEAGLLayer class];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO], kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
        _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!_glContext || ![EAGLContext setCurrentContext:_glContext] || ![self loadShaders]) {
            return nil;
        }
        _luminance = 1.0;
        _chroma = 1.0;
        _preferredConversion = kColorConversion709;
        [self launchGL];
    }
    return self;
}
- (void)launchGL
{
	[EAGLContext setCurrentContext:_glContext];
	[self setupBuffers];
	[self loadShaders];
	glUseProgram(self.program);
	
	glUniform1i(uniforms[UNIFORM_Y], 0);
	glUniform1i(uniforms[UNIFORM_UV], 1);
	glUniform1f(uniforms[UNIFORM_LUMA_THRESHOLD], self.luminance);
	glUniform1f(uniforms[UNIFORM_CHROMA_THRESHOLD], self.chroma);
	glUniform1f(uniforms[UNIFORM_ROTATION_ANGLE], self.preferredRotation);
	glUniformMatrix3fv(uniforms[UNIFORM_COLOR_CONVERSION_MATRIX], 1, GL_FALSE, _preferredConversion);
	
	if (!_videoTextureCache) {
		CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _glContext, NULL, &_videoTextureCache);
		if (err != noErr) {
			NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
			return;
		}
	}
    self.presentationRect = self.bounds.size;
}

#pragma mark - Utilities

- (void)setupBuffers
{
	glDisable(GL_DEPTH_TEST);
	
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), 0);
	
	glEnableVertexAttribArray(ATTRIB_TEXCOORD);
	glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), 0);
	
	glGenFramebuffers(1, &_frameBufferHandle);
	glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
	
	glGenRenderbuffers(1, &_colorBufferHandle);
	glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
	
	[_glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);

	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBufferHandle);
	if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
		NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
	}
}

- (void)cleanUpTextures
{
	if (_lumaTexture) {
		CFRelease(_lumaTexture);
		_lumaTexture = NULL;
	}
	if (_chromaTexture) {
		CFRelease(_chromaTexture);
		_chromaTexture = NULL;
	}
	CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}

- (void)dealloc
{
	[self cleanUpTextures];
	if(_videoTextureCache) {
		CFRelease(_videoTextureCache);
	}
}


-(void)displayRGB:(CVPixelBufferRef)pixelBuffer{
    int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    
    if (!_texture) {
        glActiveTexture(GL_TEXTURE1);
        glGenTextures(1, &_texture);
        glBindTexture(GL_TEXTURE_2D, _texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }
    
    glBindTexture(GL_TEXTURE_2D,_texture);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    int bytesPerRow = (int) CVPixelBufferGetBytesPerRow(pixelBuffer);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, bytesPerRow/4, frameHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, CVPixelBufferGetBaseAddress(pixelBuffer));
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    [self _display];
}

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer{
    NSAssert(pixelBuffer != NULL, @"pixelBuffer 为空了，请仔细检查代码");
    if (self.isRGB) {
        [self displayRGB:pixelBuffer];
    }
    else{
        [self displayYUV:pixelBuffer];
    }
}
#pragma mark - OpenGLES drawing

- (void)displayYUV:(CVPixelBufferRef)pixelBuffer
{
	CVReturn err;
    int frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
   
    [self cleanUpTextures];
    
    CVPixelBufferLockBaseAddress(pixelBuffer,0);
    
    CFTypeRef colorAttachments = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
    
    if (colorAttachments == kCVImageBufferYCbCrMatrix_ITU_R_601_4) {
        _preferredConversion = kColorConversion601;
    }
    else {
        _preferredConversion = kColorConversion709;
    }
    
    glActiveTexture(GL_TEXTURE0);
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _videoTextureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RED_EXT,
                                                       frameWidth,
                                                       frameHeight,
                                                       GL_RED_EXT,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &_lumaTexture);
    if (err) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
    glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // UV-plane.
    glActiveTexture(GL_TEXTURE1);
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _videoTextureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RG_EXT,
                                                       frameWidth / 2,
                                                       frameHeight / 2,
                                                       GL_RG_EXT,
                                                       GL_UNSIGNED_BYTE,
                                                       1,
                                                       &_chromaTexture);
    if (err) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
    glBindTexture(CVOpenGLESTextureGetTarget(_chromaTexture), CVOpenGLESTextureGetName(_chromaTexture));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    [self _display];
}

-(void)_display{
    glViewport(0, 0, _backingWidth, _backingHeight);
    
    glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(self.program);
    glUniform1f(uniforms[UNIFORM_LUMA_THRESHOLD], self.luminance);
    glUniform1f(uniforms[UNIFORM_CHROMA_THRESHOLD], self.chroma);
    glUniform1f(uniforms[UNIFORM_ROTATION_ANGLE], self.preferredRotation);
    glUniformMatrix3fv(uniforms[UNIFORM_COLOR_CONVERSION_MATRIX], 1, GL_FALSE, _preferredConversion);
    
    CGRect vertexSamplingRect = AVMakeRectWithAspectRatioInsideRect(self.presentationRect, self.layer.bounds);
    
    CGSize normalizedSamplingSize = CGSizeMake(0.0, 0.0);
    CGSize cropScaleAmount = CGSizeMake(vertexSamplingRect.size.width/self.layer.bounds.size.width, vertexSamplingRect.size.height/self.layer.bounds.size.height);
    
    if (cropScaleAmount.width > cropScaleAmount.height) {
        normalizedSamplingSize.width = 1.0;
        normalizedSamplingSize.height = cropScaleAmount.height/cropScaleAmount.width;
    }
    else {
        normalizedSamplingSize.width = 1.0;
        normalizedSamplingSize.height = cropScaleAmount.width/cropScaleAmount.height;
    }
    GLfloat quadVertexData [] = {
        -1 * normalizedSamplingSize.width, -1 * normalizedSamplingSize.height,
        normalizedSamplingSize.width, -1 * normalizedSamplingSize.height,
        -1 * normalizedSamplingSize.width, normalizedSamplingSize.height,
        normalizedSamplingSize.width, normalizedSamplingSize.height,
    };
    
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, quadVertexData);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    
    CGRect textureSamplingRect = CGRectMake(0, 0, 1, 1);
    GLfloat quadTextureData[] =  {
        CGRectGetMinX(textureSamplingRect), CGRectGetMaxY(textureSamplingRect),
        CGRectGetMaxX(textureSamplingRect), CGRectGetMaxY(textureSamplingRect),
        CGRectGetMinX(textureSamplingRect), CGRectGetMinY(textureSamplingRect),
        CGRectGetMaxX(textureSamplingRect), CGRectGetMinY(textureSamplingRect)
    };
    
    glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, 0, 0, quadTextureData);
    glEnableVertexAttribArray(ATTRIB_TEXCOORD);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
    [_glContext presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
	GLuint vertShader, fragShader;
	
	self.program = glCreateProgram();
	
    
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER sourceString:kRongGPUImageGeneralVertexShaderString]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER sourceString:kRongGPUImageYUVFrameShaderString]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
	
	glAttachShader(self.program, vertShader);
	glAttachShader(self.program, fragShader);
	glBindAttribLocation(self.program, ATTRIB_VERTEX, "position");
	glBindAttribLocation(self.program, ATTRIB_TEXCOORD, "texCoord");
	
	if (![self linkProgram:self.program]) {
		NSLog(@"链接失败: %d", self.program);
		
		if (vertShader) {
			glDeleteShader(vertShader);
			vertShader = 0;
		}
		if (fragShader) {
			glDeleteShader(fragShader);
			fragShader = 0;
		}
		if (self.program) {
			glDeleteProgram(self.program);
			self.program = 0;
		}
		
		return NO;
	}
	
	uniforms[UNIFORM_Y] = glGetUniformLocation(self.program, "SamplerY");
	uniforms[UNIFORM_UV] = glGetUniformLocation(self.program, "SamplerUV");
	uniforms[UNIFORM_LUMA_THRESHOLD] = glGetUniformLocation(self.program, "lumaThreshold");
	uniforms[UNIFORM_CHROMA_THRESHOLD] = glGetUniformLocation(self.program, "chromaThreshold");
	uniforms[UNIFORM_ROTATION_ANGLE] = glGetUniformLocation(self.program, "preferredRotation");
	uniforms[UNIFORM_COLOR_CONVERSION_MATRIX] = glGetUniformLocation(self.program, "colorConversionMatrix");
	
	if (vertShader) {
		glDetachShader(self.program, vertShader);
		glDeleteShader(vertShader);
	}
	if (fragShader) {
		glDetachShader(self.program, fragShader);
		glDeleteShader(fragShader);
	}
	
	return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type sourceString:(NSString *)sourceString
{
	GLint status;
	const GLchar *source;
	source = (GLchar *)[sourceString UTF8String];
	
	*shader = glCreateShader(type);
	glShaderSource(*shader, 1, &source, NULL);
	glCompileShader(*shader);
	
#if defined(DEBUG)
	GLint logLength;
	glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetShaderInfoLog(*shader, logLength, &logLength, log);
		NSLog(@"Shader compile log:\n%s", log);
		free(log);
	}
#endif
	glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
	if (status == 0) {
		glDeleteShader(*shader);
		return NO;
	}
	
	return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
	GLint status;
	glLinkProgram(prog);
	
#if defined(DEBUG)
	GLint logLength;
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(prog, logLength, &logLength, log);
		NSLog(@"Program link log:\n%s", log);
		free(log);
	}
#endif
	
	glGetProgramiv(prog, GL_LINK_STATUS, &status);
	if (status == 0) {
		return NO;
	}
	
	return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
	GLint logLength, status;
	
	glValidateProgram(prog);
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(prog, logLength, &logLength, log);
		NSLog(@"Program validate log:\n%s", log);
		free(log);
	}
	
	glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
	if (status == 0) {
		return NO;
	}
	
	return YES;
}

@end


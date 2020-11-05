//
//  STAudioMixingPannelController.m
//  SealRTC
//
//  Created by birney on 2020/3/8.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <RongRTCLib/RongRTCLib.h>
#import "STAudioMixingPannelController.h"
#import "STAudioModeViewController.h"
#import "STAudioMixerConfiguration.h"
#import "RTActiveWheel.h"
#import "Masonry.h"

@interface STAudioMixingPannelController () <STAudioModeViewControllerDelegate,
                                             UIDocumentPickerDelegate,
                                             RCRTCAudioMixerAudioPlayDelegate>
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mixerModelLabel;

@property (weak, nonatomic) IBOutlet UILabel *localVolumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *micVolumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *remoteVolumeLabel;
@property (weak, nonatomic) IBOutlet UISlider *localVolumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *micVolumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *remoteVolueSlider;

@property (strong, nonatomic) UIButton *playBtn;
@property (strong, nonatomic) UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *playingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (nonatomic, assign) Float64 audioFileDuration;
@property (nonatomic, assign) BOOL updatePlayingTimeDisable;
@end

/**
 "play_and_mix"="Playing and mixing";
 "only_mix"="Only mixing";
 "only_play"="Only Playing";
 "play_and_mix_and_disbale_mic"="Playing and mixing, disable mic";
 */

NSString* desc(NSInteger mode) {
    switch (mode) {
        case 0:
            return @"本地播放，混音";
        case 1:
            return @"本地不播放，混音";
        case 2:
            return @"本地播放， 不混音";
        case 3:
            return @"本地播放，混音，禁止麦克";
        default:
            return @"unknown";
    }
}

@implementation STAudioMixingPannelController

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //      self.navigationController.navigationBarHidden = YES;
    
    if (self.config.audioFileURL.absoluteString.length <= 0) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"my_homeland" ofType:@"aac"];
        NSURL* fileURL = [NSURL fileURLWithPath:path];
        self.config.audioFileURL = fileURL;
    }
    
    [self setNavi];
    [self setupUI];
    
    [self setup];
}

- (void)setNavi{
    
    UIButton * closeBtn = [[UIButton alloc] init];
//    closeBtn.backgroundColor = [UIColor redColor];
    closeBtn.frame = CGRectMake(0, 0, 44, 44);
    [closeBtn setImage:[UIImage imageNamed:@"dismiss"] forState:(UIControlStateNormal)];
    [closeBtn addTarget:self action:@selector(closeAction:) forControlEvents:(UIControlEventTouchUpInside)];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
//    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                         NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:17]}];
    
    
}

- (void)setupUI{
 
    self.tableView.backgroundColor = [UIColor clearColor];
    
    //headview
    UIView * headerView = [[UIView alloc] init];
//    headerView.backgroundColor = [UIColor yellowColor];
    headerView.frame = CGRectMake(0, 0, MainscreenWidth, 44);
    
    self.playBtn = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.playBtn.tintColor = [UIColor systemGreenColor];
    [self.playBtn setImage:[UIImage imageNamed:@"audio_mixer_play"] forState:(UIControlStateNormal)];
    [self.playBtn addTarget:self action:@selector(playAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [headerView addSubview:self.playBtn];
    
    self.stopBtn = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.stopBtn.tintColor = [UIColor systemGreenColor];
    [self.stopBtn setImage:[UIImage imageNamed:@"audio_mixer_stop"] forState:(UIControlStateNormal)];
    [self.stopBtn addTarget:self action:@selector(resetAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [headerView addSubview:self.stopBtn];
    
//    PXDWeakSelf
    __weak typeof(self) weakSelf = self;
    [_stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(44);
        make.right.equalTo(headerView.mas_right).offset(-20);
        make.centerY.equalTo(headerView);
    }];
    
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(44);
        make.right.equalTo(weakSelf.stopBtn.mas_left).offset(-8);
        make.centerY.equalTo(headerView);
    }];
    [headerView layoutSubviews];
    
    self.tableView.tableHeaderView = headerView;
    
    
}

- (void)setup {
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 350);
    UIVisualEffectView* effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    effectView.alpha = 0.8;
    self.tableView.backgroundView = effectView;
    
    NSString* fileName = self.config.audioFileURL.lastPathComponent;
    Float64 duration =  [RCRTCAudioMixer durationOfAudioFile:self.config.audioFileURL];
    self.endTimeLabel.text = [self textFormatOfDuration:duration];
    self.audioFileDuration = duration;
    [RCRTCAudioMixer sharedInstance].delegate = self;
    self.fileNameLabel.text = fileName;
    self.localVolumeSlider.value = self.config.localVolume;
    self.micVolumeSlider.value = self.config.micVolume;
    self.remoteVolueSlider.value = self.config.remoteVolume;
    self.localVolumeLabel.text = [NSString stringWithFormat:@"%@",@((NSInteger)self.config.localVolume)];
    self.micVolumeLabel.text = [NSString stringWithFormat:@"%@",@((NSInteger)self.config.micVolume)];
    self.remoteVolumeLabel.text = [NSString stringWithFormat:@"%@",@((NSInteger)self.config.remoteVolume)];
    self.mixerModelLabel.text = desc(self.config.mixerModeIndex);
    if ([RCRTCAudioMixer sharedInstance].status == RTCMixEngineStatusPlaying) {
        self.playBtn.selected = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationItem.title = @"混音控制";
    
    //为什么无效了
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                         NSFontAttributeName : [UIFont boldSystemFontOfSize:17]}];
    
//    [self wr_setNavBarTintColor:[UIColor whiteColor]];
    
    //FIXME: 导航栏始终是有个UIView在显示白色， 怎么正确去除，各种设置都不行...只能执行下面去设置
    if ([[self.navigationController.navigationBar subviews] count]) {
        [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:0];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //设置，有效
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                         NSFontAttributeName : [UIFont boldSystemFontOfSize:17]}];
    
//    [self wr_setNavBarTintColor:[UIColor whiteColor]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.title = @" ";
}
#pragma mark - Helper
- (NSString*)textFormatOfDuration:(Float64)duration {
    Float64 fmiutes = duration / 60.0f;
    NSUInteger minutes = fmiutes;
    NSUInteger seconds = duration - minutes * 60;
    return [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)minutes, (unsigned long)seconds];
}
#pragma mark - Target Action
- (IBAction)closeAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)localVolumeChanged:(UISlider*)sender {
    self.localVolumeLabel.text = [NSString stringWithFormat:@"%@",@((NSInteger)sender.value)];
    self.config.localVolume = (NSInteger)sender.value;
    [[RCRTCAudioMixer sharedInstance] setPlayingVolume:sender.value];
}
- (IBAction)micVolumeChanged:(UISlider *)sender {
    self.micVolumeLabel.text = [NSString stringWithFormat:@"%@",@((NSInteger)sender.value)];
    self.config.micVolume = (NSInteger)sender.value;
    [[RCRTCEngine sharedInstance].defaultAudioStream setRecordingVolume:sender.value];
}
- (IBAction)remoteVolumeChanged:(UISlider *)sender {
    self.remoteVolumeLabel.text = [NSString stringWithFormat:@"%@",@((NSInteger)sender.value)];
    self.config.remoteVolume = (NSInteger)sender.value;
    [[RCRTCAudioMixer sharedInstance] setMixingVolume:sender.value];
}

- (IBAction)progressDidChanged:(UISlider *)sender {
    [[RCRTCAudioMixer sharedInstance] setPlayProgress:sender.value];
    self.updatePlayingTimeDisable = NO;
    self.playBtn.selected = YES;
}
- (IBAction)progressTouchDown:(id)sender {
    self.updatePlayingTimeDisable = YES;
}

- (IBAction)resetAction:(id)sender {
    [[RCRTCAudioMixer sharedInstance] stop];
    self.playBtn.selected = NO;
}

- (IBAction)playAction:(UIButton *)sender {
    if (!sender.isSelected) {
        if ([RCRTCAudioMixer sharedInstance].status == RTCMixEngineStatusPause) {
            [[RCRTCAudioMixer sharedInstance] resume];
        } else {
            NSURL* audioURL = self.config.audioFileURL;
            @try {
                BOOL isPlay = NO;
                RCRTCMixerMode mode = RCRTCMixerModeNone;
                if (self.config.mixingOption & STAudioMixingOptionPlaying) {
                    isPlay = YES;
                }
                if (self.config.mixingOption & STAudioMixingOptionMixing) {
                    mode = RCRTCMixerModeMixing;
                }
                
                if (self.config.mixingOption & STAudioMixingOptionReplaceMic) {
                    mode = RCRTCMixerModeReplace;
                }
                [[RCRTCAudioMixer sharedInstance] startMixingWithURL:audioURL
                                                            playback:isPlay
                                                           mixerMode:mode
                                                           loopCount:NSUIntegerMax];
            } @catch (NSException* e) {
                UIWindow* keyWin = [UIApplication sharedApplication].keyWindow;
                [RTActiveWheel showPromptHUDAddedTo:keyWin
                                               text:@"此数据无法播放/混音，请换其他数据后重试"];
                return;
            }
        }
    } else {
        [[RCRTCAudioMixer sharedInstance] pause];
    }
    sender.selected = !sender.isSelected;
}

#pragma makr - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > -44) {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = nil;
    } else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        static NSString * cell0ID = @"cell0";
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cell0ID];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cell0ID];
        }
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel * titleLabel = [cell.contentView viewWithTag:1001];
        if (!titleLabel) {
            titleLabel = [[UILabel alloc] init];
            titleLabel.frame = CGRectMake(8, 20, 80, 20);
            titleLabel.text = @"选择音频";
            titleLabel.font = [UIFont systemFontOfSize:18];
            titleLabel.textColor = [UIColor whiteColor];
            [cell.contentView addSubview:titleLabel];
        }
        
        UILabel * valueLabel = [cell.contentView viewWithTag:1002];
        if (!valueLabel) {
            valueLabel = [[UILabel alloc] init];
            valueLabel.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame)+10, 20, MainscreenWidth-CGRectGetMaxX(titleLabel.frame)-50, 20);
            valueLabel.font = [UIFont systemFontOfSize:17];
            valueLabel.textColor = [UIColor whiteColor];
            valueLabel.textAlignment = NSTextAlignmentRight;
            valueLabel.tag = 1002;
            [cell.contentView addSubview:valueLabel];
            
            self.fileNameLabel = valueLabel;
        }
        
        NSString* fileName = self.config.audioFileURL.lastPathComponent;
        self.fileNameLabel.text = fileName;
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_mixer_right_arrow"]];
        
        return cell;
        
    }else if (indexPath.row == 1){
        static NSString * cell1ID = @"cell1";
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cell1ID];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cell1ID];
        }
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel * titleLabel = [cell.contentView viewWithTag:1001];
        if (!titleLabel) {
            titleLabel = [[UILabel alloc] init];
            titleLabel.frame = CGRectMake(8, 20, 80, 20);
            titleLabel.text = @"本端音量";
            titleLabel.font = [UIFont systemFontOfSize:18];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.tag = 1001;
            [cell.contentView addSubview:titleLabel];
        }
        
        UISlider * vSlider = [cell.contentView viewWithTag:1002];
        if (!vSlider) {
            vSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+10, 20, MainscreenWidth-CGRectGetMaxX(titleLabel.frame)-70, 20)];
            vSlider.tag = 1002;
            vSlider.maximumValue = 100;
            vSlider.minimumValue = 0;
            vSlider.tintColor = [UIColor systemGreenColor];
            [vSlider addTarget:self action:@selector(localVolumeChanged:) forControlEvents:(UIControlEventValueChanged)];
            [cell.contentView addSubview:vSlider];
            
            self.localVolumeSlider = vSlider;
        }
        
        UILabel * volumeLable = [cell.contentView viewWithTag:1003];
        if (!volumeLable) {
            
            volumeLable = [[UILabel alloc] init];
            volumeLable.frame = CGRectMake(MainscreenWidth - 60, 20, 50, 20);
            volumeLable.text = @"100";
            volumeLable.font = [UIFont systemFontOfSize:17];
            volumeLable.textColor = [UIColor whiteColor];
            volumeLable.textAlignment = NSTextAlignmentCenter;
            volumeLable.tag = 1003;
            [cell.contentView addSubview:volumeLable];
            
            self.localVolumeLabel = volumeLable;
        }
        

        self.localVolumeSlider.value = self.config.localVolume;
        self.localVolumeLabel.text = [NSString stringWithFormat:@"%@",@((NSInteger)self.config.localVolume)];
        
        
        return cell;
    }else if (indexPath.row == 2){
        static NSString * cell2ID = @"cell2";
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cell2ID];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cell2ID];
        }
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel * titleLabel = [cell.contentView viewWithTag:1001];
        if (!titleLabel) {
            titleLabel = [[UILabel alloc] init];
            titleLabel.frame = CGRectMake(8, 20, 80, 20);
            titleLabel.text = @"远端音量";
            titleLabel.font = [UIFont systemFontOfSize:18];
            titleLabel.textColor = [UIColor whiteColor];
            [cell.contentView addSubview:titleLabel];
        }
        
        UISlider * vSlider = [cell.contentView viewWithTag:1002];
        if (!vSlider) {
            vSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+10, 20, MainscreenWidth-CGRectGetMaxX(titleLabel.frame)-70, 20)];
            vSlider.tag = 1002;
            vSlider.maximumValue = 100;
            vSlider.minimumValue = 0;
            vSlider.tintColor = [UIColor systemGreenColor];
            [vSlider addTarget:self action:@selector(remoteVolumeChanged:) forControlEvents:(UIControlEventValueChanged)];
            [cell.contentView addSubview:vSlider];
            
            self.remoteVolueSlider = vSlider;
        }
        
        UILabel * volumeLable = [cell.contentView viewWithTag:1003];
        if (!volumeLable) {
            
            volumeLable = [[UILabel alloc] init];
            volumeLable.frame = CGRectMake(MainscreenWidth - 60, 20, 50, 20);
            volumeLable.text = @"100";
            volumeLable.font = [UIFont systemFontOfSize:17];
            volumeLable.textColor = [UIColor whiteColor];
            volumeLable.textAlignment = NSTextAlignmentCenter;
            volumeLable.tag = 1003;
            [cell.contentView addSubview:volumeLable];
            
            self.remoteVolumeLabel = volumeLable;
        }
        

        self.remoteVolueSlider.value = self.config.remoteVolume;
        self.remoteVolumeLabel.text = [NSString stringWithFormat:@"%@",@((NSInteger)self.config.remoteVolume)];
        
        return cell;
    }else if (indexPath.row == 3){
        static NSString * cell3ID = @"cell3";
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cell3ID];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cell3ID];
        }
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel * titleLabel = [cell.contentView viewWithTag:1001];
        if (!titleLabel) {
            titleLabel = [[UILabel alloc] init];
            titleLabel.frame = CGRectMake(8, 20, 100, 20);
            titleLabel.text = @"麦克风音量";
            titleLabel.font = [UIFont systemFontOfSize:18];
            titleLabel.textColor = [UIColor whiteColor];
            [cell.contentView addSubview:titleLabel];
        }
        
        UISlider * vSlider = [cell.contentView viewWithTag:1002];
        if (!vSlider) {
            vSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+10, 20, MainscreenWidth-CGRectGetMaxX(titleLabel.frame)-70, 20)];
            vSlider.tag = 1002;
            vSlider.maximumValue = 100;
            vSlider.minimumValue = 0;
            vSlider.tintColor = [UIColor systemGreenColor];
            [vSlider addTarget:self action:@selector(micVolumeChanged:) forControlEvents:(UIControlEventValueChanged)];
            [cell.contentView addSubview:vSlider];
            
            self.micVolumeSlider = vSlider;
        }
        
        UILabel * volumeLable = [cell.contentView viewWithTag:1003];
        if (!volumeLable) {
            
            volumeLable = [[UILabel alloc] init];
            volumeLable.frame = CGRectMake(MainscreenWidth - 60, 20, 50, 20);
            volumeLable.text = @"100";
            volumeLable.font = [UIFont systemFontOfSize:17];
            volumeLable.textColor = [UIColor whiteColor];
            volumeLable.textAlignment = NSTextAlignmentCenter;
            volumeLable.tag = 1003;
            [cell.contentView addSubview:volumeLable];
            
            self.micVolumeLabel = volumeLable;
        }
        
        self.micVolumeSlider.value = self.config.micVolume;
        self.micVolumeLabel.text = [NSString stringWithFormat:@"%@",@((NSInteger)self.config.micVolume)];
        
        return cell;
    }else if (indexPath.row == 4){
        static NSString * cell4ID = @"cell4";
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cell4ID];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cell4ID];
        }
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel * titleLabel = [cell.contentView viewWithTag:1001];
        if (!titleLabel) {
            titleLabel = [[UILabel alloc] init];
            titleLabel.frame = CGRectMake(8, 20, 80, 20);
            titleLabel.text = @"混音模式";
            titleLabel.font = [UIFont systemFontOfSize:18];
            titleLabel.textColor = [UIColor whiteColor];
            [cell.contentView addSubview:titleLabel];
        }
        
        UILabel * valueLabel = [cell.contentView viewWithTag:1002];
        if (!valueLabel) {
            valueLabel = [[UILabel alloc] init];
            valueLabel.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame)+10, 20, MainscreenWidth-CGRectGetMaxX(titleLabel.frame)-50, 20);
            valueLabel.font = [UIFont systemFontOfSize:17];
            valueLabel.textColor = [UIColor whiteColor];
            valueLabel.textAlignment = NSTextAlignmentRight;
            valueLabel.tag = 1002;
            [cell.contentView addSubview:valueLabel];
            
            self.mixerModelLabel = valueLabel;
        }
        
        self.mixerModelLabel.text = desc(self.config.mixerModeIndex);
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_mixer_right_arrow"]];
        
        return cell;
    }else{
        
        static NSString * cellID = @"defaultCell";
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellID];
        }
        cell.contentView.backgroundColor = indexPath.row%2==0?[UIColor redColor]:[UIColor greenColor];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (0 == indexPath.row) {
        UIDocumentPickerViewController *dpvc =
            [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.audio"]
                                                                   inMode:UIDocumentPickerModeImport];
        dpvc.delegate = self;
        if (@available(iOS 13, *)) {
            dpvc.shouldShowFileExtensions = YES;
        }
        [self presentViewController:dpvc animated:YES completion:nil];
    }
    
    if (4 == indexPath.row) {
        
        STAudioModeViewController* amvc = [[STAudioModeViewController alloc] init];
        amvc.mixerModeIndex = self.config.mixerModeIndex;
        amvc.delegate = self;
        [self.navigationController pushViewController:amvc animated:YES];
    }
    
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    self.config.audioFileURL = url;
    self.fileNameLabel.text = url.lastPathComponent;
    [[RCRTCAudioMixer sharedInstance] stop];
    self.playBtn.selected = NO;
    Float64 duration =  [RCRTCAudioMixer durationOfAudioFile:self.config.audioFileURL];
    self.audioFileDuration = duration;
    self.playingTimeLabel.text = @"00:00";
    self.endTimeLabel.text = [self textFormatOfDuration:duration];
    self.progressSlider.value = 0;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"push_audio_mode"]) {
        STAudioModeViewController* amvc = segue.destinationViewController;
        amvc.mixerModeIndex = self.config.mixerModeIndex;
        amvc.delegate = self;
    }
}


#pragma mark -STAudioModeViewControllerDelegate

- (void)didSelectedModeOptions:(STAudioMixingOption)option atIndex:(NSInteger)index {
    self.mixerModelLabel.text = desc(index);
    self.config.mixerModeIndex = index;
    self.config.mixingOption = option;
    [[RCRTCAudioMixer sharedInstance] stop];
    self.playBtn.selected = NO;
}

#pragma mark - RongRTCAudioMixerDelegate
- (void)didReportPlayingProgress:(float)progress {
    if (!self.updatePlayingTimeDisable) {
        [self.progressSlider setValue:progress animated:YES];
        Float64 playAt = self.audioFileDuration * progress;
        self.playingTimeLabel.text = [self textFormatOfDuration:playAt];
    }
    
}
- (void)didPlayToEnd {
    if (!self.updatePlayingTimeDisable) {
        self.progressSlider.value = 1;
    }
}

@end

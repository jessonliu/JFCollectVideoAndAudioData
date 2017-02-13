//
//  ViewController.m
//  JFCollectVideoAndAudioData
//
//  Created by Jessonliu iOS on 2017/2/9.
//  Copyright © 2017年 Jessonliu. All rights reserved.
//

#import "ViewController.h"
#import "JFCaptureSession.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <JFCaptureSessionDelegate> {
 
}
@property (nonatomic, strong) JFCaptureSession *session;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIView *MenuView;
@property (nonatomic, assign) NSInteger authRemember;   // 授权记录 这里只简单地实现效果, 如果授权摄像头 += 1, 如果同时授权了麦克风 += 1, 在setter 方法里, 判断, authRemember == 2 再进行音视频数据采集

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self checkVideoDeviceAuth];
    [self checkAudioDeviceAuth];
}

// 检查是否授权摄像头的使用权限
- (void)checkVideoDeviceAuth {
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized:    // 已授权
            self.authRemember += 1;
            break;
        case AVAuthorizationStatusNotDetermined: // 未授权, 进行允许和拒绝授权
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    self.authRemember += 1;
                } else {
                    NSLog(@"拒绝授权");
                }
            }];
        }
            break;
        default:
            NSLog(@"用户尚未授权摄像头的使用权");
            break;
    }
}

// 检查是否授权麦克风的shiyongquan
- (void)checkAudioDeviceAuth {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (granted) {
                    self.authRemember += 1;
                } else {
                    NSLog(@"拒绝授权");
                }
            }];
        }
            break;
        case AVAuthorizationStatusAuthorized:
            self.authRemember += 1;
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            break;
        default:
            break;
    }
}

// 检测授权状态
- (void)setAuthRemember:(NSInteger)authRemember {
    _authRemember = authRemember;
    // 只有麦克风和摄像头都授权了, 才进行视频采集 (该方法简单, 但逻辑不严谨)
    if (_authRemember == 2) {
        self.session = [[JFCaptureSession alloc] defaultJFCaptureSessionWithSessionPreset:JFCaptureSessionPreset540x960];
        _session.preView = self.view;
        _session.delegate = self;
        [self.view bringSubviewToFront:self.actionButton];
        [self.view bringSubviewToFront:self.MenuView];
        [self.view bringSubviewToFront:self.imageView];
    }
}

#pragma mark - JFCaptureSessionDelegate
/** 视频取样数据回调 */
- (void)videoCaptureOutputWithSampleBuffer:(CMSampleBufferRef)sampleBuffer {

    // 这也是一种视频图像展示的方式, 但需要处理视频方向问题, 这里不做处理
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 转换为CIImage
    CIImage *ciImage = [CIImage imageWithCVImageBuffer:imageBuffer];
    // 转换UIImage
    UIImage *image = [UIImage imageWithCIImage:ciImage];
    // 回到主线程更新UI
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
    });
    
    // 在此方法中进行 H.264 硬软编码
    
}

/** 音频取样数据回调 */
- (void)audioCaptureOutputWithSampleBuffer:(CMSampleBufferRef)sampleBuffer {
   // 在此方法进行 AAC 软硬编码
    
}


- (IBAction)CollectDataButtonAction:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.selected) {
        
        // 开始采集
        [self.session startRunning];
    } else {
        // 结束采集
        [self.session stopRunning];
    }
}
- (IBAction)changeVideoDevicePositionAction:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.selected) {
        // 转换至后置摄像头
        self.session.videoDevicePosition = JFCaptureDevicePositionBack;
    } else {
        // 转换至前置摄像头
        self.session.videoDevicePosition = JFCaptureDevicePositionFront;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

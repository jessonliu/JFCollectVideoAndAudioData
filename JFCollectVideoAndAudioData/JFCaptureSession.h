//
//  JFCaptureSession.h
//  JFCollectVideoAndAudioData
//
//  Created by Jessonliu iOS on 2017/2/9.
//  Copyright © 2017年 Jessonliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, JFCaptureSessionPreset){
    /// 低分辨率
    JFCaptureSessionPreset368x640 = 0,
    /// 中分辨率
    JFCaptureSessionPreset540x960 = 1,
    /// 高分辨率
    JFCaptureSessionPreset720x1280 = 2
};

// 摄像头方向
typedef NS_ENUM(NSInteger, JFCaptureDevicePosition) {
    JFCaptureDevicePositionFront = 0,
    JFCaptureDevicePositionBack
};

@protocol JFCaptureSessionDelegate <NSObject>

/** 视频取样数据回调 */
- (void)videoCaptureOutputWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/** 音频取样数据回调 */
- (void)audioCaptureOutputWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

@interface JFCaptureSession : NSObject


- (instancetype)defaultJFCaptureSessionWithSessionPreset:(JFCaptureSessionPreset)sessionPreset;


/**
 展示视频图像的试图
 */
@property (nonatomic, strong) UIView *preView;

@property (nonatomic, assign) JFCaptureDevicePosition videoDevicePosition;

@property (nonatomic, assign) id <JFCaptureSessionDelegate> delegate;


/**
 开始
 */
- (void)startRunning;

/**
 暂停
 */
- (void)stopRunning;







@end

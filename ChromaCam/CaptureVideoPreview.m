/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Camera preview.
*/

@import AVFoundation;

#import "CaptureVideoPreview.h"
#import <objc/runtime.h>

@implementation CaptureVideoPreview

#pragma mark - Method Swizzling

- (void)awakeFromNib {
    [super awakeFromNib];
//    NSLog(@"awakeFromNib: %@", [[self.layer.class layerClass] description]);
}

//- (void)awakeFromNib
//{
////    dispatch_async(capture_session_configuration_queue, ^{
//        _captureDevice            = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualWideCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
//        [_captureDevice.captureDeviceInput      = [AVCaptureDeviceInput deviceInputWithDevice:_captureSession.captureDevice error:nil] setUnifiedAutoExposureDefaultsEnabled:TRUE];
//        [videoCameraForPreviewLayer.captureConnection       = [[AVCaptureConnection alloc] initWithInputPort:[[videoCameraForPreviewLayer.captureDeviceInput portsWithMediaType:AVMediaTypeVideo sourceDeviceType:AVCaptureDeviceTypeBuiltInDualWideCamera sourceDevicePosition:AVCaptureDevicePositionBack] firstObject] videoPreviewLayer:videoCameraForPreviewLayer.captureVideoPreviewLayer] setVideoOrientation:AVCaptureVideoOrientationPortrait];
//        [videoCameraForPreviewLayer.captureSession          = [[AVCaptureSession alloc] init] setSessionPreset:([videoCameraForPreviewLayer.captureSession canSetSessionPreset:AVCaptureSessionPreset3840x2160]) ? AVCaptureSessionPreset3840x2160 : AVCaptureSessionPreset1920x1080];
//        [videoCameraForPreviewLayer.captureSession beginConfiguration];
//        {
//            [videoCameraForPreviewLayer.captureSession addInput:([videoCameraForPreviewLayer.captureSession canAddInput:videoCameraForPreviewLayer.captureDeviceInput]) ? videoCameraForPreviewLayer.captureDeviceInput : nil];
//            [videoCameraForPreviewLayer.captureSession addConnection:([videoCameraForPreviewLayer.captureSession canAddConnection:videoCameraForPreviewLayer.captureConnection]) ? videoCameraForPreviewLayer.captureConnection : nil];
//        }
//        [videoCameraForPreviewLayer.captureSession commitConfiguration];
//    });
//}

@end

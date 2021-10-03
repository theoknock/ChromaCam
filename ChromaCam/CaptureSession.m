//
//  VideoCamera.m
//  ChromaCam
//
//  Created by Xcode Developer on 9/25/21.
//

#import "CaptureSession.h"

#include "CaptureSessionConfigurationQueue.h"

@implementation CaptureSession

static CaptureSession *  = nil;

+ (CaptureSession *)videoCameraForPreviewLayer:(AVCaptureVideoPreviewLayer *)captureVideoPreviewLayer;
{
    if (videoCameraForPreviewLayer == nil)
    {
        videoCameraForPreviewLayer = [[super allocWithZone:NULL] init];
        dispatch_async(capture_session_configuration_queue, ^{
            videoCameraForPreviewLayer.captureDevice            = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualWideCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
            [videoCameraForPreviewLayer.captureDeviceInput      = [AVCaptureDeviceInput deviceInputWithDevice:videoCameraForPreviewLayer.captureDevice error:nil] setUnifiedAutoExposureDefaultsEnabled:TRUE];
            [videoCameraForPreviewLayer.captureConnection       = [[AVCaptureConnection alloc] initWithInputPort:[[videoCameraForPreviewLayer.captureDeviceInput portsWithMediaType:AVMediaTypeVideo sourceDeviceType:AVCaptureDeviceTypeBuiltInDualWideCamera sourceDevicePosition:AVCaptureDevicePositionBack] firstObject] videoPreviewLayer:videoCameraForPreviewLayer.captureVideoPreviewLayer] setVideoOrientation:AVCaptureVideoOrientationPortrait];
            [videoCameraForPreviewLayer.captureSession          = [[AVCaptureSession alloc] init] setSessionPreset:([videoCameraForPreviewLayer.captureSession canSetSessionPreset:AVCaptureSessionPreset3840x2160]) ? AVCaptureSessionPreset3840x2160 : AVCaptureSessionPreset1920x1080];
            [videoCameraForPreviewLayer.captureSession beginConfiguration];
            {
                [videoCameraForPreviewLayer.captureSession addInput:([videoCameraForPreviewLayer.captureSession canAddInput:videoCameraForPreviewLayer.captureDeviceInput]) ? videoCameraForPreviewLayer.captureDeviceInput : nil];
                [videoCameraForPreviewLayer.captureSession addConnection:([videoCameraForPreviewLayer.captureSession canAddConnection:videoCameraForPreviewLayer.captureConnection]) ? videoCameraForPreviewLayer.captureConnection : nil];
            }
            [videoCameraForPreviewLayer.captureSession commitConfiguration];
        });
    }
    
    
//    videoCameraForPreviewLayer.captureSession.connections.firstObject.la
    return videoCameraForPreviewLayer;
}

@end



//
//  ViewController.m
//  ChromaCam
//
//  Created by Xcode Developer on 9/25/21.
//

#import "ViewController.h"

@interface ViewController ()
{
    AVCaptureDevice                                * captureDevice;
    AVCaptureDeviceInput                           * captureInput;
    AVCaptureConnection                            * captureConnection;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    captureDevice        = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    [captureInput        = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil] setUnifiedAutoExposureDefaultsEnabled:TRUE];
    [captureConnection   = [[AVCaptureConnection alloc] initWithInputPort:captureInput.ports.firstObject videoPreviewLayer:(AVCaptureVideoPreviewLayer *)self.captureVideoPreview.layer] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    [self.captureSession = [[AVCaptureSession alloc] init] setSessionPreset:([self.captureSession canSetSessionPreset:AVCaptureSessionPreset3840x2160]) ? AVCaptureSessionPreset3840x2160 : AVCaptureSessionPreset1920x1080];
    [self.captureSession beginConfiguration];
    {
        [self.captureSession addInput:([self.captureSession canAddInput:captureInput]) ? captureInput : nil];
        
        [(AVCaptureVideoPreviewLayer *)self.captureVideoPreview.layer setSessionWithNoConnection:self.captureSession];
        
        [self.captureSession addConnection:([self.captureSession canAddConnection:captureConnection]) ? captureConnection : nil];
    }
    [self.captureSession commitConfiguration];
    
    [self.captureSession startRunning];
    
    [self.scrollView setContentOffset:CGPointMake(-100.0, 0)];
}


@end

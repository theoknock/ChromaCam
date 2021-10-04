//
//  ViewController.m
//  ChromaCam
//
//  Created by Xcode Developer on 9/25/21.
//

#import "ViewController.h"

@interface ViewController ()
{
    AVCaptureSession     * captureSession;
    AVCaptureDevice      * captureDevice;
    AVCaptureDeviceInput * captureInput;
    AVCaptureConnection  * captureConnection;
    
    void (^configureCameraProperty)(float);
    void (^setLensPosition)(float);
    void (^setZoomFactor)(float);
    void (^setExposureDuration)(float);
}

@end

@implementation ViewController

static float scale(float unscaledNum, float minAllowed, float maxAllowed, float min, float max) {
    return (maxAllowed - minAllowed) * (unscaledNum - min) / (max - min) + minAllowed;
}

static float (^exposureDurationSliderValue)(AVCaptureDevice *, float) = ^ float (AVCaptureDevice * video_device, float x) {
    double minDurationSeconds = CMTimeGetSeconds(video_device.activeFormat.minExposureDuration);
    double maxDurationSeconds = 1.0/3.0;                                                                // vs. CMTimeGetSeconds(self.videoDevice.activeFormat.maxExposureDuration);
    double p = pow(x, 5.0);                             // Apply power function to expand slider's low-end range
    double newDurationSeconds = p * ( maxDurationSeconds - minDurationSeconds) + minDurationSeconds;    // Scale from 0-1 slider range to actual duration
    
    return newDurationSeconds;
};

static CMTime (^secondsToCMTime)(float) = ^ CMTime (float seconds) {
    CMTime exposureDurationValue = CMTimeMakeWithSeconds(seconds, 1000*1000*1000);
    
    return exposureDurationValue;
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [captureSession = [[AVCaptureSession alloc] init] setSessionPreset:([captureSession canSetSessionPreset:AVCaptureSessionPreset3840x2160]) ? AVCaptureSessionPreset3840x2160 : AVCaptureSessionPreset1920x1080];
    [captureSession beginConfiguration];
    {
        captureDevice        = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        [captureInput        = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil] setUnifiedAutoExposureDefaultsEnabled:TRUE];
        [captureSession addInput:([captureSession canAddInput:captureInput]) ? captureInput : nil];
        
        [(AVCaptureVideoPreviewLayer *)self.captureVideoPreview.layer setSessionWithNoConnection:captureSession];
        
        [captureConnection   = [[AVCaptureConnection alloc] initWithInputPort:captureInput.ports.firstObject videoPreviewLayer:(AVCaptureVideoPreviewLayer *)self.captureVideoPreview.layer] setVideoOrientation:AVCaptureVideoOrientationPortrait];
        [captureSession addConnection:([captureSession canAddConnection:captureConnection]) ? captureConnection : nil];
    }
    [captureSession commitConfiguration];
    [captureSession startRunning];
    
    setZoomFactor = ^(AVCaptureDevice * cd, float range_min, float range_max, float min_x, float max_x) {
        return ^ void (float x) {
                float value = scale(x, range_min, range_max, min_x, max_x);
                [cd setVideoZoomFactor:MAX(range_min, MIN(value, range_max))];
            };
    }(captureDevice, 1.0, captureDevice.activeFormat.videoMaxZoomFactor, 0.0, CGRectGetWidth(self.scrollView.bounds));
    
    setLensPosition = ^(AVCaptureDevice * cd, float range_min, float range_max, float min_x, float max_x) {
        return ^ void (float x) {
            float value = MAX(range_min, MIN(scale(x, range_min, range_max, min_x, max_x), range_max));
            [cd setFocusModeLockedWithLensPosition:value completionHandler:nil];
        };
    }(captureDevice, 0.0, 1.0, 0.0, CGRectGetWidth(self.scrollView.bounds));
    
    setExposureDuration = ^(AVCaptureDevice * cd, float range_min, float range_max, float min_x, float max_x) {
        double minDurationSeconds = 1.0/1000.0; // CMTimeGetSeconds(cd.activeFormat.minExposureDuration);
        double maxDurationSeconds = 1.0/3.0;                                                                // vs. CMTimeGetSeconds(self.videoDevice.activeFormat.maxExposureDuration);
        
        return ^ void (float x) {
            float value = MAX(range_min, MIN(scale(x, range_min, range_max, min_x, max_x), range_max));
            double p = pow(value, 5.0);                             // Apply power function to expand slider's low-end range
            double seconds = p * ( maxDurationSeconds - minDurationSeconds) + minDurationSeconds;    // Scale from 0-1 slider range to actual duration
            CMTime exposureDurationValue = CMTimeMakeWithSeconds(seconds, 1000*1000*1000);
            [cd setExposureModeCustomWithDuration:exposureDurationValue ISO:AVCaptureISOCurrent completionHandler:nil];
        };
    }(captureDevice, 0.0, 1.0, 0.0, CGRectGetWidth(self.scrollView.bounds));
}

- (IBAction)setCameraProperty:(UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIButton * button in self.cameraControlButtons)
        {
            [button setSelected:FALSE];
            [button setHighlighted:FALSE];
        }
        [(UIButton *)sender setSelected:TRUE ];
        [(UIButton *)sender setHighlighted:TRUE];
        
        NSInteger tag = [sender tag];
        void(^cameraPropertyConfiguration)(float) = nil;
        switch (tag) {
            case 0: {
                cameraPropertyConfiguration = setZoomFactor;
                break;
            }
            case 1: {
                cameraPropertyConfiguration = setZoomFactor;
                break;
            }
            case 2: {
                cameraPropertyConfiguration = setExposureDuration;
                break;
            }
            case 3: {
                cameraPropertyConfiguration = setZoomFactor;
                break;
            }
            case 4: {
                cameraPropertyConfiguration = setLensPosition;
                break;
            }
            default:
                break;
        }
        
        configureCameraProperty = ^ (void(^cameraPropertySetter)(float)) {
            return ^ void (float x) {
                cameraPropertySetter(x);
            };
        }(cameraPropertyConfiguration);
    });
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [captureDevice lockForConfiguration:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // To-Do: Get selected button...
    if ((scrollView.isDragging || scrollView.isTracking || scrollView.isDecelerating))
    {
        configureCameraProperty(scrollView.contentOffset.x);
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [captureDevice unlockForConfiguration];
}

@end

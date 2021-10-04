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
    void (^setISO)(float);
    void (^setTorchLevel)(float);
}

@end

@implementation ViewController

static float scale(float unscaledNum, float minAllowed, float maxAllowed, float min, float max) {
    return (maxAllowed - minAllowed) * (unscaledNum - min) / (max - min) + minAllowed;
}

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
        double minDurationSeconds = 1.0/1000.0;
        double maxDurationSeconds = 1.0/3.0;
        
        return ^ void (float x) {
            float value = MAX(range_min, MIN(scale(x, range_min, range_max, min_x, max_x), range_max));
            double p = pow(value, 5.0);
            double seconds = p * ( maxDurationSeconds - minDurationSeconds) + minDurationSeconds;
            CMTime exposureDurationValue = CMTimeMakeWithSeconds(seconds, 1000*1000*1000);
            [cd setExposureModeCustomWithDuration:exposureDurationValue ISO:AVCaptureISOCurrent completionHandler:nil];
        };
    }(captureDevice, 0.0, 1.0, 0.0, CGRectGetWidth(self.scrollView.bounds));
    
    setISO = ^(AVCaptureDevice * cd, float range_min, float range_max, float min_x, float max_x) {
        return ^ void (float x) {
            float value = MAX(range_min, MIN(scale(x, range_min, range_max, min_x, max_x), range_max));
            [cd setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:value completionHandler:nil];
        };
    }(captureDevice, captureDevice.activeFormat.minISO, captureDevice.activeFormat.maxISO, 0.0, CGRectGetWidth(self.scrollView.bounds));
    
    setTorchLevel = ^(AVCaptureDevice * cd, float range_min, float range_max, float min_x, float max_x) {
        return ^ void (float x) {
            float value = MAX(range_min, MIN(scale(x, range_min, range_max, min_x, max_x), range_max));
            if (value != 0.0 && ([[NSProcessInfo processInfo] thermalState] != NSProcessInfoThermalStateCritical && [[NSProcessInfo processInfo] thermalState] != NSProcessInfoThermalStateSerious))
                [cd setTorchModeOnWithLevel:value error:nil];
            else
                [cd setTorchMode:AVCaptureTorchModeOff];
        };
    }(captureDevice, 0.0, 1.0, 0.0, CGRectGetWidth(self.scrollView.bounds));
    
    configureCameraProperty = ^ (void(^cameraPropertySetter)(float)) {
        return ^ void (float x) {
            cameraPropertySetter(x);
        };
    }(setExposureDuration);
}

- (IBAction)setCameraProperty:(UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIButton * button in self.cameraControlButtons)
        {
            [button setSelected:FALSE];
            [button setHighlighted:FALSE];
        }
        
        [(UIButton *)sender setSelected:TRUE];
        [(UIButton *)sender setHighlighted:TRUE];
        
        NSInteger tag = [sender tag];
        void(^cameraPropertyConfiguration)(float) = nil;
        switch (tag) {
            case 0: {
                cameraPropertyConfiguration = setTorchLevel;
                break;
            }
            case 1: {
                cameraPropertyConfiguration = setLensPosition;
                break;
            }
            case 2: {
                cameraPropertyConfiguration = setExposureDuration;
                break;
            }
            case 3: {
                cameraPropertyConfiguration = setISO;
                break;
            }
            case 4: {
                cameraPropertyConfiguration = setZoomFactor;
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

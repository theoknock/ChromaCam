//
//  ViewController.m
//  ChromaCam
//
//  Created by Xcode Developer on 9/25/21.
//

#import "ViewController.h"
#import "CaptureSessionConfigurationQueue.h"

typedef enum : NSUInteger {
    CaptureDevicePropertyTorchLevel,
    CaptureDevicePropertyLensPosition,
    CaptureDevicePropertyExposureDuration,
    CaptureDevicePropertyISO,
    CaptureDevicePropertyZoomFactor
} CaptureDeviceProperty;

@interface ViewController ()
{
    AVCaptureSession     * captureSession;
    AVCaptureDevice      * captureDevice;
    AVCaptureDeviceInput * captureInput;
    AVCaptureConnection  * captureConnection;
    
    void (^configureCameraProperty)(float);
    // add a block that executes when these properties are first initialized to set the scroll view offset to the current property value equivalent
    void (^setLensPosition)(float);
    void (^setZoomFactor)(float);
    void (^setExposureDuration)(float);
    void (^setISO)(float);
    void (^setTorchLevel)(float);
    
    void (^setScrollViewOffset)(float(^normalizedCameraPropertyValue)(void));
}

@end

@implementation ViewController

static float normalize(float value, float min, float max) {
    return (value - min) / (max - min);
}

static float scale(float old_value, float old_min, float old_max, float new_min, float new_max) {
    return (new_max - new_min) * (old_value - old_min) / (old_max - old_min) + new_min;
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
    
    [self setCameraProperty:self.torchLevelButton];
}

- (IBAction)setCameraProperty:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [(UIButton *)sender setSelected:TRUE];
        [(UIButton *)sender setHighlighted:TRUE];
        
        CGPoint scrollViewContentOffset = CGPointMake([(UIButton *)sender bounds].size.width * [sender tag], self.propertyScrollView.contentOffset.y);
        [self.propertyScrollView setContentOffset:scrollViewContentOffset animated:TRUE];
        
        CGFloat scrollViewCenterX = CGRectGetWidth(self.propertyScrollView.bounds);
        
        for (UIButton * button in self.cameraControlButtons)
        {
            [button setSelected:FALSE];
            [button setHighlighted:FALSE];
            
            // To-Do: Move this so that it is accessible from the scrollViewDidScroll
            CGFloat buttonCenterX = [button bounds].size.width * [sender tag];
            CGFloat differenceCenterXMax = [button bounds].size.width * 2;
            CGFloat differenceCenterX = fabs(buttonCenterX - scrollViewCenterX);
            // 0 == 100% size; 2 * buttonCenterX == 25% reduction in size
            // scale(float old_value, float old_min, float old_max, float new_min, float new_max)
            CGFloat resize = fabs(scale(differenceCenterX, 0.0, differenceCenterXMax, 42.0, 10.5));
            NSLog(@"resize % == %f", resize);
            [button invalidateIntrinsicContentSize];
            UIImage * resizedImage = [button.currentImage imageByApplyingSymbolConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:resize]];
            [button setImage:resizedImage forState:UIControlStateNormal];
        }
        
        
        NSInteger tag = [sender tag];
        void(^cameraPropertyConfiguration)(float) = nil;
        switch (tag) {
            case CaptureDevicePropertyTorchLevel: {
                cameraPropertyConfiguration = ^ (UIScrollView * valueScrollView, AVCaptureDevice * cd, float old_value, float old_min, float old_max) {
                    CGPoint scrollViewContentOffset = CGPointMake(old_value * CGRectGetWidth(valueScrollView.bounds), valueScrollView.contentOffset.y);
                    [valueScrollView setContentOffset:scrollViewContentOffset animated:TRUE];
                    
                    return ^ void (float offset) {
                        float new_value = MAX(old_min, MIN(scale(offset, 0.0, CGRectGetWidth(valueScrollView.bounds), old_min, old_max), old_max));
                        if (new_value != 0.0 && ([[NSProcessInfo processInfo] thermalState] != NSProcessInfoThermalStateCritical && [[NSProcessInfo processInfo] thermalState] != NSProcessInfoThermalStateSerious))
                            [cd setTorchModeOnWithLevel:new_value error:nil];
                        else
                            [cd setTorchMode:AVCaptureTorchModeOff];
                    };
                }(self.valueScrollView, captureDevice, [captureDevice torchLevel], 0.0, 1.0);
                break;
            }
            case CaptureDevicePropertyLensPosition: {
                cameraPropertyConfiguration = ^ (UIScrollView * valueScrollView, AVCaptureDevice * cd, float old_value, float old_min, float old_max) {
                    CGPoint scrollViewContentOffset = CGPointMake(old_value * CGRectGetWidth(valueScrollView.bounds), valueScrollView.contentOffset.y);
                    [valueScrollView setContentOffset:scrollViewContentOffset animated:TRUE];
                    
                    return ^ void (float offset) {
                        float new_value = MAX(old_min, MIN(scale(offset, 0.0, CGRectGetWidth(valueScrollView.bounds), old_min, old_max), old_max));
                        [cd setFocusModeLockedWithLensPosition:new_value completionHandler:nil];
                    };
                }(self.valueScrollView, captureDevice, captureDevice.lensPosition, 0.0, 1.0);
                break;
            }
            case CaptureDevicePropertyExposureDuration: {
                cameraPropertyConfiguration = ^ (UIScrollView * valueScrollView, AVCaptureDevice * cd, float old_value, float old_min, float old_max) {
                    float normalized_value = normalize(old_value, old_min, old_max);
                    float offset_value     = normalized_value * CGRectGetWidth(valueScrollView.bounds);
                    CGPoint scrollViewContentOffset = CGPointMake(offset_value, valueScrollView.contentOffset.y);
                    [valueScrollView setContentOffset:scrollViewContentOffset animated:TRUE];
                    
                    return ^ void (float offset) {
                        float new_value = MAX(old_min, MIN(scale(offset, 0.0, CGRectGetWidth(valueScrollView.bounds), old_min, old_max), old_max));
                        CMTime exposureDurationValue = CMTimeMakeWithSeconds(new_value, 1000*1000*1000);
                        [cd setExposureModeCustomWithDuration:exposureDurationValue ISO:AVCaptureISOCurrent completionHandler:nil];
                    };
                }(self.valueScrollView, captureDevice, CMTimeGetSeconds([captureDevice exposureDuration]), CMTimeGetSeconds(captureDevice.activeFormat.minExposureDuration), 1.0/3.0);
                break;
            }
            case CaptureDevicePropertyISO: {
                cameraPropertyConfiguration = ^ (UIScrollView * valueScrollView, AVCaptureDevice * cd, float old_value, float old_min, float old_max) {
                    float normalized_value = normalize(old_value, old_min, old_max);
                    float offset_value     = normalized_value * CGRectGetWidth(valueScrollView.bounds);
                    CGPoint scrollViewContentOffset = CGPointMake(offset_value, valueScrollView.contentOffset.y);
                    [valueScrollView setContentOffset:scrollViewContentOffset animated:TRUE];
                    
                    return ^ void (float offset) {
                        float new_value = MAX(old_min, MIN(scale(offset, 0.0, CGRectGetWidth(valueScrollView.bounds), old_min, old_max), old_max));
                        [cd setExposureModeCustomWithDuration:captureDevice.exposureDuration ISO:new_value completionHandler:nil];
                    };
                }(self.valueScrollView, captureDevice, captureDevice.ISO, captureDevice.activeFormat.minISO, captureDevice.activeFormat.maxISO);
                break;
            }
            case CaptureDevicePropertyZoomFactor: {
                cameraPropertyConfiguration = ^(UIScrollView * valueScrollView, AVCaptureDevice * cd, float old_value, float old_min, float old_max) {
                    float normalized_value = normalize(old_value, old_min, old_max);
                    float offset_value     = normalized_value * CGRectGetWidth(valueScrollView.bounds);
                    CGPoint scrollViewContentOffset = CGPointMake(offset_value, valueScrollView.contentOffset.y);
                    [valueScrollView setContentOffset:scrollViewContentOffset animated:TRUE];
                    
                    return ^ void (float offset) {
                        float new_value = MAX(old_min, MIN(scale(offset, 0.0, CGRectGetWidth(valueScrollView.bounds), old_min, old_max), old_max));
                        [cd setVideoZoomFactor:new_value];
                    };
                }(self.valueScrollView, captureDevice, captureDevice.videoZoomFactor, captureDevice.minAvailableVideoZoomFactor, captureDevice.maxAvailableVideoZoomFactor);
                break;
            }
            default:
                break;
        }
        
        configureCameraProperty = ^ (void(^cameraPropertySetter)(float)) {
            return ^ void (float x) {
                dispatch_async(capture_session_configuration_queue_ref(), ^{
                    cameraPropertySetter(x);
                });
            };
        }(cameraPropertyConfiguration);
    });
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)valueScrollView
{
    [captureDevice lockForConfiguration:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)valueScrollView
{
//    NSLog(@"scrollView tag == %lu", valueScrollView.tag);
    
    
    // Basically, you're calculating the center point of a button based on its distance from the center of its
    // parent content view based on the distance from the center of the scroll view (same as content view?) and the scroll view offset.
    // For example: if a button is 200 points from the center of its parent content view...
    //              ...and the scroll view is offset 400 points from its center...
    //              ...then you +/- 400 points to the parent content view center...
    //              ...then you +/- (new parent content view center +/- button distance of 200 points)
    
//    NSLog(@"self.propertyScrollView.bounds.size.width == %f", CGRectGetWidth(valueScrollView.bounds));
//    NSLog(@"self.propertyContentView.bounds.size.width == %f", CGRectGetWidth(self.propertyContentView.bounds));
//    NSLog(@"button (tag: 1) center == %f", CGRectGetWidth(self.propertyContentView.bounds));
    
    
    switch (valueScrollView.tag) {
        case 0: {
            
            
            for (UIButton * button in self.cameraControlButtons)
            {
                CGFloat offsetDistanceFromScrollViewCenter = valueScrollView.contentOffset.x;
                CGFloat buttonCenterXDefault = [button bounds].size.width * button.tag;
                CGFloat offsetDistanceFromContentViewCenter = CGRectGetMidX(self.propertyContentView.bounds) - buttonCenterXDefault;
                CGFloat buttonCenterXCurrent = CGRectGetMidX(valueScrollView.bounds) + (offsetDistanceFromScrollViewCenter + offsetDistanceFromContentViewCenter);
                CGFloat x = CGRectGetWidth(valueScrollView.bounds) - fabs(offsetDistanceFromScrollViewCenter - buttonCenterXCurrent); //CGRectGetWidth(valueScrollView.bounds) - buttonCenterXCurrent;
                printf("\noffsetDistanceFromScrollViewCenter == %f\n%lu\tbuttonCenterXCurrent == %f\nx == %f\n", offsetDistanceFromScrollViewCenter, button.tag, buttonCenterXCurrent, x);
                // 0 == 100% size; 2 * buttonCenterX == 25% reduction in size
                // scale(float old_value, float old_min, float old_max, float new_min, float new_max)
                CGFloat normalized_x = fabs(normalize(x, 0.0, CGRectGetWidth(valueScrollView.bounds))); //, 10.5, 40.0));
                printf("\nnormalized_x == %f\n", normalized_x);
                CGFloat repointSize = 42.0 - (42.0 * normalized_x);
                UIImage * resizedImage = [button.currentImage imageByApplyingSymbolConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:repointSize]];
                [button setImage:resizedImage forState:UIControlStateNormal];
            }
            break;
        }
         
        case 1: {
            if ((valueScrollView.isDragging || valueScrollView.isTracking || valueScrollView.isDecelerating))
            {
                configureCameraProperty(valueScrollView.contentOffset.x);
            }
            break;
        }
        default:
            break;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)valueScrollView
{
    [captureDevice unlockForConfiguration];
}

@end

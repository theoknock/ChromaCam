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
    
    [self.propertyScrollView setDecelerationRate:UIScrollViewDecelerationRateFast];
    
    //    [self.propertyContentView.layer setBorderColor:[UIColor redColor].CGColor];
    //    [self.propertyContentView.layer setBorderWidth:2.0];
    //    printf("self.propertyContentView.layer.bounds.size.width == % f", self.propertyContentView.layer.bounds.size.width);
}

- (IBAction)setCameraProperty:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            [self.valueScrollView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [captureDevice unlockForConfiguration];
        }];
        
        CGPoint scrollViewContentOffset = CGPointMake([(UIButton *)sender bounds].size.width * [sender tag], self.propertyScrollView.contentOffset.y);
        [self.propertyScrollView setContentOffset:scrollViewContentOffset animated:TRUE];
        
        CGFloat scrollViewCenterX = CGRectGetWidth(self.propertyScrollView.bounds);
        
        for (UIButton * button in self.cameraControlButtons)
        {
            [button setSelected:FALSE];
            [button setHighlighted:FALSE];
            
            //            float button_alpha = (float)((100.0 - (labs(((UIButton *)sender).tag - button.tag) * 25.0)) / 100.0);
            //            printf("button_alpha == %f", button_alpha);
            //            [button setAlpha:button_alpha];
            //
            //            CGFloat buttonCenterXOffset = fabs(([button bounds].size.width * (self.cameraControlButtons.count / 2)) - ([button bounds].size.width * button.tag)); // + ([button bounds].size.width / 2.0);
            //            printf("\n\n-------------\ntag == %lu\t\tbuttonCenterXOffset == %f\n------%f-------\n", button.tag, buttonCenterXOffset, self.propertyScrollView.contentOffset.x /*[button bounds].size.width * 4*/);
            //            CGFloat differenceCenterX = fabs(buttonCenterX - scrollViewCenterX);
            // 0 == 100% size; 2 * buttonCenterX == 25% reduction in size
            // scale(float old_value, float old_min, float old_max, float new_min, float new_max)
            //            CGFloat resize = fabs(scale(differenceCenterX, 0.0, differenceCenterXMax, 42.0, 10.5));
            //            NSLog(@"resize % == %f", resize);
            //            [button invalidateIntrinsicContentSize];
            //            UIImage * resizedImage = [button.currentImage imageByApplyingSymbolConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:resize]];
            //            [button setImage:resizedImage forState:UIControlStateNormal];
        }
        //        printf("\nself.propertyScrollView.contentOffset.x == %f\n", self.propertyScrollView.contentOffset.x);
        
        [(UIButton *)sender setSelected:TRUE];
        [(UIButton *)sender setHighlighted:TRUE];
        
        
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
        
        [UIView animateWithDuration:0.5 animations:^{
            [self.valueScrollView setAlpha:1.0];
        } completion:^(BOOL finished) {
            [captureDevice lockForConfiguration:nil];
        }];
    });
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [captureDevice lockForConfiguration:nil];
//    switch (scrollView.tag) {
//        case 0: {
//            [UIView animateWithDuration:0.25 animations:^{
//                [self.valueScrollView setAlpha:0.0];
//            }];
//            
//            break;
//        }
//            
//        case 1: {
//            [captureDevice lockForConfiguration:nil];
//            break;
//        }
//            
//        default:
//            break;
//    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    switch (scrollView.tag) {
            //        case 0: {
            //
            //
            //            for (UIButton * button in self.cameraControlButtons)
            //            {
            //                CGFloat offsetDistanceFromScrollViewCenter = scrollView.contentOffset.x;
            //                CGFloat buttonCenterXDefault = [button bounds].size.width * button.tag;
            //                CGFloat offsetDistanceFromContentViewCenter = CGRectGetMidX(self.propertyContentView.bounds) - buttonCenterXDefault;
            //                CGFloat buttonCenterXCurrent = CGRectGetMidX(scrollView.bounds) + (offsetDistanceFromScrollViewCenter + offsetDistanceFromContentViewCenter);
            //                CGFloat x = CGRectGetWidth(scrollView.bounds) - fabs(offsetDistanceFromScrollViewCenter - buttonCenterXCurrent);
            //                CGFloat normalized_x = fabs(normalize(x, 0.0, CGRectGetMaxX(scrollView.bounds)));
            //                CGFloat repointSize = (1.0 - fabs(0.801932 - normalized_x)) * 42.0;
            ////                printf("\noffsetDistanceFromScrollViewCenter == %f\n%lu\tbuttonCenterXCurrent == %f\nx == %f\n", offsetDistanceFromScrollViewCenter, button.tag, buttonCenterXCurrent, x);
            ////                printf("\nnormalized_x == %f\n", normalized_x);
            ////                printf("\nrepointSize == %f\n", repointSize);
            //                UIImage * resizedImage = [button.currentImage imageByApplyingSymbolConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:repointSize]];
            //                [button setImage:resizedImage forState:UIControlStateNormal];
            //
            //            }
            //            break;
            //        }
            
        case 1: {
            if ((scrollView.isDragging || scrollView.isTracking || scrollView.isDecelerating))
            {
                configureCameraProperty(scrollView.contentOffset.x);
            }
            break;
        }
        default:
            break;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    switch (scrollView.tag) {
        case 0: {
            CGFloat nearest_button_tag = (scrollView.contentOffset.x / 82.0);
            printf("nearest_button_tag %f\n", nearest_button_tag);
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterNoStyle];
            [formatter setMaximumFractionDigits:0];
            [formatter setRoundingMode: NSNumberFormatterRoundHalfEven];
            NSString * rounded_nearest_button_tag_str = [formatter stringFromNumber:[NSNumber numberWithFloat:nearest_button_tag]];
            NSLog(@"rounded_nearest_button_tag %@\n", rounded_nearest_button_tag_str);
            
            NSInteger rounded_nearest_button_tag = [rounded_nearest_button_tag_str integerValue];
            CGPoint scrollViewContentOffset = CGPointMake(82.0 * rounded_nearest_button_tag, self.propertyScrollView.contentOffset.y);
            [self.propertyScrollView setContentOffset:scrollViewContentOffset animated:TRUE];
            
            for (UIButton * button in self.cameraControlButtons) {
                if (button.tag == rounded_nearest_button_tag) {
                    [self setCameraProperty:button];
                    break;
                }
            }
            break;
        }
            
        case 1: {
            [captureDevice unlockForConfiguration];
            break;
        }
            
        default:
            break;
    }
}



@end

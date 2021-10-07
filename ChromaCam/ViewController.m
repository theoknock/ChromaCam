//
//  ViewController.m
//  ChromaCam
//
//  Created by Xcode Developer on 9/25/21.
//

#import "ViewController.h"
#import "CaptureSessionConfigurationQueue.h"

static float normalize(float value, float min, float max) {
    return (value - min) / (max - min);
}

static float scale(float old_value, float old_min, float old_max, float new_min, float new_max) {
    return (new_max - new_min) * (fmax(old_min, fmin(old_value, old_max)) - old_min) / (old_max - old_min) + new_min;
}

typedef enum : NSUInteger {
    CaptureDeviceConfigurationControlPropertyTorchLevel,
    CaptureDeviceConfigurationControlPropertyLensPosition,
    CaptureDeviceConfigurationControlPropertyExposureDuration,
    CaptureDeviceConfigurationControlPropertyISO,
    CaptureDeviceConfigurationControlPropertyZoomFactor
} CaptureDeviceConfigurationControlProperty;

typedef enum : NSUInteger {
    CaptureDeviceConfigurationControlValueTorchLevel,
    CaptureDeviceConfigurationControlValueLensPosition,
    CaptureDeviceConfigurationControlValueExposureDuration,
    CaptureDeviceConfigurationControlValueISO,
    CaptureDeviceConfigurationControlValueZoomFactor
} CaptureDeviceConfigurationControlValue;

typedef enum : NSUInteger {
    CaptureDeviceConfigurationControlTypeProperty,
    CaptureDeviceConfigurationControlTypeValue
} CaptureDeviceConfigurationControlType;

typedef enum : NSUInteger {
    CaptureDeviceConfigurationControlPropertyFocusCurrent,
    CaptureDeviceConfigurationControlPropertyFocusNearest,
    CaptureDeviceConfigurationControlPropertyFocusNext
} CaptureDeviceConfigurationControlPropertyFocus;

static CaptureDeviceConfigurationControlProperty (^CaptureDeviceConfigurationPropertyControlFocusTarget)(UIScrollView *, UIStackView *, CGFloat) = ^ CaptureDeviceConfigurationControlProperty (UIScrollView * control_view_parent, UIStackView * control_view, CGFloat control_view_parent_target_offset) {
//    float scaled_control_view_parent_content_offset = scale(control_view_parent.contentOffset.x, 0.0, control_view_parent.contentSize.width, 0.0, control_view.bounds.size.width);
    float button_center_width = control_view_parent.bounds.size.width / control_view.subviews.count;
    float center_button_tag   = control_view_parent.contentOffset.x / button_center_width;
    CGFloat button_center_position_x_scaled = scale(center_button_tag, 0.0, control_view_parent.bounds.size.width, 0.0, control_view.bounds.size.width);
    CaptureDeviceConfigurationControlProperty target_control_property = (control_view_parent.contentOffset.x >= control_view_parent_target_offset) ? ceil(button_center_position_x_scaled) : floor(button_center_position_x_scaled);
    
    return target_control_property;
};

static CGPoint (^CaptureDeviceConfigurationPropertyControlPosition)(UIScrollView *, UIStackView *, CaptureDeviceConfigurationControlProperty) = ^ CGPoint (UIScrollView * control_view_parent, UIStackView * control_view, CaptureDeviceConfigurationControlProperty control_property) {
    CGFloat button_center_width             = control_view.bounds.size.width / control_view.subviews.count;
    CGFloat button_center_position_x        = button_center_width * control_property;
    CGFloat button_center_position_x_scaled = scale(button_center_position_x, 0.0, control_view.bounds.size.width, 0.0, control_view_parent.contentSize.width);
    CGPoint button_center_position_point    = CGPointMake(button_center_position_x_scaled, control_view_parent.contentOffset.x);
    
    return button_center_position_point;
};

@interface ViewController ()
{
    AVCaptureSession     * captureSession;
    AVCaptureDevice      * captureDevice;
    AVCaptureDeviceInput * captureInput;
    AVCaptureConnection  * captureConnection;
    
    void (^configureCameraProperty)(float);
}

@end

@implementation ViewController

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
}

- (IBAction)setCameraProperty:(id)sender {
    CaptureDeviceConfigurationControlProperty sender_control_property = (CaptureDeviceConfigurationControlProperty)((UIButton *)sender).tag;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.valueScrollView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [captureDevice unlockForConfiguration];
        
        void(^cameraPropertyConfiguration)(float) = nil;
        switch (sender_control_property) {
            case CaptureDeviceConfigurationControlPropertyTorchLevel: {
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
            case CaptureDeviceConfigurationControlPropertyLensPosition: {
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
            case CaptureDeviceConfigurationControlPropertyExposureDuration: {
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
            case CaptureDeviceConfigurationControlPropertyISO: {
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
            case CaptureDeviceConfigurationControlPropertyZoomFactor: {
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
        
        [UIView animateWithDuration:0.25 animations:^{
            [self.valueScrollView setAlpha:1.0];
            for (UIButton * button in self.cameraControlButtons)
            {
                BOOL select_highlight_state = ((button.tag == sender_control_property) ? TRUE : FALSE);
                [button setSelected:select_highlight_state];
                [button setHighlighted:select_highlight_state];
            }
        } completion:^(BOOL finished) {
            [captureDevice lockForConfiguration:nil];
        }];
    }];
    
//        CGPoint scrollViewContentOffset = CGPointMake([(UIButton *)sender bounds].size.width * sender_control_property, self.propertyScrollView.contentOffset.y);
//        [self.propertyScrollView setContentOffset:scrollViewContentOffset animated:TRUE];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    switch (scrollView.tag) {
        case CaptureDeviceConfigurationControlTypeProperty: {
            if ((scrollView.isDragging || scrollView.isTracking || scrollView.isDecelerating))
            {
                CaptureDeviceConfigurationControlProperty control_property = CaptureDeviceConfigurationPropertyControlFocusTarget(scrollView, (UIStackView *)((scrollView.subviews.firstObject).subviews.firstObject), scrollView.contentOffset.x);
                for (UIButton * button in (NSArray<UIButton *> *)[((scrollView.subviews.firstObject).subviews.firstObject) subviews])
                {
                    [button setHighlighted:(button.tag == control_property)];
                }
            }
            break;
        }
        case CaptureDeviceConfigurationControlTypeValue: {
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

//static NSInteger (^roundFloatToIntHalfEven)(CGFloat float_value) = ^ NSInteger (CGFloat float_value) {
//    NSNumberFormatter *formatter = [NSNumberFormatter new];
//    [formatter setNumberStyle:NSNumberFormatterNoStyle];
//    [formatter setRoundingMode: NSNumberFormatterRoundHalfEven];
//    return [[formatter stringFromNumber:[NSNumber numberWithFloat:float_value]] integerValue];
//};

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // targetContentOffset tells you which direction the scrollview is scrolling when compared against
    // the scrollview contentOffset x-position
    // Once the target control position is calculated, then the targetContentOffset property can be updated with it
    
    switch (scrollView.tag) {
        case 0: {
            CaptureDeviceConfigurationControlProperty control_property = CaptureDeviceConfigurationPropertyControlFocusTarget(scrollView, (UIStackView *)((scrollView.subviews.firstObject).subviews.firstObject), targetContentOffset->x);
            printf("\n%lu\tcurrent offset == %f\n", control_property, scrollView.contentOffset.x);
            printf("\n%lu\ttarget offset == %f\n", control_property, targetContentOffset->x);
            *targetContentOffset = CaptureDeviceConfigurationPropertyControlPosition(scrollView, (UIStackView *)((scrollView.subviews.firstObject).subviews.firstObject), control_property);
//            [self.propertyScrollView setContentOffset:CaptureDeviceConfigurationPropertyControlPosition(scrollView, (UIStackView *)((scrollView.subviews.firstObject).subviews.firstObject), control_property) animated:TRUE];
//            [self setCameraProperty:(UIButton *)[self.propertyButtonsStackView viewWithTag:control_property]];
            printf("\n%lu\ttarget offset == %f\n", control_property, targetContentOffset->x);
            printf("\n------------------------------------\n");
            break;
        }
            
        default:
            break;
    }
}

@end

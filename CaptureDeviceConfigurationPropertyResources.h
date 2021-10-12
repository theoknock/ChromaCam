//
//  CaptureDeviceConfigurationPropertyResources.h
//  ChromaCam
//
//  Created by Xcode Developer on 10/9/21.
//

#ifndef CaptureDeviceConfigurationPropertyResources_h
#define CaptureDeviceConfigurationPropertyResources_h

#define ITEM_SIZE 70

static float normalize(float value, float min, float max) {
    return (value - min) / (max - min);
}

static float scale(float old_value, float old_min, float old_max, float new_min, float new_max) {
    return (new_max - new_min) * (fmax(old_min, fmin(old_value, old_max)) - old_min) / (old_max - old_min) + new_min;
}

typedef enum : NSUInteger {
    CaptureDeviceConfigurationControlTypePropertyHorizontalOnly,
    CaptureDeviceConfigurationControlTypeValueScrollView,
    CaptureDeviceConfigurationControlTypePropertyRadial
} CaptureDeviceConfigurationControlType;

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

static NSString * (^ImageForCaptureDeviceConfigurationControlProperty)(CaptureDeviceConfigurationControlProperty) = ^ NSString * (CaptureDeviceConfigurationControlProperty control_property) {
    switch (control_property) {
        case CaptureDeviceConfigurationControlPropertyTorchLevel: {
            return @"bolt.circle";
            break;
        }
        case CaptureDeviceConfigurationControlPropertyLensPosition: {
            return @"viewfinder.circle";
            break;
        }
        case CaptureDeviceConfigurationControlPropertyExposureDuration: {
            return @"timer";
            break;
        }
        case CaptureDeviceConfigurationControlPropertyISO: {
            return @"camera.aperture";
            break;
        }
        case CaptureDeviceConfigurationControlPropertyZoomFactor: {
            return @"magnifyingglass.circle";
            break;
        }
        default:
            return @"questionmark.circle";
            break;
    }
};

//static void(^ConfigurationforCaptureDeviceProperty)(CaptureDeviceConfigurationControlProperty) = ^ NSString * (CaptureDeviceConfigurationControlProperty control_property) {
//
//                                                    [self setUserInteractionEnabled:TRUE];
//                                                    [self addEventHandler:^(CaptureDeviceConfigurationPropertyReusableButton * sender) {
//                                                        CaptureDeviceConfigurationControlProperty sender_control_property = (CaptureDeviceConfigurationControlProperty)sender.tag;
//
//
//                                                        [UIView animateWithDuration:0.25 animations:^{
//                                                            [self.valueControl setAlpha:0.0];
//
//                                                    //        for (CaptureDeviceConfigurationControlProperty control_property = CaptureDeviceConfigurationControlPropertyTorchLevel; control_property <= CaptureDeviceConfigurationControlPropertyZoomFactor; control_property++) {
//                                                    //            BOOL changeState = (sender_control_property == control_property);
//                                                    //            [ButtonForCaptureDeviceConfigurationControlProperty(control_property) setSelected:changeState];
//                                                    //            [ButtonForCaptureDeviceConfigurationControlProperty(control_property) setHighlighted:changeState];
//                                                    //        }
//
//                                            //                [ButtonForCaptureDeviceConfigurationControlProperty(CaptureDeviceConfigurationControlPropertyTorchLevel) setSelected:TRUE];
//                                            //                [ButtonForCaptureDeviceConfigurationControlProperty(CaptureDeviceConfigurationControlPropertyTorchLevel) setHighlighted:TRUE];
//
//                                                    //        NSIndexPath * selectedIndexPath = [NSIndexPath indexPathForItem:CaptureDeviceConfigurationControlPropertyTorchLevel inSection:0];
//                                                    //        [(PropertyCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:selectedIndexPath] setCaptureDeviceConfigurationPropertyButtonActiveState:FALSE];
//
//
//
//                                                        } completion:^(BOOL finished) {
//                                                            [captureDevice unlockForConfiguration];
//
//                                                            void(^cameraPropertyConfiguration)(float) = nil;
//                                                            switch (sender_control_property) {
//                                                                case CaptureDeviceConfigurationControlPropertyTorchLevel: {
//                                                                    cameraPropertyConfiguration = ^ (UIScrollView * valueScrollView, AVCaptureDevice * cd, float old_value, float old_min, float old_max) {
//                                                                        CGPoint scrollViewContentOffset = CGPointMake(old_value * CGRectGetWidth(valueScrollView.bounds), valueScrollView.contentOffset.y);
//                                                                        [valueScrollView setContentOffset:scrollViewContentOffset animated:TRUE];
//
//                                                                        return ^ void (float offset) {
//                                                                            float new_value = MAX(old_min, MIN(scale(offset, 0.0, CGRectGetWidth(valueScrollView.bounds), old_min, old_max), old_max));
//                                                                            if (new_value != 0.0 && ([[NSProcessInfo processInfo] thermalState] != NSProcessInfoThermalStateCritical && [[NSProcessInfo processInfo] thermalState] != NSProcessInfoThermalStateSerious))
//                                                                                [cd setTorchModeOnWithLevel:new_value error:nil];
//                                                                            else
//                                                                                [cd setTorchMode:AVCaptureTorchModeOff];
//
//                                                                            [(ValueScrollViewContentViewLayerContent *)self.valueContentView.layer setValue:normalize(new_value, old_min, old_max)];
//                                                                        };
//                                                                    }(self.valueScrollView, captureDevice, [captureDevice torchLevel], 0.0, 1.0);
//                                                                    break;
//                                                                }
//                                                                case CaptureDeviceConfigurationControlPropertyLensPosition: {
//                                                                    cameraPropertyConfiguration = ^ (UIScrollView * valueScrollView, AVCaptureDevice * cd, float old_value, float old_min, float old_max) {
//                                                                        CGPoint scrollViewContentOffset = CGPointMake(old_value * CGRectGetWidth(valueScrollView.bounds), valueScrollView.contentOffset.y);
//                                                                        [valueScrollView setContentOffset:scrollViewContentOffset animated:TRUE];
//
//                                                                        return ^ void (float offset) {
//                                                                            float new_value = MAX(old_min, MIN(scale(offset, 0.0, CGRectGetWidth(valueScrollView.bounds), old_min, old_max), old_max));
//                                                                            [cd setFocusModeLockedWithLensPosition:new_value completionHandler:nil];
//                                                                            [(ValueScrollViewContentViewLayerContent *)self.valueContentView.layer setValue:normalize(new_value, old_min, old_max)];
//                                                                        };
//                                                                    }(self.valueScrollView, captureDevice, captureDevice.lensPosition, 0.0, 1.0);
//                                                                    break;
//                                                                }
//                                                                case CaptureDeviceConfigurationControlPropertyExposureDuration: {
//                                                                    cameraPropertyConfiguration = ^ (UIScrollView * valueScrollView, AVCaptureDevice * cd, float old_value, float old_min, float old_max) {
//                                                                        float normalized_value = normalize(old_value, old_min, old_max);
//                                                                        float offset_value     = normalized_value * CGRectGetWidth(valueScrollView.bounds);
//                                                                        CGPoint scrollViewContentOffset = CGPointMake(offset_value, valueScrollView.contentOffset.y);
//                                                                        [valueScrollView setContentOffset:scrollViewContentOffset animated:TRUE];
//
//                                                                        return ^ void (float offset) {
//                                                                            float new_value = MAX(old_min, MIN(scale(offset, 0.0, CGRectGetWidth(valueScrollView.bounds), old_min, old_max), old_max));
//                                                                            CMTime exposureDurationValue = CMTimeMakeWithSeconds(new_value, 1000*1000*1000);
//                                                                            [cd setExposureModeCustomWithDuration:exposureDurationValue ISO:AVCaptureISOCurrent completionHandler:nil];
//
//                                                                            [(ValueScrollViewContentViewLayerContent *)self.valueContentView.layer setValue:normalize(new_value, old_min, old_max)];
//                                                                        };
//                                                                    }(self.valueScrollView, captureDevice, CMTimeGetSeconds([captureDevice exposureDuration]), CMTimeGetSeconds(captureDevice.activeFormat.minExposureDuration), 1.0/3.0);
//                                                                    break;
//                                                                }
//                                                                case CaptureDeviceConfigurationControlPropertyISO: {
//                                                                    cameraPropertyConfiguration = ^ (UIScrollView * valueScrollView, AVCaptureDevice * cd, float old_value, float old_min, float old_max) {
//                                                                        float normalized_value = normalize(old_value, old_min, old_max);
//                                                                        float offset_value     = normalized_value * CGRectGetWidth(valueScrollView.bounds);
//                                                                        CGPoint scrollViewContentOffset = CGPointMake(offset_value, valueScrollView.contentOffset.y);
//                                                                        [valueScrollView setContentOffset:scrollViewContentOffset animated:TRUE];
//
//                                                                        return ^ void (float offset) {
//                                                                            float new_value = MAX(old_min, MIN(scale(offset, 0.0, CGRectGetWidth(valueScrollView.bounds), old_min, old_max), old_max));
//                                                                            [cd setExposureModeCustomWithDuration:captureDevice.exposureDuration ISO:new_value completionHandler:nil];
//
//                                                                            [(ValueScrollViewContentViewLayerContent *)self.valueContentView.layer setValue:normalize(new_value, old_min, old_max)];
//                                                                        };
//                                                                    }(self.valueScrollView, captureDevice, captureDevice.ISO, captureDevice.activeFormat.minISO, captureDevice.activeFormat.maxISO);
//                                                                    break;
//                                                                }
//                                                                case CaptureDeviceConfigurationControlPropertyZoomFactor: {
//                                                                    cameraPropertyConfiguration = ^(UIScrollView * valueScrollView, AVCaptureDevice * cd, float old_value, float old_min, float old_max) {
//                                                                        float normalized_value = normalize(old_value, old_min, old_max);
//                                                                        float offset_value     = normalized_value * CGRectGetWidth(valueScrollView.bounds);
//                                                                        CGPoint scrollViewContentOffset = CGPointMake(offset_value, valueScrollView.contentOffset.y);
//                                                                        [valueScrollView setContentOffset:scrollViewContentOffset animated:TRUE];
//
//                                                                        return ^ void (float offset) {
//                                                                            float new_value = MAX(old_min, MIN(scale(offset, 0.0, CGRectGetWidth(valueScrollView.bounds), old_min, old_max), old_max));
//                                                                            [cd setVideoZoomFactor:new_value];
//
//                                                                            [(ValueScrollViewContentViewLayerContent *)self.valueContentView.layer setValue:normalize(new_value, old_min, old_max)];
//                                                                        };
//                                                                    }(self.valueScrollView, captureDevice, captureDevice.videoZoomFactor, captureDevice.minAvailableVideoZoomFactor, captureDevice.maxAvailableVideoZoomFactor);
//                                                                    break;
//                                                                }
//                                                                default:
//                                                                    break;
//                                                            }
//
//                                                            configureCameraProperty = ^ (void(^cameraPropertySetter)(float)) {
//                                                                return ^ void (float x) {
//                                                                    dispatch_async(capture_session_configuration_queue_ref(), ^{
//                                                                        cameraPropertySetter(x);
//                                                                    });
//                                                                };
//                                                            }(cameraPropertyConfiguration);
//
//                                                            [UIView animateWithDuration:0.25 animations:^{
//                                                                [self.valueScrollView setAlpha:1.0];
//
//                                                            } completion:^(BOOL finished) {
//                                                                [captureDevice lockForConfiguration:nil];
//                                                            }];
//                                                        }];
//                                                    }  forControlEvents:UIControlEventAllEvents];)


#endif /* CaptureDeviceConfigurationPropertyResources_h */

//
//  ViewController.m
//  ChromaCam
//
//  Created by Xcode Developer on 9/25/21.
//

#import "ViewController.h"
#import "CaptureSessionConfigurationQueue.h"
#import "CoverLayout.h"

static float normalize(float value, float min, float max) {
    return (value - min) / (max - min);
}

static float scale(float old_value, float old_min, float old_max, float new_min, float new_max) {
    return (new_max - new_min) * (fmax(old_min, fmin(old_value, old_max)) - old_min) / (old_max - old_min) + new_min;
}

typedef enum : NSUInteger {
    CaptureDeviceConfigurationControlTypeProperty,
    CaptureDeviceConfigurationControlTypeValue,
    CaptureDeviceConfigurationControlTypeControlImage
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

typedef enum : NSUInteger {
    CaptureDeviceConfigurationControlPropertyFocusCurrent,
    CaptureDeviceConfigurationControlPropertyFocusNearest,
    CaptureDeviceConfigurationControlPropertyFocusNext
} CaptureDeviceConfigurationControlPropertyFocus;

typedef enum : NSUInteger {
    CaptureDeviceConfigurationControlCenterOffsetDirectionRight,
    CaptureDeviceConfigurationControlCenterOffsetDirectionLeft,
    CaptureDeviceConfigurationControlCenterOffsetDirectionNone
} CaptureDeviceConfigurationControlCenterOffsetDirection;

typedef enum : NSUInteger {
    CaptureDeviceConfigurationControlHorizontalScrollingDirectionRight,
    CaptureDeviceConfigurationControlHorizontalScrollingDirectionLeft,
    CaptureDeviceConfigurationControlHorizontalScrollingDirectionNone
} CaptureDeviceConfigurationControlHorizontalScrollingDirection;

@interface ViewController ()
{
    AVCaptureSession     * captureSession;
    AVCaptureDevice      * captureDevice;
    AVCaptureDeviceInput * captureInput;
    AVCaptureConnection  * captureConnection;
    
    void(^configureCameraProperty)(float);
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
    
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return 5;
}

//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
//
//
//    return cell;
//}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(collectionView.bounds.size.width/3, collectionView.bounds.size.height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    
    
    //((UICollectionViewFlowLayout *)collectionViewLayout).itemSize
    
//    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
//    CGFloat leftInsetValue = (collectionView.frame.size.width - flowLayout.itemSize.width)/2.0f;
    CGFloat leftInsetValue = (self.collectionView.frame.size.width - self.cellLayout.itemSize.width) / 2.0f;
    UIEdgeInsets inset = UIEdgeInsetsMake(0, leftInsetValue, 0, leftInsetValue);
    
    return inset;
}


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

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCellReuseID" forIndexPath:indexPath];
    UIButton * property_control_button = (UIButton *)cell.contentView.subviews.firstObject;
    [property_control_button setTag:indexPath.item];
    UIImage * button_image = [UIImage systemImageNamed:ImageForCaptureDeviceConfigurationControlProperty(property_control_button.tag)];
    [property_control_button setImage:button_image forState:UIControlStateNormal];
    
    return cell;
}

- (IBAction)configureCaptureDeviceProperty:(UIButton *)sender forEvent:(UIEvent *)event {
    CaptureDeviceConfigurationControlProperty sender_control_property = (CaptureDeviceConfigurationControlProperty)sender.tag;
    
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
            
        } completion:^(BOOL finished) {
            [captureDevice lockForConfiguration:nil];
        }];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == CaptureDeviceConfigurationControlTypeValue)
        if ((scrollView.isDragging || scrollView.isTracking || scrollView.isDecelerating))
            configureCameraProperty(scrollView.contentOffset.x);
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    switch (scrollView.tag) {
//        case CaptureDeviceConfigurationControlTypeProperty: {
//            __block CGFloat content_offset_x_last = scrollView.contentOffset.x;
//            scrollViewDirection = ^ void (CGFloat content_offset_x_current) {
//                CaptureDeviceConfigurationControlHorizontalScrollingDirection scrolling_direction = (content_offset_x_current == content_offset_x_last) ? CaptureDeviceConfigurationControlHorizontalScrollingDirectionNone : (content_offset_x_current > content_offset_x_last) ? CaptureDeviceConfigurationControlHorizontalScrollingDirectionLeft : CaptureDeviceConfigurationControlHorizontalScrollingDirectionRight;
//                if (scrolling_direction != CaptureDeviceConfigurationControlHorizontalScrollingDirectionNone) {
//                    CaptureDeviceConfigurationControlProperty control_property_select   = 0;
//                    CaptureDeviceConfigurationControlProperty control_property_deselect = 0;
//                    CaptureDeviceConfigurationPropertyControlFocusTarget(scrollView, (UIStackView *)((scrollView.subviews.firstObject).subviews.firstObject), scrolling_direction, &control_property_select, &control_property_deselect);
//
//                    UIButton * last_button = [self.cameraControlButtons objectAtIndex:control_property_deselect];
//                    [last_button setSelected:FALSE];
//                    [last_button setHighlighted:FALSE];
//
//                    UIButton * current_button = [self.cameraControlButtons objectAtIndex:control_property_select];
//                    [current_button setSelected:TRUE];
//                    [current_button setHighlighted:TRUE];
//                }
//            };
//            break;
//        }
//        default:
//            break;
//    }
//}
//
//static const CGFloat (^captureDeviceConfigurationControlTransform)(CGFloat, CGFloat, CGFloat, CGFloat) = ^ CGFloat (CGFloat content_offset_x, CGFloat content_size_width, CGFloat button_index, CGFloat button_count) {
//    CGFloat n = normalize(content_offset_x, 0.0, content_size_width); // check to see if midpoint of content_size_width is 0.5 when normalized
//    CGFloat v = 0.5625;
//    CGFloat x = normalize(((content_size_width / button_count) * button_index), 0.0, content_size_width); // x is the point along the curve where a button's midpoint lies
//    CGFloat control_height = exp(-( (pow(x - n, 2.0)) / (pow(v, 2.0)) ));
//
//    return control_height;
//};
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if ((scrollView.isDragging || scrollView.isTracking || scrollView.isDecelerating))
//    {
//        switch (scrollView.tag) {
//            case CaptureDeviceConfigurationControlTypeProperty: {
//                for (UIButton * button in self.cameraControlButtons) {
//                    CGFloat y = captureDeviceConfigurationControlTransform(scrollView.contentOffset.x, scrollView.bounds.size.width, button.tag, 5.0);
//                    CGFloat resize = y * scrollView.bounds.size.height;
//                    UIImage * resizedImage = [button.currentImage imageByApplyingSymbolConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:resize]];
//                    [button setImage:resizedImage forState:UIControlStateNormal];
//                    [button setAlpha:y/1.1];
//                }
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    scrollViewDirection(fmaxf(0.0, fminf(scrollView.contentOffset.x, scrollView.bounds.size.width)));
//                });
//
//                break;
//            }
//
//            case CaptureDeviceConfigurationControlTypeValue: {
//                configureCameraProperty(scrollView.contentOffset.x);
//
//                break;
//            }
//
//            default:
//                break;
//        }
//    }
//}
//
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    //    switch (scrollView.tag) {
//    //        case 0: {
//    //            CaptureDeviceConfigurationControlProperty control_property = CaptureDeviceConfigurationPropertyControlFocusTarget(scrollView, (UIStackView *)((scrollView.subviews.firstObject).subviews.firstObject), targetContentOffset->x);
//    //            printf("\n%lu\tcurrent offset == %f\n", control_property, scrollView.contentOffset.x);
//    //            printf("\n%lu\ttarget offset == %f\n", control_property, targetContentOffset->x);
//    //            *targetContentOffset = CaptureDeviceConfigurationPropertyControlPosition(scrollView, (UIStackView *)((scrollView.subviews.firstObject).subviews.firstObject), control_property);
//    //            printf("\n%lu\ttarget offset == %f\n", control_property, targetContentOffset->x);
//    //            printf("\n------------------------------------\n");
//    //
//    //            //            [self setCameraProperty:(UIButton *)[self.propertyButtonsStackView viewWithTag:control_property]];
//    //
//    //            break;
//    //        }
//    //
//    //        default:
//    //            break;
//    //    }
//}

@end

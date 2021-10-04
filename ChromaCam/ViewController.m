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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.cameraControlButtons.count;
}

// Maybe To-Do: Replace by getting the image from the subview (UIButton) of the stack view with the same tag as the indexPath.item
static UIImage * (^cameraControlButtonImage)(NSInteger) = ^ UIImage * (NSInteger tag) {
    NSString * systemImageName = nil;
    switch (tag) {
        case CaptureDevicePropertyTorchLevel:
            systemImageName = @"bolt.circle";
            break;
        case CaptureDevicePropertyLensPosition:
            systemImageName = @"viewfinder.circle";
            break;
        case CaptureDevicePropertyExposureDuration:
            systemImageName = @"timer";
            break;
        case CaptureDevicePropertyISO:
            systemImageName = @"camera.aperture";
            break;
        case CaptureDevicePropertyZoomFactor:
            systemImageName = @"magnifyingglass.circle";
            break;
        
        default:
            break;
    }
    
    UIImage * backgroundImage = [UIImage systemImageNamed:systemImageName withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:42.0]];;
    
    return backgroundImage;
};

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CameraControlCellReuseID" forIndexPath:indexPath];

    UIButton * cameraControlButton = (UIButton *)[[cell.contentView subviews] firstObject];
    [cameraControlButton setFrame:cell.contentView.bounds];
    [cameraControlButton setTag:indexPath.item];
    [cameraControlButton setImage:cameraControlButtonImage(indexPath.item) forState:UIControlStateNormal];
    [cameraControlButton addTarget:self action:@selector(setCameraProperty:) forControlEvents:UIControlEventAllEvents];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIButton * cameraControlButton = (UIButton *)[[cell.contentView subviews] firstObject];
    [cameraControlButton setTag:indexPath.item];
    [self setCameraProperty:cameraControlButton];
}

// UICollectionView To-Do:
//          1.    When a cell is no longer centered, deselect and unhighlight the button
//          2.    Center a cell when selected or scrolling towards the center while not dragging or tracking; select and highlight its button
//          3.    Set horizontal content inset so all cells can be centered when selected
//          4.    Evenly space and center cells

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
    
    [self setCameraProperty:self.lensPositionButton];
}
- (IBAction)setCameraProperty:(id)sender {
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
            case CaptureDevicePropertyTorchLevel: {
                cameraPropertyConfiguration = ^(UIScrollView * scrollView, AVCaptureDevice * cd, float range_min, float range_max, float min_x, float max_x) {
                    
                    float current_value = scale([cd torchLevel], 0.0, CGRectGetWidth(self.scrollView.bounds), 0.0, 1.0);
                    CGPoint scrollViewContentOffset = CGPointMake(current_value, scrollView.contentOffset.y);
                    [scrollView setContentOffset:scrollViewContentOffset animated:TRUE];
                    
                    return ^ void (float x) {
                        float value = MAX(range_min, MIN(scale(x, range_min, range_max, min_x, max_x), range_max));
                        if (value != 0.0 && ([[NSProcessInfo processInfo] thermalState] != NSProcessInfoThermalStateCritical && [[NSProcessInfo processInfo] thermalState] != NSProcessInfoThermalStateSerious))
                            [cd setTorchModeOnWithLevel:value error:nil];
                        else
                            [cd setTorchMode:AVCaptureTorchModeOff];
                    };
                }(self.scrollView, captureDevice, 0.0, 1.0, 0.0, CGRectGetWidth(self.scrollView.bounds));
                break;
            }
            case CaptureDevicePropertyLensPosition: {
                cameraPropertyConfiguration = ^(UIScrollView * scrollView, AVCaptureDevice * cd, float range_min, float range_max, float min_x, float max_x) {
                    
                    float current_value = scale([cd lensPosition], 0.0, CGRectGetWidth(self.scrollView.bounds), 0.0, 1.0);
                    CGPoint scrollViewContentOffset = CGPointMake(current_value, scrollView.contentOffset.y);
                    [scrollView setContentOffset:scrollViewContentOffset animated:TRUE];
                    
                    return ^ void (float x) {
                        float value = MAX(range_min, MIN(scale(x, range_min, range_max, min_x, max_x), range_max));
                        [cd setFocusModeLockedWithLensPosition:value completionHandler:nil];
                    };
                }(self.scrollView, captureDevice, 0.0, 1.0, 0.0, CGRectGetWidth(self.scrollView.bounds));
                break;
            }
            case CaptureDevicePropertyExposureDuration: {
                cameraPropertyConfiguration = ^ (UIScrollView * scrollView, AVCaptureDevice * cd, float old_value, float old_min, float old_max) {
                    float normalized_value = normalize(old_value, old_min, old_max);
                    float offset_value     = normalized_value * CGRectGetWidth(scrollView.bounds);
                    CGPoint scrollViewContentOffset = CGPointMake(offset_value, scrollView.contentOffset.y);
                    [scrollView setContentOffset:scrollViewContentOffset animated:TRUE];
                    
                    return ^ void (float offset) {
                        float new_value = MAX(old_min, MIN(scale(offset, 0.0, CGRectGetWidth(scrollView.bounds), old_min, old_max), old_max));
                        CMTime exposureDurationValue = CMTimeMakeWithSeconds(new_value, 1000*1000*1000);
                        [cd setExposureModeCustomWithDuration:exposureDurationValue ISO:captureDevice.ISO completionHandler:nil];
                    };
                }(self.scrollView, captureDevice, CMTimeGetSeconds([captureDevice exposureDuration]), CMTimeGetSeconds(captureDevice.activeFormat.minExposureDuration), 1.0/3.0);
                break;
            }
            case CaptureDevicePropertyISO: {
                cameraPropertyConfiguration = ^ (UIScrollView * scrollView, AVCaptureDevice * cd, float old_value, float old_min, float old_max) {
                    float normalized_value = normalize(old_value, old_min, old_max);
                    float offset_value     = normalized_value * CGRectGetWidth(scrollView.bounds);
                    CGPoint scrollViewContentOffset = CGPointMake(offset_value, scrollView.contentOffset.y);
                    [scrollView setContentOffset:scrollViewContentOffset animated:TRUE];
                    
                    return ^ void (float offset) {
                        float new_value = MAX(old_min, MIN(scale(offset, 0.0, CGRectGetWidth(scrollView.bounds), old_min, old_max), old_max));
                        [cd setExposureModeCustomWithDuration:captureDevice.exposureDuration ISO:new_value completionHandler:nil];
                    };
                }(self.scrollView, captureDevice, captureDevice.ISO, captureDevice.activeFormat.minISO, captureDevice.activeFormat.maxISO);
                break;
            }
            case CaptureDevicePropertyZoomFactor: {
                cameraPropertyConfiguration = ^(AVCaptureDevice * cd, float range_min, float range_max, float min_x, float max_x) {
                    return ^ void (float x) {
                        float value = scale(x, range_min, range_max, min_x, max_x);
                        [cd setVideoZoomFactor:MAX(range_min, MIN(value, range_max))];
                    };
                }(captureDevice, 1.0, captureDevice.activeFormat.videoMaxZoomFactor, 0.0, CGRectGetWidth(self.scrollView.bounds));;
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

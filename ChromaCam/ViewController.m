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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.cameraControlButtons.count;
}

static UIImage * (^cameraControlButtonImage)(NSInteger) = ^ UIImage * (NSInteger tag) {
    NSString * systemImageName = nil;
    switch (tag) {
        case 0:
            systemImageName = @"bolt.circle";
            break;
        case 1:
            systemImageName = @"viewfinder.circle";
            break;
        case 2:
            systemImageName = @"timer";
            break;
        case 3:
            systemImageName = @"camera.aperture";
            break;
        case 4:
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
//    [cell setTag:indexPath.item]; // set the cell's tag to the item number for the index path so it will act like a camera property configuration button when selected

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
- (IBAction)setCameraProperty:(id)sender {
    printf("sender.tag == %lu", ((UIButton *)sender).tag);
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

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
    void (^setZoomFactor)(float);
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
    
    setZoomFactor = ^(AVCaptureDevice * cd, float range_min, float range_max, float min_x, float max_x) {
        return ^ void (float x) {
                float value = normalize(x, range_min, range_max, min_x, max_x);
                [cd setVideoZoomFactor:MAX(range_min, MIN(value, range_max))];
            };
    }(captureDevice, 1.0, captureDevice.activeFormat.videoMaxZoomFactor, 0.0, CGRectGetWidth(self.scrollView.bounds));
}

float normalize(float unscaledNum, float minAllowed, float maxAllowed, float min, float max) {
    return (maxAllowed - minAllowed) * (unscaledNum - min) / (max - min) + minAllowed;
}

typedef void (^SetCameraProperty)(float);



- (IBAction)setCameraProperty:(UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIButton * button in self.cameraControlButtons)
        {
            [button setSelected:FALSE];
            [button setHighlighted:FALSE];
        }
        [(UIButton *)sender setSelected:TRUE ];
        [(UIButton *)sender setHighlighted:TRUE];
        
        NSInteger tag = 2;
        switch (tag) {
            case 2: {
                configureCameraProperty = ^ (SetCameraProperty cameraPropertySetter) {
                    return ^ void (float x) {
                        cameraPropertySetter(x);
                    };
                }(setZoomFactor);
                break;
            }
            default:
                break;
        }
    });
    
    // To-Do: Create a block to configure each camera property; set the constant variables only once
    //        Create a global block property that takes the camera property configuration block associated
    //        with the selected button
    //        Pass the camera property configuration block to the global block property and execute it in scrollViewDidScroll
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [captureDevice lockForConfiguration:nil];
}

static float(^scaleSliderValue)(CGRect, CGFloat, float, float) = ^float(CGRect scrollViewFrame, CGFloat contentOffsetX, float scaleMinimum, float scaleMaximum)
{
    CGFloat frameMinX  = -(CGRectGetMidX(scrollViewFrame));
    CGFloat frameMaxX  =  CGRectGetMaxX(scrollViewFrame) + fabs(CGRectGetMidX(scrollViewFrame));
    contentOffsetX     =  (contentOffsetX < frameMinX) ? frameMinX : ((contentOffsetX > frameMaxX) ? frameMaxX : contentOffsetX);
    float slider_value =  normalize(contentOffsetX, 0.0, 1.0, frameMinX, frameMaxX);
    slider_value       =  (slider_value < 0.0) ? 0.0 : (slider_value > 1.0) ? 1.0 : slider_value;
    
    return slider_value;
};

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

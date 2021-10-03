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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [captureDevice lockForConfiguration:nil];
}

float normalize(float unscaledNum, float minAllowed, float maxAllowed, float min, float max) {
    return (maxAllowed - minAllowed) * (unscaledNum - min) / (max - min) + minAllowed;
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
    if ((scrollView.isDragging || scrollView.isTracking || scrollView.isDecelerating))
    {
//        NSLog(@"scrollView.bounds.origin.x == %f\nscrollView.bounds.size.width == %f\n", CGRectGetMinX(self.scrollView.bounds), CGRectGetWidth(self.scrollView.bounds));
//        float value = scaleSliderValue(scrollView.frame, scrollView.contentOffset.x, 1.0, captureDevice.activeFormat.videoMaxZoomFactor);
        float value = normalize(scrollView.contentOffset.x, 1.0, captureDevice.activeFormat.videoMaxZoomFactor, 0.0, CGRectGetWidth(self.scrollView.bounds));
        [captureDevice setVideoZoomFactor:MAX(1.0, MIN(value, captureDevice.activeFormat.videoMaxZoomFactor))];
        NSLog(@"value == %f", value);
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [captureDevice unlockForConfiguration];
}

@end

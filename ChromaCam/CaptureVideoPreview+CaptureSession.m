//
//  CaptureVideoPreview+CaptureSession.m
//  ChromaCam
//
//  Created by Xcode Developer on 9/28/21.
//

#import "CaptureVideoPreview+CaptureSession.h"

@implementation CaptureVideoPreview (CaptureSession)

@dynamic captureSession, captureDevice, captureDeviceInput, captureConnection;

- (void)setCaptureSession:(AVCaptureSession *)captureSession
{
    objc_setAssociatedObject(self, @selector(captureSession), captureSession, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AVCaptureSession *)captureSession
{
    return objc_getAssociatedObject(self, @selector(captureSession));
}

@end

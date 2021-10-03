//
//  CaptureVideoPreview+CaptureSession.h
//  ChromaCam
//
//  Created by Xcode Developer on 9/28/21.
//

#import "CaptureVideoPreview.h"

#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface CaptureVideoPreview (CaptureSession)

@property (strong, nonatomic) AVCaptureSession                               * captureSession;
@property (strong, nonatomic) AVCaptureDevice                                * captureDevice;
@property (strong, nonatomic) AVCaptureDeviceInput                           * captureDeviceInput;
@property (strong, nonatomic) AVCaptureConnection                            * captureConnection;

@end

NS_ASSUME_NONNULL_END

//
//  VideoCamera.h
//  ChromaCam
//
//  Created by Xcode Developer on 9/25/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#import "CaptureVideoPreview.h"
#import "CaptureSessionConfigurationQueue.h"

NS_ASSUME_NONNULL_BEGIN

@interface CaptureSession : AVCaptureSession

+ (CaptureSession *)captureSessionForVideoPreviewLayer:(AVCaptureVideoPreviewLayer *)captureVideoPreviewLayer;

@property (strong, nonatomic) AVCaptureSession                               * captureSession;
@property (strong, nonatomic) AVCaptureDevice                                * captureDevice;
@property (strong, nonatomic) AVCaptureDeviceInput                           * captureDeviceInput;
@property (strong, nonatomic) AVCaptureConnection                            * captureConnection;
//@property (assign, nonatomic) AVCaptureVideoPreviewLayer                     * captureVideoPreviewLayer;


@end

NS_ASSUME_NONNULL_END

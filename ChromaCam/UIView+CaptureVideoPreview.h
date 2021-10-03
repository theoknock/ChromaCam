//
//  UIView+AVCaptureVideoPreviewLayer.h
//  ChromaCam
//
//  Created by Xcode Developer on 9/29/21.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (CaptureVideoPreview)

@property(class, nonatomic, readwrite) Class layerClass;

@end

NS_ASSUME_NONNULL_END

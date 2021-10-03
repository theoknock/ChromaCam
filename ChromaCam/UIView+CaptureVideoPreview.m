//
//  UIView+AVCaptureVideoPreviewLayer.m
//  ChromaCam
//
//  Created by Xcode Developer on 9/29/21.
//

#import "UIView+CaptureVideoPreview.h"

@implementation UIView (CaptureVideoPreview)

@dynamic layerClass;

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

+ (void)setLayerClass:(Class)layerClass
{
    self.layerClass = [AVCaptureVideoPreviewLayer class];
}

@end

//
//  CaptureDeviceConfigurationPropertyReusableButton.h
//  ChromaCam
//
//  Created by Xcode Developer on 10/9/21.
//

#import <UIKit/UIKit.h>
#import "CaptureDeviceConfigurationPropertyResources.h"
#import "UIControl+Blocks.h"

NS_ASSUME_NONNULL_BEGIN

@interface CaptureDeviceConfigurationPropertyReusableButton : UIButton

- (instancetype)initWithCaptureDeviceConfigurationControlProperty:(CaptureDeviceConfigurationControlProperty)captureDeviceConfigurationControlProperty;

@property (copy, nonatomic, setter=setConfigureCaptureDeviceProperty:) void(^ConfigureCaptureDeviceProperty)(float property_value);

@end

NS_ASSUME_NONNULL_END

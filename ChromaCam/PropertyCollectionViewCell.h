//
//  PropertyCollectionViewCell.h
//  ChromaCam
//
//  Created by Xcode Developer on 10/9/21.
//

#import <UIKit/UIKit.h>
#import "CaptureDeviceConfigurationPropertyReusableButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface PropertyCollectionViewCell : UICollectionViewCell

- (void)setReusableButtonWithCaptureDeviceConfigurationControlForProperty:(CaptureDeviceConfigurationControlProperty)captureDeviceConfigurationControlProperty usingValueControl:(typeof(UIControl *))valueControl;

@end

NS_ASSUME_NONNULL_END

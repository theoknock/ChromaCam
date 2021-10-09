//
//  PropertyCollectionViewCell.h
//  ChromaCam
//
//  Created by Xcode Developer on 10/9/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PropertyCollectionViewCell : UICollectionViewCell

@property (nonatomic) UIButton * captureDeviceConfigurationPropertyButton;
//- (void)setCaptureDeviceConfigurationPropertyButton:(UIButton * _Nonnull * _Nonnull)button;
- (void)setCaptureDeviceConfigurationPropertyButtonActiveState:(BOOL)activeState;

@end

NS_ASSUME_NONNULL_END

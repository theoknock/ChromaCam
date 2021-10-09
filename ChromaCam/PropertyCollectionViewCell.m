//
//  PropertyCollectionViewCell.m
//  ChromaCam
//
//  Created by Xcode Developer on 10/9/21.
//

#import "PropertyCollectionViewCell.h"

@implementation PropertyCollectionViewCell

@synthesize captureDeviceConfigurationPropertyButton;

- (void)prepareForReuse {
    [super prepareForReuse];
    [captureDeviceConfigurationPropertyButton removeFromSuperview];
    captureDeviceConfigurationPropertyButton = nil;
}

- (void)setCaptureDeviceConfigurationPropertyButton:(UIButton *)captureDeviceConfigurationPropertyButton {
    self->captureDeviceConfigurationPropertyButton = captureDeviceConfigurationPropertyButton;
    [self.contentView addSubview:self->captureDeviceConfigurationPropertyButton];
}

- (void)setCaptureDeviceConfigurationPropertyButtonActiveState:(BOOL)activeState {
    [captureDeviceConfigurationPropertyButton setHighlighted:activeState];
    [captureDeviceConfigurationPropertyButton setSelected:activeState];
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end

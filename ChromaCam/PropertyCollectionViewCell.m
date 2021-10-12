//
//  PropertyCollectionViewCell.m
//  ChromaCam
//
//  Created by Xcode Developer on 10/9/21.
//

#import "PropertyCollectionViewCell.h"

@interface PropertyCollectionViewCell ()
{
    CaptureDeviceConfigurationPropertyReusableButton * captureDeviceConfigurationPropertyReusableButton;
}

@end

@implementation PropertyCollectionViewCell

@dynamic tag;

- (void)setTag:(NSInteger)tag {
    [super setTag:tag];
    if (!captureDeviceConfigurationPropertyReusableButton) {
        [captureDeviceConfigurationPropertyReusableButton = [[CaptureDeviceConfigurationPropertyReusableButton alloc] initWithCaptureDeviceConfigurationControlProperty:self.tag] setFrame:CGRectMake(0.0, 0.0, 42.0, 42.0)];
        [self.contentView addSubview:captureDeviceConfigurationPropertyReusableButton]; //[[CaptureDeviceConfigurationPropertyReusableButton alloc] initWithCaptureDeviceConfigurationControlProperty:self.tag]];
    }
}

@end

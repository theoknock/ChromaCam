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

- (void)setReusableButtonWithCaptureDeviceConfigurationControlForProperty:(CaptureDeviceConfigurationControlProperty)captureDeviceConfigurationControlProperty usingValueControl:(typeof(UIControl *))valueControl {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [captureDeviceConfigurationPropertyReusableButton = [[CaptureDeviceConfigurationPropertyReusableButton alloc] initWithCaptureDeviceConfigurationControlProperty:self.tag] setValueControl:valueControl];
    [self.contentView addSubview:captureDeviceConfigurationPropertyReusableButton]; //[[CaptureDeviceConfigurationPropertyReusableButton alloc] initWithCaptureDeviceConfigurationControlProperty:self.tag]];
}

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [captureDeviceConfigurationPropertyReusableButton removeFromSuperview];
    captureDeviceConfigurationPropertyReusableButton = nil;
}

@end

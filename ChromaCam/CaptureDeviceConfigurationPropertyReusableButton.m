//
//  CaptureDeviceConfigurationPropertyReusableButton.m
//  ChromaCam
//
//  Created by Xcode Developer on 10/9/21.
//

#import "CaptureDeviceConfigurationPropertyReusableButton.h"
#import "CaptureDeviceConfigurationPropertyResources.h"

@implementation CaptureDeviceConfigurationPropertyReusableButton
{
    NSInteger tag_mod;
}

@synthesize valueControl = _valueControl, ConfigureCaptureDeviceProperty = _ConfigureCaptureDeviceProperty;

- (instancetype)initWithCaptureDeviceConfigurationControlProperty:(CaptureDeviceConfigurationControlProperty)captureDeviceConfigurationControlProperty {
    if (self == [super init]) {

        [self setFrame:CGRectMake(0.0, 0.0, 82.8, 63.0)];
        
        // Tag
        [self setTag:captureDeviceConfigurationControlProperty];
        
        // Image
        UIImageSymbolConfiguration * symbol_configuration = [UIImageSymbolConfiguration configurationWithPointSize:42.0 weight:UIImageSymbolWeightThin];
        UIImage * button_image = [UIImage systemImageNamed:ImageForCaptureDeviceConfigurationControlProperty(captureDeviceConfigurationControlProperty) withConfiguration:symbol_configuration];
        [self setImage:button_image forState:UIControlStateNormal];
        
        // Drawing
        [self setReversesTitleShadowWhenHighlighted:TRUE];
        [self setShowsTouchWhenHighlighted:TRUE];
        
        // State
        [self setEnabled:TRUE];
        [self setSelected:FALSE];
        [self setHighlighted:FALSE];
        [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        
        
        // View layout
        [self setTranslatesAutoresizingMaskIntoConstraints:TRUE];
        
        // Target-Action-Event
        
    }
    
    return self;
}

- (void)setValueControl:(typeof([UIControl class]))valueControl {
    NSLog(@"[valueControl class] == %@", [[valueControl class] description]);
    _valueControl = (typeof([valueControl class]))valueControl;
}

// If this doesn't work, try passing the initial arguments to this method (see related OneNote)
- (void)setConfigureCaptureDeviceProperty:(void (^)(float))ConfigureCaptureDeviceProperty {
    _ConfigureCaptureDeviceProperty = ConfigureCaptureDeviceProperty;
}

- (IBAction)activate:(id)sender {
    [self setSelected:TRUE];
    [self setHighlighted:TRUE];
    [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    printf("%s", __PRETTY_FUNCTION__);
    //    tag_mod = (tag_mod + 1) % 5;
    //    UIImageSymbolConfiguration * symbol_configuration = [UIImageSymbolConfiguration configurationWithPointSize:42.0 weight:UIImageSymbolWeightThin];
    //    UIImage * button_image = [UIImage systemImageNamed:ImageForCaptureDeviceConfigurationControlProperty(tag_mod) withConfiguration:symbol_configuration];
    //    [self setImage:button_image forState:UIControlStateNormal];
}

@end

//
//  ScrollViewControlV.m
//  ChromaCam
//
//  Created by Xcode Developer on 10/3/21.
//

#import "ScrollViewSlider.h"
#import "ScaleSliderOverlayLayer.h"

@implementation ScrollViewSlider

- (void)awakeFromNib {
    [super awakeFromNib];
    [(ScaleSliderOverlayLayer *)self.layer setMeasurementIndicatorHorizontalOffset:0];
}

+ (Class)layerClass
{
    return [ScaleSliderOverlayLayer class];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

@end

//
//  ScrollViewControlV.m
//  ChromaCam
//
//  Created by Xcode Developer on 10/3/21.
//

#import "ScrollViewContentView.h"
#import "ScaleSliderOverlayLayer.h"

#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>


@implementation ScrollViewContentView

+ (Class)layerClass
{
    return [ScaleSliderOverlayLayer class];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [(ScaleSliderOverlayLayer *)self.layer display];
}

@end

//
//  ScrollViewControlV.m
//  ChromaCam
//
//  Created by Xcode Developer on 10/3/21.
//

#import "ValueScrollViewContentView.h"
#import "ValueScrollViewContentViewLayerContent.h"

#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>


@implementation ValueScrollViewContentView

+ (Class)layerClass
{
    return [ValueScrollViewContentViewLayerContent class];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [(ValueScrollViewContentViewLayerContent *)self.layer display];
}



@end

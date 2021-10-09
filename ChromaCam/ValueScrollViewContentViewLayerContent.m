//
//  ScaleSliderLayerTop.m
//  ISOCameraLDE
//
//  Created by Xcode Developer on 10/6/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import "ValueScrollViewContentViewLayerContent.h"

#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>


@implementation ValueScrollViewContentViewLayerContent
{
    CATextLayer *scaleSliderValueTextLayer;
    CATextLayer *scaleSliderMinimumValueTextLayer;
    CATextLayer *scaleSliderMaximumValueTextLayer;
}

- (instancetype)init
{
    if (self == [super init]) {        
        scaleSliderValueTextLayer = [CATextLayer new];
        [self attributesForTextLayer:scaleSliderValueTextLayer];
        [self addSublayer:scaleSliderValueTextLayer];
        [self setText:@"0.5" forLayer:scaleSliderValueTextLayer frameWithOffset:CGRectGetMidX([[UIScreen mainScreen] bounds])];
        
        scaleSliderMinimumValueTextLayer = [CATextLayer new];
        [self attributesForTextLayer:scaleSliderMinimumValueTextLayer];
        [self addSublayer:scaleSliderMinimumValueTextLayer];
        [self setText:@"0.0" forLayer:scaleSliderMinimumValueTextLayer frameWithOffset:0];
        
        scaleSliderMaximumValueTextLayer = [CATextLayer new];
        [self attributesForTextLayer:scaleSliderMaximumValueTextLayer];
        [self addSublayer:scaleSliderMaximumValueTextLayer];
        [self setText:@"1.0" forLayer:scaleSliderMaximumValueTextLayer frameWithOffset:[[UIScreen mainScreen] bounds].size.width];
        
        [self setNeedsDisplay];
        [self setNeedsDisplayOnBoundsChange:YES];
    }
    
    return self;
}

- (void)setText:(NSString *)valueString forLayer:(CATextLayer *)textLayer frameWithOffset:(CGFloat)originX {
    [textLayer setContentsScale:[[UIScreen mainScreen] nativeScale]];
    [textLayer setRasterizationScale:[[UIScreen mainScreen] nativeScale]];
    NSMutableParagraphStyle *centerAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    centerAlignedParagraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *centerAlignedTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                  NSFontAttributeName:[UIFont systemFontOfSize:14.0 weight:UIFontWeightLight],
                                                  NSParagraphStyleAttributeName:centerAlignedParagraphStyle};
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:valueString attributes:centerAlignedTextAttributes];
    ((CATextLayer *)textLayer).string = attributedString;

    CGSize textLayerframeSize = [self suggestFrameSizeWithConstraints:self.frame.size forAttributedString:attributedString];
    CGRect textLayerFrame = CGRectMake(originX - (textLayerframeSize.width * 0.5), textLayerframeSize.height + (textLayerframeSize.height / 2.0), textLayerframeSize.width, textLayerframeSize.height);
    [(CATextLayer *)textLayer setFrame:textLayerFrame];
    [textLayer display];
}

- (void)attributesForTextLayer:(CATextLayer *)textLayer
{
    [(CATextLayer *)textLayer setAllowsFontSubpixelQuantization:TRUE];
    [(CATextLayer *)textLayer setOpaque:FALSE];
    [(CATextLayer *)textLayer setAlignmentMode:kCAAlignmentCenter];
    [(CATextLayer *)textLayer setWrapped:FALSE];
}

- (CGSize)suggestFrameSizeWithConstraints:(CGSize)size forAttributedString:(NSAttributedString *)attributedString
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFMutableAttributedStringRef)attributedString);
    CFRange attributedStringRange = CFRangeMake(0, attributedString.length);
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, attributedStringRange, NULL, size, NULL);
    CFRelease(framesetter);
    
    return suggestedSize;
}

- (CGColorRef)backgroundColor
{
    return [[UIColor clearColor] CGColor];
}

- (BOOL)isOpaque
{
    return FALSE;
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGRect bounds = [self bounds];
    CGContextTranslateCTM(ctx, CGRectGetMinX(bounds), CGRectGetMinY(bounds));

    CGFloat stepSize = (CGRectGetMaxX(bounds) / 100.0);
    CGFloat height_eighth = (CGRectGetHeight(bounds) / 8.0);
    CGFloat height_sixteenth = (CGRectGetHeight(bounds) / 16.0);
    CGFloat height_thirtysecond = (CGRectGetHeight(bounds) / 32.0);
    for (int t = 0; t <= 100; t++) {
        CGFloat x = (CGRectGetMinX(bounds) + (stepSize * t));
        if (t % 10 == 0)
        {
            CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
            CGContextSetLineWidth(ctx, 0.625);
            CGContextMoveToPoint(ctx, x, (CGRectGetMinY(bounds) + height_eighth) - height_thirtysecond);
            CGContextAddLineToPoint(ctx, x, (CGRectGetMidY(bounds) - height_eighth) - height_thirtysecond);
        }
        else
        {
            CGContextSetStrokeColorWithColor(ctx, [[UIColor lightGrayColor] CGColor]);
            CGContextSetLineWidth(ctx, 0.375);
            CGContextMoveToPoint(ctx, x, (CGRectGetMinY(bounds) + (height_eighth + height_sixteenth)) - height_thirtysecond);
            CGContextAddLineToPoint(ctx, x, (CGRectGetMidY(bounds) - (height_eighth + height_sixteenth)) - height_thirtysecond);
        }
        
        CGContextStrokePath(ctx);
    }
}

@end

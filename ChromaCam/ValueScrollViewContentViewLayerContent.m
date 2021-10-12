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

//static NSParagraphStyle * (^textLayerParagraphStyle)(void) = ^ NSParagraphStyle * (void) {
//    NSMutableParagraphStyle * centerAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
//    centerAlignedParagraphStyle.alignment = NSTextAlignmentCenter;
//
//    return centerAlignedParagraphStyle;
//};

static float(^jkl)(void) = ^ float {
    return 2;
};

static NSParagraphStyle * (^textLayerParagraphStyle)(NSTextAlignment) = ^ NSParagraphStyle * (NSTextAlignment text_alignment) {
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;

    return (NSParagraphStyle *)paragraphStyle;
};

static NSDictionary * (^textLayerTextAttributes)(UIColor *color, UIFont * font, NSParagraphStyle * paragraph_style) = ^ NSDictionary * (UIColor *color, UIFont * font, NSParagraphStyle * paragraph_style) {
NSDictionary * attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                              NSFontAttributeName:[UIFont systemFontOfSize:14.0 weight:UIFontWeightLight],
                                              NSParagraphStyleAttributeName:paragraph_style};
    
    return attributes;
};




//
//^ (float value) {
//    rertu
//    return ^ (float value) {
//        ^ (NSDictionary * string_attributes) {
//            return ^ NSAttributedString * (float value) {
//                NSAttributedString * attributed_string = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f", value] attributes:string_attributes];
//                return attributed_string;
//            };
//        }(textLayerTextAttributes([UIColor whiteColor], [UIFont systemFontOfSize:14.0 weight:UIFontWeightLight], textLayerParagraphStyle(NSTextAlignmentCenter)));
//    };
//};

//static void (^set_text_layer_value)(float) = ^ (NSParagraphStyle * textLayerParagraphStyle) {
//    return ^ (float value) {
//        // perform text layer update
//    };
//}(^ NSParagraphStyle * (void) {
//    NSMutableParagraphStyle * centerAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
//    centerAlignedParagraphStyle.alignment = NSTextAlignmentCenter;
//
//    return centerAlignedParagraphStyle;
//});

@implementation ValueScrollViewContentViewLayerContent
{
    CATextLayer *scaleSliderValueTextLayer;
    CATextLayer *scaleSliderMinimumValueTextLayer;
    CATextLayer *scaleSliderMaximumValueTextLayer;
    NSParagraphStyle * textLayerParagraphStyle;
    NSDictionary * textLayerParagraphStyleTextAttributes;
    NSMutableAttributedString * textLayerAttributedString;
}

// GOAL: NSAttributedString * (^string)(float);
static NSAttributedString * (^(^(^asdf)(NSDictionary *))(NSString *))(float) = ^ (NSDictionary * dictionary) {
    return ^ (NSString * string) {
        return ^ NSAttributedString * (float value) {
            return [NSAttributedString new];
        };
    };
};

- (void)test_block {
    // GOAL: asdf(1.0)
    NSAttributedString * string = asdf([NSDictionary new])([NSString new])(1.0);
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

- (void)setValue:(CGFloat)value {
    [self setText:[NSString stringWithFormat:@"%.2f", value] forLayer:scaleSliderValueTextLayer frameWithOffset:(CGRectGetMaxX([[UIScreen mainScreen] bounds]) -  CGRectGetMinX([[UIScreen mainScreen] bounds])) * value];
    
    [self setNeedsDisplay];
    [self setNeedsDisplayOnBoundsChange:YES];
}

- (void)setText:(NSString *)valueString forLayer:(CATextLayer *)textLayer frameWithOffset:(CGFloat)originX {
    [textLayer setContentsScale:[[UIScreen mainScreen] nativeScale]];
    [textLayer setRasterizationScale:[[UIScreen mainScreen] nativeScale]];
    NSMutableParagraphStyle * centerAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    centerAlignedParagraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary * centerAlignedTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
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

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

typedef NSParagraphStyle * (^ParagraphStyle)(void);
typedef NSDictionary * (^CharacterStyle)(NSParagraphStyle *);
typedef NSAttributedString * (^AttributedText)(NSString *);

@implementation ValueScrollViewContentViewLayerContent
{
    CATextLayer *scaleSliderValueTextLayer;
    CATextLayer *scaleSliderMinimumValueTextLayer;
    CATextLayer *scaleSliderMaximumValueTextLayer;
    AttributedText attributed_text;
}

NSDictionary * (^text_attributes)(UIColor *, UIFont *, NSTextAlignment) = ^ (UIColor * color, UIFont * font, NSTextAlignment alignment) {
    return ^ (NSParagraphStyle * style) {
        return @{NSForegroundColorAttributeName:color,
                 NSFontAttributeName:font,
                 NSParagraphStyleAttributeName:style};
    }(^ {
        NSMutableParagraphStyle * paragraphStyle;
        [paragraphStyle = [[NSMutableParagraphStyle alloc] init] setAlignment:alignment];
        return (NSParagraphStyle *)paragraphStyle;
    }());
};

// UIFontTextStyle string-to-attributed-string factories to use UIFontTextStyle
static NSAttributedString * (^(^attributed_string_using_font_text_style_body)(void))(NSString *) = ^ (void) {
    return ^ (NSDictionary * attributes) {
        return ^ NSAttributedString * (NSString * string) {
            return [[NSAttributedString alloc] initWithString:string attributes:attributes];
        };
    }(^ (UIColor * color, UIFont * font, NSTextAlignment alignment) {
        return ^ (NSParagraphStyle * text_style) {
            return @{NSForegroundColorAttributeName:color,
                     NSFontAttributeName:font,
                     NSParagraphStyleAttributeName:text_style};
        }(^ NSParagraphStyle * (void) {
            NSMutableParagraphStyle * paragraphStyle;
            [paragraphStyle = [[NSMutableParagraphStyle alloc] init] setAlignment:alignment];
            return (NSParagraphStyle *)paragraphStyle;
        }());
    }([UIColor whiteColor],
      [UIFont systemFontOfSize:14.0 weight:UIFontWeightLight],
      NSTextAlignmentCenter));
};

static NSAttributedString * (^(^(^attributed_text_with_extended_attributes)(NSDictionary *))(NSParagraphStyle *))(NSString *) = ^ (NSDictionary * text_attributes) {
    return ^ (NSParagraphStyle * text_style) {
        return ^ NSAttributedString * (NSString * string) {
            return [[NSAttributedString alloc] initWithString:string attributes:text_attributes];
        };
    };
};

- (instancetype)init
{
    if (self == [super init]) {
        attributed_text =  ^ {
            ParagraphStyle paragraph_style = ^ (NSTextAlignment alignment) {                                  // add custom parameters here
                return ^ NSParagraphStyle * (void) {
//                    printf("\nParagraphStyle\t");                                                           // uncomment for proof of optimal memory allocation
                    return [NSParagraphStyle new];
                };
            }(NSTextAlignmentCenter);
            
            CharacterStyle character_style = ^ (UIColor * color, UIFont * font, NSTextAlignment alignment) {  // add custom parameters here
                return ^ NSDictionary * (NSParagraphStyle * ps) {
//                    printf("CharacterStyle\t");                                                             // uncomment for proof of optimal memory allocation
                    return @{NSForegroundColorAttributeName:color,
                             NSFontAttributeName:font,
                             NSParagraphStyleAttributeName:ps};
                };
            }([UIColor whiteColor],
              [UIFont systemFontOfSize:14.0 weight:UIFontWeightLight],
              NSTextAlignmentCenter);
            
            return ^ (NSDictionary * attributes) {
                return ^ NSAttributedString * (NSString * text) {
//                    printf("AttributedText\n");                                                            // uncomment for proof of optimal resource usage
                    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
                };
            }(character_style(paragraph_style()));
        }();
        
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
//    printf("value == %f", value);
//    [self setNeedsDisplay];
//    [self setNeedsDisplayOnBoundsChange:YES];
}

- (void)setText:(NSString *)valueString forLayer:(CATextLayer *)textLayer frameWithOffset:(CGFloat)originX {
    NSAttributedString *attributedString = attributed_text(valueString);
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
    [(CATextLayer *)textLayer setContentsScale:[[UIScreen mainScreen] nativeScale]];
    [(CATextLayer *)textLayer setRasterizationScale:[[UIScreen mainScreen] nativeScale]];
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

//
//  PropertyCollectionViewCell.m
//  ChromaCam
//
//  Created by Xcode Developer on 10/9/21.
//

#import "PropertyCollectionViewCell.h"
#import "AFCollectionViewLayoutAttributes.h"

@implementation PropertyCollectionViewCell

#pragma mark - Overridden Methods

-(void)prepareForReuse
{
    [super prepareForReuse];
}

-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
//    maskView.alpha = 0.0f;
    self.layer.shouldRasterize = NO;
    
    // Important! Check to make sure we're actually this special subclass.
    // Failing to do so could cause the app to crash!
    if (![layoutAttributes isKindOfClass:[AFCollectionViewLayoutAttributes class]])
    {
        return;
    }
    
    AFCollectionViewLayoutAttributes *castedLayoutAttributes = (AFCollectionViewLayoutAttributes *)layoutAttributes;
    
    self.layer.shouldRasterize = castedLayoutAttributes.shouldRasterize;
//    maskView.alpha = castedLayoutAttributes.maskingValue;
}

@end

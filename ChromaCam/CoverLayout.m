//
//  CoverLayout.m
//  CollectionPractice
//
//  Created by abyssinaong on 2017. 3. 22..
//  Copyright © 2017년 KimYunseo. All rights reserved.
//

#import "CoverLayout.h"

@implementation CoverLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {    
    __autoreleasing NSArray<UICollectionViewLayoutAttributes *> * collectionViewLayoutAttributes;
    [self performSelector:@selector(changeLayoutAttributes:) withObject:[collectionViewLayoutAttributes = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:TRUE] self]];
    
    return (NSArray<UICollectionViewLayoutAttributes *> *)collectionViewLayoutAttributes;
}

- (void)changeLayoutAttributes:(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributes {
    for (UICollectionViewLayoutAttributes * attribute in layoutAttributes) {
        CGFloat actualXOffset = (self.collectionView.bounds.size.width / 2.0) + self.collectionView.contentOffset.x;
        CGFloat maxDistance = self.itemSize.width + self.minimumLineSpacing;
        CGFloat distance = MIN(fabs(actualXOffset -  attribute.center.x), maxDistance);
        
        CGFloat ratio = (maxDistance - distance) / maxDistance;
        
        CGFloat scale = (ratio * 0.5f) + 1.0f;
        
        CGFloat alpha = (ratio * 0.5f) + 0.5f;
        
        attribute.alpha = alpha;
        
        attribute.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1);
        attribute.zIndex = 10 * alpha;
    }
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat actualContentOffset = proposedContentOffset.x + (self.collectionView.bounds.size.width / 2.0f);
    
    NSArray *attributeArray = [self layoutAttributesForElementsInRect:self.collectionView.bounds];
    
    NSArray *resultArray = [attributeArray sortedArrayUsingComparator:^NSComparisonResult(UICollectionViewLayoutAttributes * _Nonnull obj1, UICollectionViewLayoutAttributes * _Nonnull obj2) {
        
        if (fabs(obj1.center.x - actualContentOffset) > fabs(obj2.center.x - actualContentOffset)) {
            
            return NSOrderedDescending;
            
        } else if (fabs(obj1.center.x - actualContentOffset) < fabs(obj2.center.x - actualContentOffset)) {
            
            return NSOrderedAscending;
            
        } else {
            
            
            return NSOrderedSame;
        }
    }];
    
    CGFloat resultOffset = ((UICollectionViewLayoutAttributes *)resultArray.firstObject).center.x;
    CGPoint targetOffset = CGPointMake(resultOffset - (self.collectionView.bounds.size.width / 2.0f), proposedContentOffset.y);
    
    return targetOffset;
}

- (CGSize)itemSize {
    CGSize cellSize = CGSizeMake(self.collectionView.bounds.size.width / 5.0f, self.collectionView.bounds.size.height);
    
    return cellSize;
}

@end

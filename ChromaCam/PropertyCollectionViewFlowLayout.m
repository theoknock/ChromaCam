//
//  PropertyCollectionViewFlowLayout.m
//  ChromaCam
//
//  Created by Xcode Developer on 10/8/21.
//

#import "PropertyCollectionViewFlowLayout.h"

@implementation PropertyCollectionViewFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(100.0, 0.0, 0.0, 0.0);

    return edgeInsets;
}

- (UICollectionViewFlowLayoutSectionInsetReference)sectionInsetReference {
    return UICollectionViewFlowLayoutSectionInsetFromLayoutMargins;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize = CGSizeMake(collectionView.bounds.size.width / [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:0], collectionView.bounds.size.height);
    
    return cellSize;
}

- (CGSize)itemSize {
    CGSize cellSize = CGSizeMake(self.collectionView.bounds.size.width / [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0], self.collectionView.bounds.size.height);
    
    return cellSize;
}

- (UICollectionViewScrollDirection)scrollDirection {
    return UICollectionViewScrollDirectionHorizontal;
}

- (CGSize)collectionViewContentSize {
    CGSize contentSize = CGSizeMake(self.collectionView.bounds.size.width * 2.0, self.collectionView.bounds.size.height);
    
    return contentSize;
}

- (CGFloat)minimumInteritemSpacing {
    return 0;
}

@end

//
//  PropertyControlHorizontalFlowCollectionViewController.m
//  ChromaCam
//
//  Created by Xcode Developer on 10/11/21.
//

#import "PropertyControlHorizontalFlowCollectionViewController.h"
#import "CaptureDeviceConfigurationPropertyResources.h"
#import "ViewController.h"

@interface PropertyControlHorizontalFlowCollectionViewController ()

@end

@implementation PropertyControlHorizontalFlowCollectionViewController

static NSArray<NSString *> * const cellImages = @[@"bolt.circle",
                                                  @"viewfinder.circle",
                                                  @"timer",
                                                  @"camera.aperture",
                                                  @"magnifyingglass.circle"];

static NSArray<NSString *> * const cellReuseIdentifiers = @[@"TorchLevelPropertyCell",
                                                            @"LensPositionPropertyCell",
                                                            @"ExposureDurationPropertyCell",
                                                            @"ISOPropertyCell",
                                                            @"ZoomFactorPropertyCell"];

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.collectionView setAllowsSelection:TRUE];
    [self.collectionView setAllowsMultipleSelection:FALSE];
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//    return CGSizeMake(collectionView.bounds.size.width / 5, collectionView.bounds.size.height);
//}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//
//
//
//    //((UICollectionViewFlowLayout *)collectionViewLayout).itemSize
//
////    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
////    CGFloat leftInsetValue = (collectionView.frame.size.width - flowLayout.itemSize.width)/2.0f;
//    CGFloat leftInsetValue = (self.collectionView.frame.size.width - self.cellLayout.itemSize.width) / 2.0f;
//    UIEdgeInsets inset = UIEdgeInsetsMake(0, leftInsetValue, 0, leftInsetValue);
//
//    return inset;
//}

//- (__kindof PropertyCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    PropertyCollectionViewCell * cell;
//    [cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PropertyCollectionViewCellReuseID" forIndexPath:indexPath] setTag:indexPath.item];
//
//    return cell;
//}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell;
    [cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifiers[indexPath.item] forIndexPath:indexPath] setTag:indexPath.item];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [(ViewController *)self.parentViewController configureCaptureDeviceForProperty:indexPath.item];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return cellReuseIdentifiers.count;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}
*/

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


@end

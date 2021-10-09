//
//  ViewController.h
//  ChromaCam
//
//  Created by Xcode Developer on 9/25/21.
//

#import <UIKit/UIKit.h>

#import "UIView+AVCaptureVideoPreviewLayer.h"
#import "ValueScrollViewContentView.h"
#import "CoverLayout.h"

@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching>

@property (weak, nonatomic) IBOutlet UIView * captureVideoPreview;

@property (weak, nonatomic) IBOutlet UIScrollView *valueScrollView;
@property (weak, nonatomic) IBOutlet ValueScrollViewContentView *valueContentView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet CoverLayout *cellLayout;

@end


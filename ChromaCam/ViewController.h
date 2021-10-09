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
#import "PropertyCollectionViewCell.h"

@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching>

@property (weak, nonatomic) IBOutlet UIView * captureVideoPreview;
@property (weak, nonatomic) IBOutlet UIButton *captureDeviceConfigurationPropertyButton;

@property (strong, nonatomic) IBOutlet UIButton *torchLevelButton;

@property (strong, nonatomic) IBOutlet UIButton *lensPositionButton;
@property (strong, nonatomic) IBOutlet UIButton *exposureDurationButton;
@property (strong, nonatomic) IBOutlet UIButton *ISOButton;

@property (strong, nonatomic) IBOutlet UIButton *zoomFactorButton;




@property (weak, nonatomic) IBOutlet UIScrollView *valueScrollView;
@property (weak, nonatomic) IBOutlet ValueScrollViewContentView *valueContentView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet CoverLayout *cellLayout;
@property (strong, nonatomic) IBOutlet UIButton *testButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *CaptureDevicePropertyConfigurationButtons;

@end


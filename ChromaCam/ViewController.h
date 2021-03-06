//
//  ViewController.h
//  ChromaCam
//
//  Created by Xcode Developer on 9/25/21.
//

#import <UIKit/UIKit.h>

#import "UIView+AVCaptureVideoPreviewLayer.h"
#import "ScrollViewSlider.h"

@interface ViewController : UIViewController <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIView * captureVideoPreview;
@property (weak, nonatomic) IBOutlet UIView *scrollViewControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet ScrollViewSlider *scrollViewSlider;
@property (weak, nonatomic) IBOutlet UIStackView *cameraControlButtonsStackView;
@property (weak, nonatomic) IBOutlet UIButton *torchLevelButton;
@property (weak, nonatomic) IBOutlet UIButton *lensPositionButton;
@property (weak, nonatomic) IBOutlet UIButton *exposureDurationButton;
@property (weak, nonatomic) IBOutlet UIButton *ISOButton;
@property (weak, nonatomic) IBOutlet UIButton *zoomFactorButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cameraControlButtons;

@end


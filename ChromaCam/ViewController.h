//
//  ViewController.h
//  ChromaCam
//
//  Created by Xcode Developer on 9/25/21.
//

#import <UIKit/UIKit.h>

#import "UIView+AVCaptureVideoPreviewLayer.h"
#import "ScrollViewContentView.h"

@interface ViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *propertyScrollView;
@property (weak, nonatomic) IBOutlet UIView * captureVideoPreview;
@property (weak, nonatomic) IBOutlet UIButton *torchLevelButton;
@property (weak, nonatomic) IBOutlet UIButton *lensPositionButton;
@property (weak, nonatomic) IBOutlet UIButton *exposureDurationButton;
@property (weak, nonatomic) IBOutlet UIButton *ISOButton;
@property (weak, nonatomic) IBOutlet UIButton *zoomFactorButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cameraControlButtons;
@property (weak, nonatomic) IBOutlet UIScrollView *valueScrollView;
@property (weak, nonatomic) IBOutlet ScrollViewContentView *valueContentView;

@end


//
//  ViewController.h
//  ChromaCam
//
//  Created by Xcode Developer on 9/25/21.
//

#import <UIKit/UIKit.h>

#import "UIView+AVCaptureVideoPreviewLayer.h"

@interface ViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView * captureVideoPreview;
@property (weak, nonatomic) IBOutlet UIView *scrollViewControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollViewSlider;

@end


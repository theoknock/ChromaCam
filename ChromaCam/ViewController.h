//
//  ViewController.h
//  ChromaCam
//
//  Created by Xcode Developer on 9/25/21.
//

#import <UIKit/UIKit.h>

#import "UIView+AVCaptureVideoPreviewLayer.h"

@interface ViewController : UIViewController

@property (strong, nonatomic) AVCaptureSession * captureSession;

@property (weak, nonatomic) IBOutlet UIView * captureVideoPreview;
@property (weak, nonatomic) IBOutlet UIView *scrollViewControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end


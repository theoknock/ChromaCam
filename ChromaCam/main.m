//
//  main.m
//  ChromaCam
//
//  Created by Xcode Developer on 9/25/21.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CaptureVideoPreview.h"

#import <objc/runtime.h>

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
        
//        Class captureVideoPreviewClass = [CaptureVideoPreview class];
//        unsigned int numInstanceMethods = 0;
//        Method * captureVideoPreviewInstanceMethods = class_copyMethodList(captureVideoPreviewClass, &numInstanceMethods);
//        //instanceMethods is an array of all instance methods for MyClass
//
//        Class captureVideoPreviewMetaClass = objc_getMetaClass(class_getName(captureVideoPreviewClass));
//        unsigned int numClassMethods = 0;
//        Method * classMethods = class_copyMethodList(captureVideoPreviewMetaClass, &numClassMethods);
//        //classMethods is an array of all class methods for MyClass
        
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}

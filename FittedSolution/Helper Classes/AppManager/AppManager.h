//
//  AppManager.h
//  FittedSolution
//
//  Created by Waqar Ali on 05/07/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainViewController.h"
#import "UIDeviceHardware.h"

#define app_manager             [AppManager sharedInstance]
#define ImageCompressionRate    0.8
#define PresentImagePicker      @"presentImagePicker"

#define isiPhone5               ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE
#define isiPhone4Or4s           ([[UIScreen mainScreen] bounds].size.height < 568)?TRUE:FALSE

struct BoundedBox
{
    int x   ;
    int y   ;
    int w   ;
    int h   ;
};
typedef struct BoundedBox BoundedBox;


@interface AppManager : NSObject

+(AppManager *)sharedInstance;

@property (nonatomic, strong) MainViewController *rootViewController;

- (NSString *)getDeviceiOSVersion;

- (BOOL)isInternetAvailable;

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize;
- (UIImage *)compressImage:(UIImage *)image;
- (UIImage *)fixRotation:(UIImage *)image;
- (void)drawBoxesOnImage:(UIImage *)image withFootBoundedBox:(BoundedBox)footBox andPhoneBoundedBox:(BoundedBox)phoneBox;

//- (void)addActivityIndicatorInMainView;
- (void)startAnimatingActivityIndicator;
- (void)stopAnimatingActivityIndicator;

- (void)handleError:(NSError *)error;
- (void)showResetAlertWithTitle:(NSString *)title Message:(NSString *)message;
- (void)showAlertWithTitle:(NSString *)title Message:(NSString *)message andAction:(NSString *)action;
- (void)showAlertForInternetErrorWithTitle:(NSString *)title Message:(NSString *)message;

- (void)showMeasuredPopup;
- (void)hideMeasuredPopup;

- (void)removeTutorialViewFromMainViewWithAnimation:(NSString *)animation;

- (BOOL)text:(NSString *)string containsString:(NSString*)other;
- (void)makeCircularView:(UIView *)view withCornerRadius:(float)radius;
- (NSData *)addPhoneModelAndNameToImageMetaData:(UIImage *)image;

@end

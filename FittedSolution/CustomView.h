//
//  CustomView.h
//  FittedSolution
//
//  Created by Waqar Ali on 13/01/2017.
//  Copyright © 2017 Waqar Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomView : UIView

@property (nonatomic) void (^cameraViewTouched)();
@property (nonatomic) UIView *cameraPreviewUpperLayer;

-(void)baseInitWithCameraViewTouchedCallBack:(void(^)())callBack;

@end

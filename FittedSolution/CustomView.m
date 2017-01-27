//
//  CustomView.m
//  FittedSolution
//
//  Created by Waqar Ali on 13/01/2017.
//  Copyright © 2017 Waqar Ali. All rights reserved.
//

#import "CustomView.h"

@implementation CustomView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.cameraPreviewUpperLayer.frame, point))
    {
        self.cameraViewTouched();
    }
    return NO;
}

-(void)baseInitWithCameraViewTouchedCallBack:(void(^)())callBack
{
    self.cameraViewTouched = callBack;
}


@end

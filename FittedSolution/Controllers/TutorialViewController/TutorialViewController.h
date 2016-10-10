//
//  TutorialViewController.h
//  FittedSolution
//
//  Created by Waqar Ali on 15/09/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView  * scrollView        ;
@property (weak, nonatomic) IBOutlet UIPageControl * pageControl       ;
@property (weak, nonatomic) IBOutlet UIButton      * getStartedBtn     ;

- (IBAction)skipTutorialAction:(id)sender;
- (IBAction)getStartedAction:(id)sender;

@end

//
//  MatchesShoesViewController.h
//  FittedSolution
//
//  Created by Waqar Ali on 06/10/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatchesShoesViewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *totalMatchesLabel;
@property (weak, nonatomic) IBOutlet UIView *mainViewContainer;

- (IBAction)backButtonAction:(id)sender;

@end

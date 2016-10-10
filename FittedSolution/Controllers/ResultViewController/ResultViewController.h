//
//  ResultViewController.h
//  FittedSolution
//
//  Created by Waqar Ali on 02/08/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FootDescription.h"

@interface ResultViewController : UIViewController

@property (strong, nonatomic) FootDescription    * sideFootDescription          ;
@property (strong, nonatomic) FootDescription    * frontFootDescription         ;

@property (weak, nonatomic) IBOutlet UILabel     * titleLbl                     ;

/*
 *      SideFootView
 */

@property (strong, nonatomic)        UIImage     * sideFootCroppedImage         ;
@property (weak, nonatomic) IBOutlet UIView      * sideFootView                 ;
@property (weak, nonatomic) IBOutlet UILabel     * sideFootViewTalusHeightLbl   ;
@property (weak, nonatomic) IBOutlet UILabel     * sideFootViewSlopeLbl         ;
@property (weak, nonatomic) IBOutlet UILabel     * sideFootViewLengthLbl        ;
@property (weak, nonatomic) IBOutlet UILabel     * sideFootViewArchDistanceLbl  ;
@property (weak, nonatomic) IBOutlet UILabel     * sideFootViewArchLbl          ;
@property (weak, nonatomic) IBOutlet UILabel     * sideFootViewToeHeightLbl     ;
@property (weak, nonatomic) IBOutlet UIImageView * sideFootImageView            ;

/*
 *      FrontFootView
 */

@property (strong, nonatomic)        UIImage     * frontFootCroppedImage        ;
@property (weak, nonatomic) IBOutlet UIView      * frontFootView                ;
@property (weak, nonatomic) IBOutlet UILabel     * frontFootViewWidthLbl        ;
@property (weak, nonatomic) IBOutlet UIImageView * frontFootImageView           ;

/*
 *      Bottom Result View
 */

@property (weak, nonatomic) IBOutlet UILabel     * footlengthTxt                ;
@property (weak, nonatomic) IBOutlet UILabel     * footWidthTxt                 ;
@property (weak, nonatomic) IBOutlet UILabel     * archHeightTxt                ;
@property (weak, nonatomic) IBOutlet UILabel     * archDistanceTxt              ;
@property (weak, nonatomic) IBOutlet UILabel     * talusHeightTxt               ;
@property (weak, nonatomic) IBOutlet UILabel     * toeBoxHeightTxt              ;
@property (weak, nonatomic) IBOutlet UILabel     * talusSlopeTxt                ;
@property (weak, nonatomic) IBOutlet UILabel     * mensUSLblTxt                 ;
@property (weak, nonatomic) IBOutlet UILabel     * mensEuroLblTxt               ;
@property (weak, nonatomic) IBOutlet UILabel     * mensUKLblTxt                 ;
@property (weak, nonatomic) IBOutlet UILabel     * womensLblTxt                 ;
@property (weak, nonatomic) IBOutlet UILabel     * womensEuroLblTxt             ;
@property (weak, nonatomic) IBOutlet UILabel     * womenUKLblTxt                ;


@property (weak, nonatomic) IBOutlet UIButton    * leftArrowBtn                 ;
@property (weak, nonatomic) IBOutlet UIButton    * rightArrowBtn                ;


/*
 *      Actions
 */

- (IBAction)shoePredictorButtonAction:(id)sender                                ;
- (IBAction)backButtonAction:(id)sender                                         ;
- (IBAction)rightArrowAction:(id)sender                                         ;
- (IBAction)leftArrowAction:(id)sender                                          ;

@end

//
//  MainViewController.h
//  FittedSolution
//
//  Created by Waqar Ali on 05/07/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpeechRecognitionManager.h"


@interface MainViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate,SpeechRecognitionManagerDelegate>

enum Step
{
    StepOne        ,
    StepOneRepeat  ,
    StepTwo        ,
    StepTwoRepeat
};

@property enum Step step                    ;

/*
 *
 *  Button Outlets and Actions
 *
 */

- (IBAction)menuButtonAction:(id)sender     ;
- (IBAction)infoButtonAction:(id)sender     ;
- (IBAction)cameraButtonAction:(id)sender   ;
- (IBAction)resetButtonAction:(id)sender    ;

@property (weak, nonatomic) IBOutlet UIButton    * cameraButton       ;
@property (weak, nonatomic) IBOutlet UIButton    * resetButton        ;

//activity outlet
@property (weak, nonatomic) IBOutlet UIImageView * activityImageView  ;

/*
 *
 *  PopView Outlets and Ok Button Action
 *
 */

@property (weak, nonatomic) IBOutlet UIView * popUpContainerView;
@property (weak, nonatomic) IBOutlet UIView * popUpView;
- (IBAction)popUpOkButtonAction:(id)sender;


/*
 *
 *  Public method
 *
 */

-(void)presentImagePicker;
-(void)removeTutorialViewFromMainViewWithAnimation:(NSString *)animation;

@end

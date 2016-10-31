//
//  ResultViewController.m
//  FittedSolution
//
//  Created by Waqar Ali on 02/08/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import "ResultViewController.h"
#import "AppManager.h"
#import "MatchesShoesViewController.h"

@interface ResultViewController ()
{
}
@end

@implementation ResultViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titleLbl.text = @"Swipe left for front view";
    
    /*
     *      Right Swipe Gesture
     */
    
    UISwipeGestureRecognizer * swipeRight           = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightAction)];
    swipeRight.direction                            = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    /*
     *      Left Swipe Gesture
     */
    
    UISwipeGestureRecognizer * swipeLeft            = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftAction)];
    swipeLeft.direction                             = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    /*
     *      Show Foot Size Data
     */
    
    if (_sideFootDescription || _frontFootDescription)
    {
        [self showFootSizeData];
    }
    
    _sideFootImageView.image = self.sideFootCroppedImage;
    
    [self enableRightArrowButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

#pragma marks - Helper Methods

-(void)showSideFootView
{
    self.sideFootView.hidden  = NO  ;
}

-(void)hideSideFootView
{
    self.sideFootView.hidden  = YES ;
}

-(void)showFrontFootView
{
    self.frontFootView.hidden = NO  ;
}

-(void)hideFrontFootView
{
    self.frontFootView.hidden = YES ;
}

-(void)showFootSizeData
{
    if (_frontFootDescription.footWidh.length == 0)
    {
        _footWidthTxt.text          = @"";
        _frontFootViewWidthLbl.text = @"Width";
    }
    else
    {
        _footWidthTxt.text          = [NSString stringWithFormat:@"%.2f\" ",[_frontFootDescription.footWidh floatValue]];
        _frontFootViewWidthLbl.text = [NSString stringWithFormat:@"Width : %.2f\" ",[_frontFootDescription.footWidh floatValue]];
    }
    
    
    if (_sideFootDescription.footLength.length == 0)
    {
        _footlengthTxt.text                 = @"";
        _sideFootViewLengthLbl.text         = @"Length";
    }
    else
    {
        _footlengthTxt.text                 = [NSString stringWithFormat:@"%.2f\"",[_sideFootDescription.footLength floatValue]];
        _sideFootViewLengthLbl.text         = [NSString stringWithFormat:@"Length : %.2f\"",[_sideFootDescription.footLength floatValue]];
    }
    
    if (_sideFootDescription.archHeight.length == 0)
    {
        _archHeightTxt.text                 = @" ";
        _sideFootViewArchLbl.text           = @"Arch Height";
    }
    else
    {
        _archHeightTxt.text                 = [NSString stringWithFormat:@"%.2f\"",[_sideFootDescription.archHeight floatValue]];
        _sideFootViewArchLbl.text           = [NSString stringWithFormat:@"Arch Height : %.2f\"",[_sideFootDescription.archHeight floatValue]];
    }
    
    if (_sideFootDescription.archDistance.length == 0)
    {
        _archDistanceTxt.text               = @" ";
        _sideFootViewArchDistanceLbl.text   = @"Arch Distance";
    }
    else
    {
        _archDistanceTxt.text               = [NSString stringWithFormat:@"%.2f\"",[_sideFootDescription.archDistance floatValue]];
        _sideFootViewArchDistanceLbl.text   = [NSString stringWithFormat:@"Arch Distance : %.2f\"",[_sideFootDescription.archDistance floatValue]];
    }
    
    if (_sideFootDescription.talusHeight.length == 0)
    {
        _talusHeightTxt.text                = @" ";
        _sideFootViewTalusHeightLbl.text    = @"Talus Height";
    }
    else
    {
        _talusHeightTxt.text                = [NSString stringWithFormat:@"%.2f\"",[_sideFootDescription.talusHeight floatValue]];
        _sideFootViewTalusHeightLbl.text    = [NSString stringWithFormat:@"Talus Height : %.2f\"",[_sideFootDescription.talusHeight floatValue]];
    }
    
    
    if (_sideFootDescription.toeBoxHeight.length == 0)
    {
        _toeBoxHeightTxt.text               = @" ";
        _sideFootViewToeHeightLbl.text      = @"Toe Height";
    }
    else
    {
        _toeBoxHeightTxt.text               = [NSString stringWithFormat:@"%.2f\"",[_sideFootDescription.toeBoxHeight floatValue]];
        _sideFootViewToeHeightLbl.text      = [NSString stringWithFormat:@"Toe Height : %.2f\"",[_sideFootDescription.toeBoxHeight floatValue]];
    }
    
    
    if (_sideFootDescription.talusSlope.length == 0)
    {
        _talusSlopeTxt.text                 = @" ";
        _sideFootViewSlopeLbl.text          = @"Talus Slope";
    }
    else
    {
        _talusSlopeTxt.text                 = [NSString stringWithFormat:@"%.2f",[_sideFootDescription.talusSlope floatValue]];
        _sideFootViewSlopeLbl.text          = [NSString stringWithFormat:@"Talus Slope %.2f",[_sideFootDescription.talusSlope floatValue]];
    }
    
    ////
    
    if (_sideFootDescription.men_US)
    {
        if ([_sideFootDescription.men_US isEqualToString:@"Over Size"] || [_sideFootDescription.men_US isEqualToString:@"Under Size"])
        {
            _mensUSLblTxt.text              =  _sideFootDescription.men_US;
        }
        else
        {
            if (_frontFootDescription.menWidthCode)
            {
                _mensUSLblTxt.text          =  [NSString stringWithFormat:@"%.1f  %@",[_sideFootDescription.men_US floatValue],_frontFootDescription.menWidthCode];
            }
            else
            {
                _mensUSLblTxt.text          =  [NSString stringWithFormat:@"%.1f",[_sideFootDescription.men_US floatValue]];
                
                if ([app_manager text:_sideFootDescription.men_US containsString:@"/"])
                {
                    _mensUSLblTxt.text      = _sideFootDescription.men_US;
                }
            }
        }
    }
    if (_sideFootDescription.men_Euro)
    {
        if ([_sideFootDescription.men_Euro isEqualToString:@"Over Size"] || [_sideFootDescription.men_Euro isEqualToString:@"Under Size"])
        {
            _mensEuroLblTxt.text            =  _sideFootDescription.men_Euro;
        }
        else
        {
            _mensEuroLblTxt.text            = [NSString stringWithFormat:@"%.1f",[_sideFootDescription.men_Euro floatValue]];
            
            if ([app_manager text:_sideFootDescription.men_Euro containsString:@"/"])
            {
                _mensEuroLblTxt.text        = _sideFootDescription.men_Euro;
            }
        }
    }
    if (_sideFootDescription.men_UK)
    {
        if ([_sideFootDescription.men_UK isEqualToString:@"Over Size"] || [_sideFootDescription.men_UK isEqualToString:@"Under Size"])
        {
            _mensUKLblTxt.text              =  _sideFootDescription.men_UK;
        }
        else
        {
            _mensUKLblTxt.text              = [NSString stringWithFormat:@"%.1f",[_sideFootDescription.men_UK floatValue]];
            
            if ([app_manager text:_sideFootDescription.men_UK containsString:@"/"])
            {
                _mensUKLblTxt.text          = _sideFootDescription.men_UK;
            }
        }
    }
    if (_sideFootDescription.women_US)
    {
        if ([_sideFootDescription.women_US isEqualToString:@"Over Size"] || [_sideFootDescription.women_US isEqualToString:@"Under Size"])
        {
            _womensLblTxt.text              =  _sideFootDescription.women_US;
        }
        else
        {
            if (_frontFootDescription.womenWidthCode)
            {
                _womensLblTxt.text          =  [NSString stringWithFormat:@"%.1f  %@",[_sideFootDescription.women_US floatValue], _frontFootDescription.womenWidthCode];
            }
            else
            {
                _womensLblTxt.text          =  [NSString stringWithFormat:@"%.1f",[_sideFootDescription.women_US floatValue]];
                
                if ([app_manager text:_sideFootDescription.women_US containsString:@"/"])
                {
                    _womensLblTxt.text      = _sideFootDescription.women_US;
                }
            }
        }
    }
    if (_sideFootDescription.women_Euro)
    {
        if ([_sideFootDescription.women_Euro isEqualToString:@"Over Size"] || [_sideFootDescription.women_Euro isEqualToString:@"Under Size"])
        {
            _womensEuroLblTxt.text          =  _sideFootDescription.women_Euro;
        }
        else
        {
            _womensEuroLblTxt.text          =  [NSString stringWithFormat:@"%.1f",[_sideFootDescription.women_Euro floatValue]];
            
            if ([app_manager text:_sideFootDescription.women_Euro containsString:@"/"])
            {
                _womensEuroLblTxt.text      = _sideFootDescription.women_Euro;
            }
        }
    }
    if (_sideFootDescription.women_UK)
    {
        if ([_sideFootDescription.women_UK isEqualToString:@"Over Size"] || [_sideFootDescription.women_UK isEqualToString:@"Under Size"])
        {
            _womenUKLblTxt.text             =  _sideFootDescription.women_UK;
        }
        else
        {
            _womenUKLblTxt.text             =  [NSString stringWithFormat:@"%.1f",[_sideFootDescription.women_UK floatValue]];
            
            if ([app_manager text:_sideFootDescription.women_UK containsString:@"/"])
            {
                _womenUKLblTxt.text         = _sideFootDescription.women_UK;
            }
        }
    }
}

#pragma mark - Swipe Gesture Actions

-(void)swipeRightAction
{
    _sideFootImageView.image    =    self.sideFootCroppedImage;
    
    [self enableRightArrowButton];
    
    [self showSideFootView];
    [self hideFrontFootView];
}

-(void)swipeLeftAction
{
    _frontFootImageView.image   =     self.frontFootCroppedImage;
    
    [self enableLeftArrowButton];
    
    [self showFrontFootView];
    [self hideSideFootView];
}

-(void)enableRightArrowButton
{
    [_leftArrowBtn setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
    _leftArrowBtn.userInteractionEnabled = NO;
    
    [_rightArrowBtn setImage:[UIImage imageNamed:@"RightArrowON"] forState:UIControlStateNormal];
    _rightArrowBtn.userInteractionEnabled = YES;
}

-(void)enableLeftArrowButton
{
    [_leftArrowBtn setImage:[UIImage imageNamed:@"LeftArrowON"] forState:UIControlStateNormal];
    _leftArrowBtn.userInteractionEnabled = YES;
    
    [_rightArrowBtn setImage:[UIImage imageNamed:@"RightArrowOFF"] forState:UIControlStateNormal];
    _rightArrowBtn.userInteractionEnabled = NO;
}

#pragma mark - Button Actions

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)rightArrowAction:(id)sender
{
    [self swipeLeftAction];
}

- (IBAction)leftArrowAction:(id)sender
{
    [self swipeRightAction];
}

- (IBAction)shoePredictorButtonAction:(id)sender
{
    MatchesShoesViewController  *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MatchesShoesViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
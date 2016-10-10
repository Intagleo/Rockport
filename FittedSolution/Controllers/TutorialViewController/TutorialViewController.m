//
//  TutorialViewController.m
//  FittedSolution
//
//  Created by Waqar Ali on 15/09/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import "TutorialViewController.h"
#import "AppManager.h"
#import "TextToSpeechManager.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setPagesInScrollView];
    [self readInstructionsOfPage:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)setPagesInScrollView
{
    NSArray * pages = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"tutorialScreen1.jpg"],[UIImage imageNamed:@"tutorialScreen2.jpg"],
                         [UIImage imageNamed:@"tutorialScreen3.jpg"],[UIImage imageNamed:@"tutorialScreen4.jpg"],
                         [UIImage imageNamed:@"tutorialScreen5.jpg"],[UIImage imageNamed:@"tutorialScreen6.jpg"],
                         [UIImage imageNamed:@"tutorialScreen7.jpg"],[UIImage imageNamed:@"tutorialScreen8.jpg"],
                         [UIImage imageNamed:@"tutorialScreen9.jpg"],[UIImage imageNamed:@"tutorialScreen10.jpg"],
                         [UIImage imageNamed:@"tutorialScreen11.jpg"],[UIImage imageNamed:@"tutorialScreen12.jpg"],
                         [UIImage imageNamed:@"tutorialScreen13.jpg"],nil];
    
    self.scrollView.delegate                       = self;
    self.scrollView.pagingEnabled                  = YES;
    self.scrollView.bounces                        = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator   = NO;
    self.pageControl.numberOfPages                 = pages.count;
    self.pageControl.currentPage                   = 0;
    
    for(int i=0; i < pages.count; i++)
    {
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size     = self.scrollView.frame.size;
        
        UIImageView * tutorialImageView    = [[UIImageView alloc] initWithFrame:frame];
        tutorialImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tutorialImageView.image            = [pages objectAtIndex:i];
        [self.scrollView addSubview:tutorialImageView];
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * pages.count, self.scrollView.frame.size.height);
}

-(void) readInstructionsOfPage:(int)page
{
    if (text_to_speech_manager.isSpeaking)
    {
        [text_to_speech_manager stopSpeaking];
    }
    
    if (page == 0)
    {
        [text_to_speech_manager readText:@"welcome to fitted solutions" afterDelay:0.0];
    }
    else if (page == 1)
    {
        [text_to_speech_manager readText:@"you are now just two clicks away from a perfect fit" afterDelay:0.0];
    }
    else if (page == 2)
    {
        [text_to_speech_manager readText:@"let's get fitted" afterDelay:0.0];
    }
    else if (page == 3)
    {
        [text_to_speech_manager readText:@"you will need to remove your shoes and socks" afterDelay:0.0];
    }
    else if (page == 4)
    {
        [text_to_speech_manager readText:@"you will need to remove the cover from your cell phone" afterDelay:0.0];
    }
    else if (page == 5)
    {
        [text_to_speech_manager readText:@"finally you will need a mirror to take a selfie in a well lit area" afterDelay:0.0];
    }
    else if (page == 6)
    {
        [text_to_speech_manager readText:@"ready" afterDelay:0.0];
    }
    else if (page == 7)
    {
        [text_to_speech_manager readText:@"when you are ready take a mirrored selfie of the inside of right foot by saying capture" afterDelay:0.0];
    }
    else if (page == 8)
    {
        [text_to_speech_manager readText:@"how to take a great side foot picture, position your foot about 10 to 20 inches from the mirror, try to keep your foot and phone parallel to the mirror, it's ok if this is not perfect just do your best, hold the phone right over the edge of your foot as shown" afterDelay:0.0];
    }
    else if (page == 9)
    {
        [text_to_speech_manager readText:@"help us get the best measurements we can, remember to take the cover off and hold the camera sideways, we'd like to see the four corners and as much of the edges of the phone as we can, the most important thing you can do is to hold the phone right above your foot" afterDelay:0.0];
    }
    else if (page == 10)
    {
        [text_to_speech_manager readText:@"next take a picture of the front of the foot when ready say capture, keep phone parallel to mirror" afterDelay:0.0];
    }
    else if (page == 11)
    {
        [text_to_speech_manager readText:@"how to take a great front foot picture, point your foot directly at the mirror, place your foot about 10 to 20 inches from the mirror, place your smart phone directly over the widest part of your foot, try to keep the phone parralel to the mirror, just do your best" afterDelay:0.0];
    }
    else if (page == 12)
    {
        [text_to_speech_manager readText:@"it's the same routine for the front foot, hold the smart phone sideways over the widest part of your foot, and try to get all four corners and as much of the edges in the image as you can" afterDelay:0.0];
    }
}

#pragma mark - UIScrollView

-(void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page          = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    if(page == 12)
    {
        self.getStartedBtn.hidden = NO;
    }
    else
    {
        self.getStartedBtn.hidden = YES;
    }
    
    [self readInstructionsOfPage:page];
}

#pragma mark - Button Action

- (IBAction)skipTutorialAction:(id)sender
{
    if (text_to_speech_manager.isSpeaking)
    {
        [text_to_speech_manager stopSpeaking];
    }
    
    [app_manager removeTutorialViewFromMainViewWithAnimation:@"bottom"];
}

- (IBAction)getStartedAction:(id)sender
{
    if (text_to_speech_manager.isSpeaking)
    {
        [text_to_speech_manager stopSpeaking];
    }
    
    [app_manager removeTutorialViewFromMainViewWithAnimation:@"left"];
}

@end

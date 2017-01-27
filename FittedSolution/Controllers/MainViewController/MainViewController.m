//
//  MainViewController.m
//  FittedSolution
//
//  Created by Waqar Ali on 05/07/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import "MainViewController.h"
#import "LinuxWebserviceManager.h"
#import "WindowsWebserviceManager.h"
#import "LinuxServerResponseHandler.h"
#import "FootDescription.h"
#import "AppManager.h"
#import "ResultViewController.h"
#import "TextToSpeechManager.h"
#import "TutorialViewController.h"
#import "CacheManager.h"
#import "AppDelegate.h"

#import "CustomView.h"

#define kSideFoot  @"side"
#define kFrontFoot @"front"
#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

@interface MainViewController ()
{
    int steppCount;
    
    bool picCaptured;
    bool progressStatusLabelShouldShow;

    NSString                 * labelToanimateWithDot                        ;
    NSTimer                  * statusLabelAimateTimer                       ;
    NSTimer                  * countDownTimer                               ;
    UIView                   * countDownView                                ;
    UILabel                  * countDownLabel                               ;
    int                        remainingCounts                              ;
    
    UIImagePickerController  * imagePicker                                  ;
    UIImage                  * capturedSidePhoto                            ;
    NSData                   * capturedSidePhotoData                        ;
    
    UIImage                  * capturedFrontPhoto                           ;
    NSData                   * capturedFrontPhotoData                       ;

    BOOL                       isLinuxServerCallForSideFootInProgress       ;
    BOOL                       isLinuxServerCallForFrontFootInProgress      ;
    BOOL                       isWindowsServerCallForSideFootInProgress     ;
    BOOL                       isWindowsServerCallForFrontFootInProgress    ;
    
    BOOL                       isWaitingForSideFootWindowsServerResponse    ;
    BOOL                       isSideFootErrorAppeared                      ;
    BOOL                       isFrontFootErrorAppeared                     ;
    NSString                 * sideFootErrorString                          ;
    NSString                 * frontFootErrorString                         ;
    BoundedBox                 frontFootBoundedBox_Cached                   ;
    BoundedBox                 frontFootPhoneBoundedBox_Cached              ;
    NSData                   * frontFootImageData_Cached                    ;
}

@property(nonatomic,assign) BOOL isHaar;

@property (nonatomic, strong) UIView            * tutorialViewContainer             ;
@property (nonatomic, strong) UIImage           * sideFootBoundedBoxCroppedImage    ;
@property (nonatomic, strong) UIImage           * frontFootBoundedBoxCroppedImage   ;
@property (strong, nonatomic) FootDescription   * sideFootDescription               ;
@property (strong, nonatomic) FootDescription   * frontFootDescription              ;

@end

@implementation MainViewController

@synthesize step;


//-(void)testCall
//{
//    NSData *side = UIImageJPEGRepresentation([UIImage imageNamed:@"blue.jpg"], 0.2)  ;
//    NSData *front = UIImageJPEGRepresentation([UIImage imageNamed:@"blue.jpg"], 0.2) ;
//    
//    [linux_webservice_manager validateSideFootImage:side andFrontFootImage:front block:^(NSData *data)
//    {
//        NSString     * responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//        NSLog(@"asd : %@",responseString);
//    }
//    errorMessage:^(NSError *error)
//    {
//        
//    }];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _progressSatusLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MainScreenBackground"]];
    _isHaar = false;
    _segmentControl.selectedSegmentIndex = 1;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    [self setUpCountDown];
    
    steppCount = 0;
    
    step                           = StepOne;
    app_manager.rootViewController = self;
    
    [text_to_speech_manager setUp];
    
    if (![cache_manager isAppAlreadyLaunched])
    {
        [self showTutorialViewAsSubView];
        [cache_manager saveAppLaunched];
    }
    else
    {
        [text_to_speech_manager readText:@"welcome to fitted solution, tap on info for app instructions." afterDelay:0.0];
    }
    
    //[self setUpSpeechRecognition]; //voice1122
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

#pragma mark - buttons action

- (IBAction)menuButtonAction:(id)sender
{
    [self showTutorialViewAsSubView];
}

- (IBAction)infoButtonAction:(id)sender
{
    if (![text_to_speech_manager isSpeaking])
    {
        [text_to_speech_manager readText:@"take mirror selfie of your foot in two steps." afterDelay:0.0];
        [text_to_speech_manager readText:@"step1 : take side snap of your foot"           afterDelay:0.3];
        [text_to_speech_manager readText:@"step2 : take front snap of your foot"          afterDelay:0.3];
    }
}

- (IBAction)cameraButtonAction:(id)sender
{
    if ([text_to_speech_manager isSpeaking])
    {
        [text_to_speech_manager stopSpeaking];
    }
    
    if ([app_manager isInternetAvailable])
    {
        [self presentImagePicker];
    }
    else
    {
        [app_manager showAlertForInternetErrorWithTitle:@"Internet Connection Is Required" Message:@"You are not connected to the internet. Please connect to the internet and then try again."];
    }
}

- (IBAction)resetButtonAction:(id)sender
{
    [app_manager showResetAlertWithTitle:@"" Message:@"Are you sure you want to start over?"];
}

- (IBAction)popUpOkButtonAction:(id)sender
{
}

- (IBAction)segmentDidChange:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        _isHaar = YES;
        app_manager.is_Haar = YES;
    }
    else
    {
        _isHaar = NO;
        app_manager.is_Haar = NO;
    }
}

#pragma mark - SpeechRecognitionManagerDelegate

-(void)pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID
{
    //NSLog(@"%@ recognised ",hypothesis);
    
    if ([hypothesis isEqualToString:@"capture"])
    {
        _resetButton.hidden = NO;
        //[imagePicker takePicture];  //voice1122
    }
}

#pragma mark - UIImagePickerControllerDelegate

-(UIImage *)screenshot
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"1--> Image Captured --------------------------------------------");
    
    [self setCameraViewToCoverFullScreen];
    [self removeCountDownView];
    
    NSLog(@"2--> Camera disappeared --------------------------------------------");
    
    [picker dismissViewControllerAnimated:YES completion:^{
        //[self stopListeningClickVoice];  //voice1122
    }];
    
    if ([app_manager isInternetAvailable])
    {
        //[app_manager startAnimatingActivityIndicator]; //1122
    
        UIImage * imageTaken      = [app_manager fixRotation:[info objectForKey:UIImagePickerControllerOriginalImage]];
      
        _resetButton.hidden   = NO;

        if (step == StepOne || step == StepOneRepeat)
        {
            capturedSidePhoto             = [app_manager compressImage:imageTaken];
            capturedSidePhotoData         = [app_manager addPhoneModelAndNameToImageMetaData:capturedSidePhoto];
            
            if (_isHaar) {
                [self validateHAARSideFootImage:capturedSidePhotoData];
            }else{
                [self validateSideFootImage:capturedSidePhotoData];
            }
        }
        else if(step == StepTwo || step == StepTwoRepeat)
        {
            capturedFrontPhoto             = [app_manager compressImage:imageTaken];
            capturedFrontPhotoData         = [app_manager addPhoneModelAndNameToImageMetaData:capturedFrontPhoto];
            
            if (_isHaar) {
                [self validateHAARFrontFootImage:capturedFrontPhotoData];
            }else{
                [self validateFrontFootImage:capturedFrontPhotoData];
            }
        }
    }
    else
    {
        [app_manager showAlertForInternetErrorWithTitle:@"Internet Connection Error" Message:@"You are not connected to the internet. Please connect to the internet and then try again."];
    }
}

#pragma mark - helper methods

-(void)showTutorialViewAsSubView
{
    TutorialViewController * tutorialViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]  instantiateViewControllerWithIdentifier:@"TutorialViewController"];
    self.tutorialViewContainer                      = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self addChildViewController:tutorialViewController];
    [self.tutorialViewContainer addSubview:tutorialViewController.view];
    
    [self.view addSubview:self.tutorialViewContainer];
}

-(void)removeTutorialViewFromMainViewWithAnimation:(NSString *)animation
{
    if ([animation isEqualToString:@"bottom"])
    {
        [UIView animateWithDuration:0.3/1.5 animations:^
         {
             self.tutorialViewContainer.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
         }
         completion:^(BOOL finished)
         {
             [self.tutorialViewContainer removeFromSuperview];
         }];
    }
    else
    {
        [UIView animateWithDuration:0.3/1.5 animations:^
         {
             self.tutorialViewContainer.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
         }
         completion:^(BOOL finished)
         {
             [self.tutorialViewContainer removeFromSuperview];
         }];
    }
}

-(void)initImagePicker
{
    imagePicker                          = [[UIImagePickerController alloc] init];
    imagePicker.delegate                 = self;
    imagePicker.sourceType               = UIImagePickerControllerSourceTypeCamera;
    
    if (_isHaar)
    {
        imagePicker.cameraDevice         = UIImagePickerControllerCameraDeviceRear;
    }
    else
    {
        imagePicker.cameraDevice         = UIImagePickerControllerCameraDeviceFront;
    }
    
    imagePicker.showsCameraControls      = NO;
    imagePicker.cameraFlashMode          = UIImagePickerControllerCameraFlashModeOff;
    imagePicker.allowsEditing            = NO;
}

-(void)showProgressStatusWithLabel:(NSString *)label
{
    if (progressStatusLabelShouldShow)
    {
        if (statusLabelAimateTimer)
        {
            [statusLabelAimateTimer invalidate];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.cameraButton.userInteractionEnabled   = NO;
            self.menuButton.userInteractionEnabled     = NO;
            self.infoButton.userInteractionEnabled     = NO;
            self.segmentControl.userInteractionEnabled = NO;
            
            labelToanimateWithDot = label;
            [self animateProgressStausWithLabel:label];
            
            self.progressSatusLabel.text = label;
            self.progressSatusLabel.hidden = NO;
        });
    }
}

-(void)hideProgressStatusLabel
{
    [statusLabelAimateTimer invalidate];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.cameraButton.userInteractionEnabled   = YES;
        self.menuButton.userInteractionEnabled     = YES;
        self.infoButton.userInteractionEnabled     = YES;
        self.segmentControl.userInteractionEnabled = YES;
        
        self.progressSatusLabel.hidden = YES;
    });
}

-(void)showProgressViewWithProgress:(NSString *)progress
{
    if (progressStatusLabelShouldShow)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.hidden = NO;
            [self.progressView setProgress:[progress floatValue] animated:true];
        });
    }
}

-(void)hideProgressView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.hidden = YES;
        self.progressView.progress = 0.0;
    });
}

int dotCount;

-(void)animateProgressStausWithLabel:(NSString *)label
{
    statusLabelAimateTimer = [NSTimer scheduledTimerWithTimeInterval:0.4
                                                      target:self
                                                    selector:@selector(animateLabel)
                                                    userInfo:nil
                                                    repeats:YES];
    dotCount = 0;
}

-(void)animateLabel
{
    if (dotCount == 0)
    {
        self.progressSatusLabel.text = [NSString stringWithFormat:@"%@",labelToanimateWithDot];
        dotCount = 1;
    }
    else if (dotCount == 1)
    {
        self.progressSatusLabel.text = [NSString stringWithFormat:@"%@.",labelToanimateWithDot];
        dotCount = 2;
    }
    else if (dotCount == 2)
    {
        self.progressSatusLabel.text = [NSString stringWithFormat:@"%@..",labelToanimateWithDot];
        dotCount = 3;
    }
    else if (dotCount == 3)
    {
        self.progressSatusLabel.text = [NSString stringWithFormat:@"%@...",labelToanimateWithDot];
        dotCount = 0;
    }
}

-(void)dismissImagePickerController
{
//    if (imagePicker.isBeingPresented)
//    {
//        if([text_to_speech_manager isSpeaking])
//        {
//            [text_to_speech_manager stopSpeaking];
//        }
//    
//        [imagePicker dismissViewControllerAnimated:YES completion:^
//        {
//            if ([speech_recognition_manager isListening])
//            {
//                [self stopListeningClickVoice];
//            }
//        }];
//    }
}

-(void)presentImagePicker
{
    switch (step)
    {
        case StepOne:
            [self setUpImagePickerForStep:1];
            break;
            
        case StepOneRepeat:
            [self setUpImagePickerForStep:1];
            break;
            
        case StepTwo:
            [self setUpImagePickerForStep:2];
            break;
            
        case StepTwoRepeat:
            [self setUpImagePickerForStep:2];
            break;
            
        default:
            [self setUpImagePickerForStep:1];
            break;
    }
    
    [self presentImagePickerController];
}

-(void)setUpImagePickerForStep:(int)stepNo
{
    if (imagePicker)
    {
        imagePicker = nil;
    }
    
    [self initImagePicker];

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    CGAffineTransform translate          = CGAffineTransformMakeTranslation(0.0, 71.0);                     //
//    imagePicker.cameraViewTransform      = translate;                                                       //
//    CGAffineTransform scale              = CGAffineTransformScale(translate, 1.333333, 1.333333);           //
//    imagePicker.cameraViewTransform      = scale;                                                           //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    UIView      * pickerHeader           = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    pickerHeader.autoresizingMask        = UIViewAutoresizingFlexibleWidth;
    
    UIImageView * headerImageView;
    
    if (stepNo == 1)
    {
        headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Step1"]];
    }
    else
    {
        headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Step2"]];
    }
    headerImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    [pickerHeader addSubview:headerImageView];
    [imagePicker.view addSubview:pickerHeader];
}

-(void) setCameraViewToCoverFullScreen
{
    CGSize screenBounds = [UIScreen mainScreen].bounds.size;
    CGFloat cameraAspectRatio = 4.0f/3.0f;
    CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
    CGFloat scale = screenBounds.height / camViewHeight;
    imagePicker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
    imagePicker.cameraViewTransform = CGAffineTransformScale(imagePicker.cameraViewTransform, scale, scale);
}

-(void)presentImagePickerController
{
    //[self performSelectorInBackground:@selector(startListeningClick_Voice) withObject:nil];  //voice1122
    
    [self setCameraViewToCoverFullScreen];
    [self presentViewController:imagePicker animated:YES completion:^
    {
        if ([[app_manager getDeviceiOSVersion] floatValue] >= 10)
        {
            [imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
            [self setCameraViewToCoverFullScreen];
        }
        
        //[app_manager stopAnimatingActivityIndicator]; //1122
        
        /*
         *          Add Locate Phone Icon On Camera
         */
        
        UIImageView * phoneIcon   = [[UIImageView alloc]init];
        phoneIcon.image           = [UIImage imageNamed:@"LocateIconForPhone"];
        
        [imagePicker.view addSubview:phoneIcon];
        
        
        /*
         *          Add Phone Label On Camera
         */
        
        UILabel * phoneLbl           = [[UILabel alloc] init];
        phoneLbl.font                = [UIFont systemFontOfSize:11.0];
        phoneLbl.textColor           = [UIColor blackColor];
        phoneLbl.backgroundColor     = [UIColor whiteColor];
        phoneLbl.numberOfLines       = 1;
        phoneLbl.textAlignment       = NSTextAlignmentCenter;
        phoneLbl.text                = @"LOCATE ICON ON THE SMART PHONE" ;
        
        [app_manager makeCircularView:phoneLbl withCornerRadius:5.0f];
        [imagePicker.view addSubview:phoneLbl];
        
        
        /*
         *          Add Locate Foot Icon On Camera
         */
        
        UIImageView * footIcon   = [[UIImageView alloc] init];
        footIcon.image           = [UIImage imageNamed:@"LocateIconForFoot"];
        
        [imagePicker.view addSubview:footIcon];
        
        
        /*
         *          Add Foot Label On Camera
         */
        
        UILabel *footLbl            = [[UILabel alloc]init];
        footLbl.font                = [UIFont systemFontOfSize:11.0];
        footLbl.textColor           = [UIColor blackColor];
        footLbl.backgroundColor     = [UIColor whiteColor];
        footLbl.numberOfLines       = 1;
        footLbl.textAlignment       = NSTextAlignmentCenter;
        footLbl.text                = @"LOCATE ICON ON THE FOOT" ;
  
        [app_manager makeCircularView:footLbl withCornerRadius:5.0f];
        [imagePicker.view addSubview:footLbl];
        
        
        /*
         *          Add Back Button on camera
         */
        
        UIButton * backbtn       = [[UIButton alloc] init];
        UIImage  * backImage     = [UIImage imageNamed:@"BackWhite"];
        backbtn.frame            = CGRectMake(8,27, 40, 25);
        backbtn.backgroundColor  = [UIColor clearColor];
        [backbtn setImage:backImage forState:UIControlStateNormal];
        [backbtn addTarget:self action:@selector(cameraBackButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        [imagePicker.view addSubview:backbtn];
        
        
        /*
         *          Add Image Picker Button on camera
         */
        
        CustomView * cameraUpperLayer            = [[CustomView alloc] init];
        cameraUpperLayer.frame                   = CGRectMake(0,80, self.view.frame.size.width, self.view.frame.size.height-65);
        cameraUpperLayer.cameraPreviewUpperLayer = cameraUpperLayer;
        [imagePicker.view addSubview:cameraUpperLayer];
        [cameraUpperLayer baseInitWithCameraViewTouchedCallBack:^()
        {
            if (!picCaptured)
            {
                picCaptured = true;
                [self performSelector:@selector(showCountDownView) withObject:self afterDelay:0.0];
            }
        }];
        
        if (isiPhone5 || isiPhone4Or4s)
        {
            phoneIcon.frame              =  CGRectMake(230, 230, 26, 26);
            phoneIcon.transform          =  CGAffineTransformMakeRotation (3.14/2);

            phoneLbl.frame               =  CGRectMake(139, 366, 208, 14);
            phoneLbl.transform           =  CGAffineTransformMakeRotation (3.14/2);

            footIcon.frame               =  CGRectMake(110, 180, 26, 26);
            footIcon.transform           =  CGAffineTransformMakeRotation (3.14/2);

            footLbl.frame                =  CGRectMake(45, 290, 157, 14);
            footLbl.transform            =  CGAffineTransformMakeRotation (3.14/2);
        }
        else  // for iphone 6 and 6s+
        {
            phoneIcon.frame              =  CGRectMake(300, 300, 26, 26);
            phoneIcon.transform          =  CGAffineTransformMakeRotation (3.14/2);
            
            phoneLbl.frame               =  CGRectMake(209, 436, 208, 14);
            phoneLbl.transform           =  CGAffineTransformMakeRotation (3.14/2);
            
            footIcon.frame               =  CGRectMake(110, 240, 26, 26);
            footIcon.transform           =  CGAffineTransformMakeRotation (3.14/2);
            
            footLbl.frame                =  CGRectMake(45, 350, 157, 14);
            footLbl.transform            =  CGAffineTransformMakeRotation (3.14/2);
        }
    }];
}

-(void)cameraBackButtonAction
{
    [self dismissViewControllerAnimated:YES completion:^
    {
        //[self stopListeningClickVoice];  //voice1122
        
        if (step == StepOne || step == StepOneRepeat)
        {
            _resetButton.hidden = YES;
        }
        else
        {
            _resetButton.hidden = NO;
        }
        
        //[app_manager stopAnimatingActivityIndicator]; //1122
    }];
}

-(void)showCountDownView
{
    countDownLabel.text = [NSString stringWithFormat:@"%d", 3];
    [imagePicker.view addSubview:countDownView];
    [self startCountDown];
}

-(void)removeCountDownView
{
    picCaptured = false;
    
    [countDownView removeFromSuperview];
}

-(void)setUpCountDown
{
    countDownView  = [[UIView alloc] initWithFrame:self.view.bounds];
    countDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
    countDownLabel.center = countDownView.center;
    countDownLabel.textAlignment   = NSTextAlignmentCenter;
    countDownLabel.backgroundColor = [UIColor clearColor];
    countDownLabel.transform       =  CGAffineTransformMakeRotation (3.14/2);
    
    UIFont *font        = [UIFont systemFontOfSize:70.0];
    countDownLabel.font = font;
    [countDownView addSubview:countDownLabel];
}

-(void)startCountDown
{
    countDownView.backgroundColor = [UIColor clearColor];
    countDownLabel.textColor =  [UIColor colorWithRed:0.00 green:0.00 blue:0.40 alpha:1.00];
    
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(countDown)
                                                    userInfo:nil
                                                     repeats:YES];
    
    remainingCounts = 3;
}

-(void)countDown
{
    remainingCounts = remainingCounts - 1;
    countDownLabel.text = [NSString stringWithFormat:@"%d",remainingCounts];
    
    if (remainingCounts == 0)
    {
        [countDownTimer invalidate];
        remainingCounts = 3;
        
        countDownView.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.40 alpha:1.00];
        countDownLabel.textColor = [UIColor whiteColor];
        
        countDownLabel.text = @"Captured";
        NSLog(@"0--> Captured Label Appeared --------------------------------------------");
        
        [self performSelector:@selector(capture) withObject:self afterDelay:0.75];
    }
}

-(void)capture
{
    [imagePicker takePicture];
}

-(void)setUpSpeechRecognition
{
    speech_recognition_manager.delegate = self;
    [speech_recognition_manager setUpSpeechRecognition];
}

-(void)startListeningClick_Voice
{
    [speech_recognition_manager startListeningClickVoice];
}

-(void)stopListeningClickVoice
{
    [speech_recognition_manager stopListeningClickVoice];
}

-(void)cropImage:(UIImage *)image withRect:(CGRect)rect forFoot:(NSString *)foot
{
    if ([foot isEqualToString:kSideFoot])
    {
        _sideFootBoundedBoxCroppedImage  = [image croppedImage:rect];
    }
    else if ([foot isEqualToString:kFrontFoot])
    {
        _frontFootBoundedBoxCroppedImage = [image croppedImage:rect];
    }
    else
    {
        return;
    }
}

-(void)validateSideFootImage:(NSData *)sideFootImageData
{
    progressStatusLabelShouldShow = true;
    
    [self showProgressViewWithProgress:@"0.1"];
    [self showProgressStatusWithLabel:@"Image being uploaded"];
    [self performSelector:@selector(showProgressViewWithProgress:) withObject:@"0.3" afterDelay:4.8];
    
    [self performSelector:@selector(showProgressStatusWithLabel:) withObject:@"Image processing" afterDelay:4.0];
    [self performSelector:@selector(showProgressViewWithProgress:) withObject:@"0.7" afterDelay:9.8];
    
    [self performSelector:@selector(showProgressStatusWithLabel:) withObject:@"Side foot being measured" afterDelay:10.0];
    
    [linux_webservice_manager validateSideFootImage:sideFootImageData block:^(NSData *data)
     {
         if(!data)
         {
             progressStatusLabelShouldShow = false;
             [self hideProgressStatusLabel];
             [self hideProgressView];
             
             step = StepOneRepeat;
             [app_manager showAlertWithTitle:@"Error" Message:@"Unable to get response from server. Please retake side foot picture." andAction:PresentImagePicker];
         }
         else
         {
             [linux_server_response_handler handleResponseForSideFoot:data block:^(FootDescription *sideFootDescription)
              {
                  [self showProgressViewWithProgress:@"1.0"];
                  progressStatusLabelShouldShow = false;
                  [self hideProgressView];
                  [self hideProgressStatusLabel];
                  
                  // show alert
                  [app_manager showMeasuredPopup];
                  
                  self.sideFootDescription = sideFootDescription;
                  
                  step = StepTwo;
                  [self presentImagePicker];
              }
              errorMessage:^(NSString * errorString)
              {
                  NSLog(@"Linux server,(Side foot) Error %@ ",errorString);
                  
                  progressStatusLabelShouldShow = false;
                  [self hideProgressStatusLabel];
                  [self hideProgressView];
                  
                  step              = StepOneRepeat;
                  NSString *message = [NSString stringWithFormat:@"%@ Please retake side foot picture.",errorString];
                  [app_manager showAlertWithTitle:@"" Message:message andAction:PresentImagePicker];
              }];
         }
     }
     errorMessage:^(NSError *error)
     {
         NSLog(@"Linux server,(Side foot) Error%@ ",error);
         progressStatusLabelShouldShow = false;
         [self hideProgressStatusLabel];
         [self hideProgressView];
         step              = StepOneRepeat;
         [app_manager handleError:error];
     }];
}

-(void)validateFrontFootImage:(NSData *)frontFootImageData
{
    progressStatusLabelShouldShow = true;
    
    [self showProgressViewWithProgress:@"0.1"];
    [self showProgressStatusWithLabel:@"Image being uploaded..."];
    
    [self performSelector:@selector(showProgressStatusWithLabel:) withObject:@"Image processing" afterDelay:4.0];
    [self performSelector:@selector(showProgressViewWithProgress:) withObject:@"0.3" afterDelay:4.8];
    
    [self performSelector:@selector(showProgressStatusWithLabel:) withObject:@"Front foot being measured" afterDelay:10.0];
    [self performSelector:@selector(showProgressViewWithProgress:) withObject:@"0.7" afterDelay:9.8];
    
    [self performSelector:@selector(showProgressStatusWithLabel:) withObject:@"Results being analyzed" afterDelay:12.0];
    [self performSelector:@selector(showProgressViewWithProgress:) withObject:@"0.8" afterDelay:12.0];
    
    NSString *sideFootLength = _sideFootDescription.footLength;
    
    [linux_webservice_manager validateFrontFootImage:frontFootImageData withSideFootLength:sideFootLength block:^(NSData *data)
     {
         if(!data)
         {
             progressStatusLabelShouldShow = false;
             [self hideProgressStatusLabel];
             [self hideProgressView];
             
             step = StepTwoRepeat;
             [app_manager showAlertWithTitle:@"Error" Message:@"Unable to get response from server. Please retake front foot picture." andAction:PresentImagePicker];
         }
         else
         {
             [linux_server_response_handler handleResponseForFrontFoot:data block:^(FootDescription *frontFootDescription)
              {
                  [self showProgressViewWithProgress:@"1.0"];
                  progressStatusLabelShouldShow = false;
                  [self hideProgressView];
                  [self hideProgressStatusLabel];
                  
                  // show alert
                  [app_manager showMeasuredPopup];
                  
                  self.frontFootDescription = frontFootDescription;
                  [self pushResultViewController];
              }
              errorMessage:^(NSString * errorString)
              {
                  NSLog(@"Linux server,(Front foot) Error %@ ",errorString);
                  
                  progressStatusLabelShouldShow = false;
                  [self hideProgressStatusLabel];
                  [self hideProgressView];
                  
                  step               = StepTwoRepeat;
                  NSString * message = [NSString stringWithFormat:@"%@ Please retake front foot picture.",errorString];
                  [app_manager showAlertWithTitle:@"" Message:message andAction:PresentImagePicker];
              }];
         }
     }
     errorMessage:^(NSError *error)
     {
         NSLog(@"Linux server,(Front foot) Error%@ ",error);
         progressStatusLabelShouldShow = false;
         [self hideProgressStatusLabel];
         [self hideProgressView];
         step = StepTwoRepeat;
         [app_manager handleError:error];
     }];
}

// No wait between two calls
//-(void)validateSideFootImage:(NSData *)sideFootImageData
//{
//    if (step == StepOne)
//    {
//        step = StepTwo;
//        [self presentImagePicker];
//    }
//    
//    isLinuxServerCallForSideFootInProgress = YES;
//    
//    [linux_webservice_manager validateSideFootImage:sideFootImageData block:^(NSData *data)
//    {
//        if(!data)
//        {
//            isLinuxServerCallForSideFootInProgress = NO;
//            
//            step = StepOneRepeat;
//            [app_manager showAlertWithTitle:@"Error" Message:@"Unable to get response from server. Please retake side foot picture." andAction:PresentImagePicker];
//        }
//        else
//        {
//            [linux_server_response_handler handleResponseForSideFoot:data block:^(FootDescription *sideFootDescription)
//            {
//                isLinuxServerCallForSideFootInProgress = NO;
//                                
//                // draw bounded box on original image of side foot
//                //[app_manager drawBoxesOnImage:capturedSidePhoto withFootBoundedBox:footBoundedBox andPhoneBoundedBox:phoneBoundedBox];
//                
//                // crop foot and save for result screen
//                //CGRect sideFootRect = CGRectMake(footBoundedBox.x, footBoundedBox.y, footBoundedBox.w, footBoundedBox.h);
//                //[self cropImage:capturedSidePhoto withRect:sideFootRect forFoot:@"side"];
//                
//                // show alert
//                [app_manager showMeasuredPopup];
//                
//                self.sideFootDescription = sideFootDescription;
//                isSideFootErrorAppeared = NO;
//                
//                if ([self shouldPushResultViewController])
//                {
//                    [self pushResultViewController];
//                }
//                else if(isFrontFootErrorAppeared)
//                {
//                    step = StepTwoRepeat;
//                    NSString *message = [NSString stringWithFormat:@"%@ Please retake front foot picture.",frontFootErrorString];
//                    [app_manager showAlertWithTitle:@"" Message:message andAction:PresentImagePicker];
//                }
//            }
//            errorMessage:^(NSString * errorString)
//            {
//                NSLog(@"Linux server,(Side foot) Error %@ ",errorString);
//                
//                isLinuxServerCallForSideFootInProgress = NO;
//                isSideFootErrorAppeared = YES;
//                sideFootErrorString = errorString;
//                
//                if (!isLinuxServerCallForFrontFootInProgress)
//                {
//                    if (isFrontFootErrorAppeared)
//                    {
//                        step = StepTwoRepeat;
//                        NSString *message = [NSString stringWithFormat:@"%@ Please retake front foot picture.",frontFootErrorString];
//                        [app_manager showAlertWithTitle:@"" Message:message andAction:PresentImagePicker];
//                    }
//                    else
//                    {
//                        if(step != StepTwo)
//                        {
//                            step              = StepOneRepeat;
//                            NSString *message = [NSString stringWithFormat:@"%@ Please retake side foot picture.",errorString];
//                            [app_manager showAlertWithTitle:@"" Message:message andAction:PresentImagePicker];
//                        }
//                    }
//                }
//            }];
//        }
//    }
//    errorMessage:^(NSError *error)
//    {
//        NSLog(@"Linux server,(Side foot) Error%@ ",error);
//        isLinuxServerCallForSideFootInProgress = NO;
//        
//        [imagePicker dismissViewControllerAnimated:YES completion:^{
//            [app_manager handleError:error];
//        }];
//        
//        //[linux_webservice_manager cancelAllRunningTasks];
//    }];
//}

//-(void)validateFrontFootImage:(NSData *)frontFootImageData
//{
//    if(isSideFootErrorAppeared)
//    {
//        step              = StepOneRepeat;
//        NSString *message = [NSString stringWithFormat:@"%@ Please retake side foot picture.",sideFootErrorString];
//        [app_manager showAlertWithTitle:@"" Message:message andAction:PresentImagePicker];
//    }
//    
//    isLinuxServerCallForFrontFootInProgress = YES;
//    
//    [linux_webservice_manager validateFrontFootImage:frontFootImageData block:^(NSData *data)
//     {
//         if(!data)
//         {
//             isLinuxServerCallForFrontFootInProgress = NO;
//             step = StepTwoRepeat;
//             [app_manager showAlertWithTitle:@"Error" Message:@"Unable to get response from server. Please retake front foot picture." andAction:PresentImagePicker];
//         }
//         else
//         {
//             [linux_server_response_handler handleResponseForFrontFoot:data block:^(FootDescription *frontFootDescription)
//              {
//                  isLinuxServerCallForFrontFootInProgress = NO;
//               
//                  // draw bounded box on original image of front foot
//                  //[app_manager drawBoxesOnImage:capturedFrontPhoto withFootBoundedBox:footBoundedBox andPhoneBoundedBox:phoneBoundedBox];
//                  
//                  // crop foot and save
//                  //CGRect sideFootRect = CGRectMake(footBoundedBox.x, footBoundedBox.y, footBoundedBox.w, footBoundedBox.h);
//                  //[self cropImage:capturedFrontPhoto withRect:sideFootRect forFoot:@"front"];
//                  
//                  // show alert
//                  [app_manager showMeasuredPopup];
//                  
//                  self.frontFootDescription = frontFootDescription;
//                  isFrontFootErrorAppeared = NO;
//                  
//                  if ([self shouldPushResultViewController])
//                  {
//                      [self pushResultViewController];
//                  }
//                  else if(isSideFootErrorAppeared)
//                  {
//                      step = StepOneRepeat;
//                      NSString *message = [NSString stringWithFormat:@"%@ Please retake side foot picture.",sideFootErrorString];
//                      [app_manager showAlertWithTitle:@"" Message:message andAction:PresentImagePicker];
//                  }
//              }
//              errorMessage:^(NSString * errorString)
//              {
//                  NSLog(@"Linux server,(Front foot) Error %@ ",errorString);
//                  
//                  isLinuxServerCallForFrontFootInProgress = NO;
//                  isFrontFootErrorAppeared = YES;
//                  frontFootErrorString     = errorString;
//                  
//                  if (!isLinuxServerCallForSideFootInProgress)
//                  {
//                      if (isSideFootErrorAppeared)
//                      {
//                          step = StepOneRepeat;
//                          NSString *message = [NSString stringWithFormat:@"%@ Please retake side foot picture.",sideFootErrorString];
//                          [app_manager showAlertWithTitle:@"" Message:message andAction:PresentImagePicker];
//                      }
//                      else
//                      {
//                          step               = StepTwoRepeat;
//                          NSString * message = [NSString stringWithFormat:@"%@ Please retake front foot picture.",errorString];
//                          [app_manager showAlertWithTitle:@"" Message:message andAction:PresentImagePicker];
//                      }
//                  }
//              }];
//         }
//     }
//     errorMessage:^(NSError *error)
//     {
//         NSLog(@"Linux server,(Front foot) Error%@ ",error);
//         isLinuxServerCallForFrontFootInProgress = NO;
//         
//         [imagePicker dismissViewControllerAnimated:YES completion:^{
//             [app_manager handleError:error];
//         }];
//     }];
//}

-(BOOL)shouldPushResultViewController
{
    if (_sideFootDescription && _frontFootDescription)
    {
        return YES;
    }
    return NO;
}

-(void)pushResultViewController
{
    _resetButton.hidden                 = YES;
    step                                = StepOne;
    //[app_manager stopAnimatingActivityIndicator]; //1122

    dispatch_async(dispatch_get_main_queue(),^
    {
        ResultViewController * rvc ;
        
        if (isiPhone5 || isiPhone4Or4s)
        {
            rvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ResultForIphoneFourFive"];
        }
        else
        {
            rvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ResultForIphoneSixSixPlus"];
        }
        
        rvc.sideFootDescription    = _sideFootDescription;
        rvc.frontFootDescription   = _frontFootDescription;
        rvc.sideFootCroppedImage   = _sideFootBoundedBoxCroppedImage;
        rvc.frontFootCroppedImage  = _frontFootBoundedBoxCroppedImage;
        
        [self resetAppData];
        
        [self.navigationController pushViewController:rvc animated:YES];
    });
}

-(BOOL)shouldHideActivityIndicator
{
    if (isLinuxServerCallForSideFootInProgress || isLinuxServerCallForFrontFootInProgress || isWindowsServerCallForSideFootInProgress || isWindowsServerCallForFrontFootInProgress)
    {
        return NO;
    }
    return YES;
}

-(void)resetAppData
{
    [self hideProgressView];
    [self hideProgressStatusLabel];
 
    
    
    step = StepOne ;
    isLinuxServerCallForSideFootInProgress       = NO  ;
    isLinuxServerCallForFrontFootInProgress      = NO  ;
    isWindowsServerCallForSideFootInProgress     = NO  ;
    isWindowsServerCallForFrontFootInProgress    = NO  ;
    
    isWaitingForSideFootWindowsServerResponse    = NO  ;
    isSideFootErrorAppeared                      = NO  ;
    isFrontFootErrorAppeared                     = NO  ;
    
    self.sideFootDescription                     = nil ;
    self.frontFootDescription                    = nil ;
}



//////////////////// HAAR /////////////////////


-(void)validateHAARSideFootImage:(NSData *)sideFootImageData
{
    if (!isWaitingForSideFootWindowsServerResponse)
    {
        // move to step two without waiting for side foot response
        
        step              = StepTwo;
        [self presentImagePicker];
    }
    
    isLinuxServerCallForSideFootInProgress = YES;
    [linux_webservice_manager validateHAARSideFootImage:sideFootImageData block:^(NSData *data)
     {
         if(!data)
         {
             isLinuxServerCallForSideFootInProgress = NO;
             step = StepOneRepeat;
             [app_manager showAlertWithTitle:@"Error" Message:@"Unable to get response from server. Please retake side foot picture." andAction:PresentImagePicker];
         }
         else
         {
             [linux_server_response_handler handleHAARResponseForSideFoot:data block:^(NSArray *boxesArray)
              {
                  isLinuxServerCallForSideFootInProgress = NO;
                  
                  BoundedBox footBoundedBox, phoneBoundedBox;
                  
                  NSValue * footBoxValue  = [boxesArray objectAtIndex:0];
                  NSValue * phoneBoxValue = [boxesArray objectAtIndex:1];
                  
                  [footBoxValue getValue:&footBoundedBox];
                  [phoneBoxValue getValue:&phoneBoundedBox];
                  
                  // draw bounded box on original image of side foot
                  [app_manager drawBoxesOnImage:capturedSidePhoto withFootBoundedBox:footBoundedBox andPhoneBoundedBox:phoneBoundedBox];
                  
                  // crop foot and save for result screen
                  CGRect sideFootRect = CGRectMake(footBoundedBox.x, footBoundedBox.y, footBoundedBox.w, footBoundedBox.h);
                  [self cropImage:capturedSidePhoto withRect:sideFootRect forFoot:@"side"];
                  
                  // show alert
                  [app_manager showMeasuredPopup];
                  
                  //upload side foot image with boundedbox for segmentation
                  [self uploadSideFootForSegmentation:sideFootImageData withSideFootBoundedBox:footBoundedBox andPhoneBoundedBox:phoneBoundedBox];
              }
                                                         errorMessage:^(NSString * errorString)
              {
                  if (isLinuxServerCallForFrontFootInProgress)
                  {
                      [linux_webservice_manager cancelAllRunningTasks];
                  }
                  else
                  {
                      // dismiss camera view of second step
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [imagePicker dismissViewControllerAnimated:YES completion:nil];
                      });
                  }
                  
                  NSLog(@"Linux server,(Side foot) Error %@ ",errorString);
                  step              = StepOneRepeat;
                  NSString *message = [NSString stringWithFormat:@"%@. Please retake side foot picture.",errorString];
                  [app_manager showAlertWithTitle:@"" Message:message andAction:PresentImagePicker];
              }];
         }
     }
                                       errorMessage:^(NSError *error)
     {
         NSLog(@"Linux server,(Side foot) Error%@ ",error);
         isLinuxServerCallForSideFootInProgress = NO;
         [app_manager handleError:error];
         [linux_webservice_manager cancelAllRunningTasks];
     }];
}

-(void)validateHAARFrontFootImage:(NSData *)frontFootImageData
{
    isLinuxServerCallForFrontFootInProgress = YES;
    
    [linux_webservice_manager validateHAARFrontFootImage:frontFootImageData block:^(NSData *data)
     {
         if(!data)
         {
             isLinuxServerCallForFrontFootInProgress = NO;
             step = StepTwoRepeat;
             [app_manager showAlertWithTitle:@"Error" Message:@"Unable to get response from server. Please retake front foot picture." andAction:PresentImagePicker];
         }
         else
         {
             [linux_server_response_handler handleHAARResponseForFrontFoot:data block:^(NSArray *boxesArray)
              {
                  isLinuxServerCallForFrontFootInProgress = NO;
                  
                  if (isSideFootErrorAppeared) {
                      return ;
                  }
                  
                  BoundedBox footBoundedBox, phoneBoundedBox;
                  
                  NSValue * footBoxValue  = [boxesArray objectAtIndex:0];
                  NSValue * phoneBoxValue = [boxesArray objectAtIndex:1];
                  
                  [footBoxValue getValue:&footBoundedBox];
                  [phoneBoxValue getValue:&phoneBoundedBox];
                  
                  // draw bounded box on original image of front foot
                  [app_manager drawBoxesOnImage:capturedFrontPhoto withFootBoundedBox:footBoundedBox andPhoneBoundedBox:phoneBoundedBox];
                  
                  // crop foot and save
                  CGRect sideFootRect = CGRectMake(footBoundedBox.x, footBoundedBox.y, footBoundedBox.w, footBoundedBox.h);
                  [self cropImage:capturedFrontPhoto withRect:sideFootRect forFoot:@"front"];
                  
                  // show alert
                  [app_manager showMeasuredPopup];
                  
                  
                  if (isWindowsServerCallForSideFootInProgress)
                  {
                      // cache front foot data
                      isWaitingForSideFootWindowsServerResponse = YES;
                      frontFootBoundedBox_Cached                = footBoundedBox;
                      frontFootPhoneBoundedBox_Cached           = phoneBoundedBox;
                      frontFootImageData_Cached                 = frontFootImageData;
                  }
                  else
                  {
                      if (!isSideFootErrorAppeared)
                      {
                          // show alert
                          //[app_manager showMeasuredPopup];
                          
                          //upload front foot image with boundedbox for segmentation
                          [self uploadFrontFootForSegmentation:frontFootImageData withFrontFootBoundedBox:footBoundedBox andPhoneBoundedBox:phoneBoundedBox];
                      }
                  }
                  
                  //upload front foot image with boundedbox for segmentation
                  //[self uploadFrontFootForSegmentation:frontFootImageData withFrontFootBoundedBox:footBoundedBox andPhoneBoundedBox:phoneBoundedBox];
              }
                                                          errorMessage:^(NSString * errorString)
              {
                  NSLog(@"Linux server,(Front foot) Error %@ ",errorString);
                  step               = StepTwoRepeat;
                  NSString * message = [NSString stringWithFormat:@"%@. Please retake front foot picture.",errorString];
                  [app_manager showAlertWithTitle:@"" Message:message andAction:PresentImagePicker];
              }];
         }
     }
                                        errorMessage:^(NSError *error)
     {
         NSLog(@"Linux server,(Front foot) Error%@ ",error);
         isLinuxServerCallForFrontFootInProgress = NO;
         [app_manager handleError:error];
     }];
}

-(void)uploadSideFootForSegmentation:(NSData *)sideFootImageData withSideFootBoundedBox:(BoundedBox)sideFootBox andPhoneBoundedBox:(BoundedBox)phoneBox
{
    isWindowsServerCallForSideFootInProgress = YES;
    [windows_webservice_manager uploadSideFootImageForSegmentation:sideFootImageData withSideFootBoundedBox:sideFootBox andPhoneBoundedBox:phoneBox block:^(FootDescription *footDescription)
     {
         isWindowsServerCallForSideFootInProgress = NO;
         _sideFootDescription                     = footDescription;
         
         if (isWaitingForSideFootWindowsServerResponse)
         {
             [self uploadFrontFootForSegmentation:frontFootImageData_Cached withFrontFootBoundedBox:frontFootBoundedBox_Cached andPhoneBoundedBox:frontFootPhoneBoundedBox_Cached];
         }
         
         //step                                     = StepTwo;
         //[self presentImagePicker];
     }
                                                      errorMessage:^(NSString *error)
     {
         isWindowsServerCallForSideFootInProgress = NO;
         
         step = StepOneRepeat;
         
         isSideFootErrorAppeared = YES;
         
         // dismiss camera
         dispatch_async(dispatch_get_main_queue(), ^{
             [imagePicker dismissViewControllerAnimated:YES completion:nil];
         });
         
         if (error.length > 0)
         {
             if (isLinuxServerCallForFrontFootInProgress)
             {
                 [linux_webservice_manager cancelAllRunningTasks];
             }
             if (isWindowsServerCallForFrontFootInProgress)
             {
                 [windows_webservice_manager cancelAllRunningTasks];
             }
             
             NSString * errorMessage = [NSString stringWithFormat:@"%@. Please retake side foot picture.",error];
             [app_manager showAlertWithTitle:@"" Message:errorMessage andAction:PresentImagePicker];
         }
     }];
}

-(void)uploadFrontFootForSegmentation:(NSData *)frontFootImageData withFrontFootBoundedBox:(BoundedBox)frontFootBox andPhoneBoundedBox:(BoundedBox)phoneBox
{
    NSString * sideID   = _sideFootDescription.sideID;
    NSString * resultID = _sideFootDescription.resultID;
    
    isWindowsServerCallForFrontFootInProgress = YES;
    [windows_webservice_manager uploadFrontFootImageForSegmentation:frontFootImageData withFrontFootBoundedBox:frontFootBox phoneBoundedBox:phoneBox sideID:sideID andResultID:resultID block:^(FootDescription *footDescription)
     {
         isWindowsServerCallForFrontFootInProgress = NO;
         _frontFootDescription                     = footDescription;
         
         if ([self shouldPushResultViewController])
         {
             [self pushResultViewController];
         }
     }
                                                       errorMessage:^(NSString *error)
     {
         isWindowsServerCallForFrontFootInProgress = NO;
         if (error.length > 0)
         {
             step = StepTwoRepeat;
             [app_manager showAlertWithTitle:@"Front Foot Error!" Message:error andAction:PresentImagePicker];
         }
     }];
}





@end

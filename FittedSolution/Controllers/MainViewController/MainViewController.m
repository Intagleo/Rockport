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

@interface MainViewController ()
{
    UIImagePickerController  * imagePicker                                  ;
    UIImage                  * capturedPhoto                                ;
    NSData                   * capturedPhotoData                            ;
    

    BOOL                       isLinuxServerCallForSideFootInProgress       ;
    BOOL                       isLinuxServerCallForFrontFootInProgress      ;
    BOOL                       isWindowsServerCallForSideFootInProgress     ;
    BOOL                       isWindowsServerCallForFrontFootInProgress    ;
    
    // new added for new flow (18 oct 2016)
    BOOL                       isWaitingForSideFootWindowsServerResponse    ;
    BOOL                       isSideFootErrorAppeared                      ;
    BOOL                       isFrontFootErrorAppeared                     ;
    NSString                 * sideFootErrorString                          ;
    NSString                 * frontFootErrorString                         ;
    BoundedBox                 frontFootBoundedBox_Cached                   ;
    BoundedBox                 frontFootPhoneBoundedBox_Cached              ;
    NSData                   * frontFootImageData_Cached                    ;
}

@property (nonatomic, strong) UIView            * tutorialViewContainer             ;
@property (nonatomic, strong) UIImage           * sideFootBoundedBoxCroppedImage    ;
@property (nonatomic, strong) UIImage           * frontFootBoundedBoxCroppedImage   ;
@property (strong, nonatomic) FootDescription   * sideFootDescription               ;
@property (strong, nonatomic) FootDescription   * frontFootDescription              ;

@end

@implementation MainViewController

@synthesize step;

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    
    [self setUpSpeechRecognition];
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

#pragma mark - SpeechRecognitionManagerDelegate

-(void)pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID
{
    NSLog(@"%@ recognised ",hypothesis);
    
    if ([hypothesis isEqualToString:@"capture"])
    {
        _resetButton.hidden = NO;
        [imagePicker takePicture];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [self stopListeningClickVoice];
    }];
    
    if ([app_manager isInternetAvailable])
    {
        [app_manager startAnimatingActivityIndicator];
    
        UIImage * imageTaken      = [app_manager fixRotation:[info objectForKey:UIImagePickerControllerOriginalImage]];
        
//        if (step == StepOne || step == StepOneRepeat) {
//            imageTaken      = [UIImage imageNamed:@"0.jpg"];
//        }
//        else
//        {
//            imageTaken      = [UIImage imageNamed:@"frontFoot1.jpg"];
//        }
        
        
        capturedPhoto             = [app_manager compressImage:imageTaken];
        capturedPhotoData         = [app_manager addPhoneModelAndNameToImageMetaData:capturedPhoto];
        
        _resetButton.hidden   = NO;

        if (step == StepOne || step == StepOneRepeat)
        {
            [self validateSideFootImage:capturedPhotoData];
        }
        else if(step == StepTwo || step == StepTwoRepeat)
        {
            [self validateFrontFootImage:capturedPhotoData];
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
    imagePicker.cameraDevice             = UIImagePickerControllerCameraDeviceRear;
    imagePicker.showsCameraControls      = NO;
    imagePicker.cameraFlashMode          = UIImagePickerControllerCameraFlashModeOff;
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
    
    CGAffineTransform translate          = CGAffineTransformMakeTranslation(0.0, 71.0);
    imagePicker.cameraViewTransform      = translate;
    CGAffineTransform scale              = CGAffineTransformScale(translate, 1.333333, 1.333333);
    imagePicker.cameraViewTransform      = scale;
    
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
    
    [pickerHeader addSubview:headerImageView];
    [imagePicker.view addSubview:pickerHeader];
    
    // adjusting camera view to fullscreen
//    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
//    float cameraAspectRatio = 4.0 / 3.0;
//    float imageWidth = floorf(screenSize.width * cameraAspectRatio);
//    float scale = ceilf((screenSize.height / imageWidth) * 10.0) / 10.0;
//    imagePicker.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
//    
//    CGAffineTransform translate          = CGAffineTransformMakeTranslation(0.0, pickerHeader.frame.size.height);
//    imagePicker.cameraViewTransform      = translate;
//    CGAffineTransform transform_scale    = CGAffineTransformScale(translate, scale, scale);
//    imagePicker.cameraViewTransform      = transform_scale;
}

-(void)presentImagePickerController
{
    [self performSelectorInBackground:@selector(startListeningClick_Voice) withObject:nil];
    
    [self presentViewController:imagePicker animated:YES completion:^
    {
        if ([[app_manager getDeviceiOSVersion] floatValue] >= 10)
        {
            [imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
            
//            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
//            // iOS is going to calculate a size which constrains the 4:3 aspect ratio
//            // to the screen size. We're basically mimicking that here to determine
//            // what size the system will likely display the image at on screen.
//            // NOTE: screenSize.width may seem odd in this calculation - but, remember,
//            // the devices only take 4:3 images when they are oriented *sideways*.
//            float cameraAspectRatio = 4.0 / 3.0;
//            float imageWidth = floorf(screenSize.width * cameraAspectRatio);
//            float scale = ceilf((screenSize.height / imageWidth) * 10.0) / 10.0;
//            imagePicker.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
        }
        
        [app_manager stopAnimatingActivityIndicator];
        
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
        
        UIButton * cameraClickBtn        = [[UIButton alloc] init];
        cameraClickBtn.frame             = CGRectMake(0,80, self.view.frame.size.width, self.view.frame.size.height-65);
        cameraClickBtn.backgroundColor   = [UIColor clearColor];
        [cameraClickBtn addTarget:self action:@selector(cameraClickButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        [imagePicker.view addSubview:cameraClickBtn];
        
        if (isiPhone5 || isiPhone4Or4s)
        {
            phoneIcon.frame              = CGRectMake(230, 230, 26, 26);
            phoneIcon.transform          =  CGAffineTransformMakeRotation (3.14/2);

            phoneLbl.frame               = CGRectMake(139, 366, 208, 14);
            phoneLbl.transform           =  CGAffineTransformMakeRotation (3.14/2);

            footIcon.frame               = CGRectMake(110, 180, 26, 26);
            footIcon.transform           =  CGAffineTransformMakeRotation (3.14/2);

            footLbl.frame                = CGRectMake(45, 290, 157, 14);
            footLbl.transform            =  CGAffineTransformMakeRotation (3.14/2);
        }
        else  // for iphone 6 and 6s+
        {
            phoneIcon.frame              = CGRectMake(300, 300, 26, 26);
            phoneIcon.transform          =  CGAffineTransformMakeRotation (3.14/2);
            
            phoneLbl.frame               = CGRectMake(209, 436, 208, 14);
            phoneLbl.transform           =  CGAffineTransformMakeRotation (3.14/2);
            
            footIcon.frame               = CGRectMake(110, 240, 26, 26);
            footIcon.transform           =  CGAffineTransformMakeRotation (3.14/2);
            
            footLbl.frame                = CGRectMake(45, 350, 157, 14);
            footLbl.transform            =  CGAffineTransformMakeRotation (3.14/2);
        }
    }];
}

-(void)cameraBackButtonAction
{
    [self dismissViewControllerAnimated:YES completion:^
    {
        [self stopListeningClickVoice];
        
        if (step == StepOne || step == StepOneRepeat)
        {
            _resetButton.hidden = YES;
        }
        else
        {
            _resetButton.hidden = NO;
        }
        
        [app_manager stopAnimatingActivityIndicator];
    }];
}

-(void)cameraClickButtonAction
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
    if ([foot isEqualToString:@"side"])
    {
        _sideFootBoundedBoxCroppedImage  = [image croppedImage:rect];
    }
    else if ([foot isEqualToString:@"front"])
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
    isLinuxServerCallForSideFootInProgress = YES;
    
    [linux_webservice_manager validateSideFootImage:sideFootImageData block:^(NSData *data)
     {
         isLinuxServerCallForSideFootInProgress = NO;
         NSLog(@"Linux server,(Side foot) Data%@ ",data);
         
         if(!data)
         {
             step = StepOneRepeat;
             [app_manager showAlertWithTitle:@"Error" Message:@"Unable to get response from server. Please retake side foot picture." andAction:PresentImagePicker];
         }
         else
         {
             [linux_server_response_handler handleResponseForSideFoot:data block:^(NSArray *boxesArray)
              {
                  BoundedBox footBoundedBox, phoneBoundedBox;
                  
                  NSValue * footBoxValue  = [boxesArray objectAtIndex:0];
                  NSValue * phoneBoxValue = [boxesArray objectAtIndex:1];
                  
                  [footBoxValue getValue:&footBoundedBox];
                  [phoneBoxValue getValue:&phoneBoundedBox];
                  
                  // draw bounded box on original image of side foot
                  [app_manager drawBoxesOnImage:capturedPhoto withFootBoundedBox:footBoundedBox andPhoneBoundedBox:phoneBoundedBox];
                  
                  // crop foot and save for result screen
                  CGRect sideFootRect = CGRectMake(footBoundedBox.x, footBoundedBox.y, footBoundedBox.w, footBoundedBox.h);
                  [self cropImage:capturedPhoto withRect:sideFootRect forFoot:@"side"];
                  
                  // show alert
                  [app_manager showMeasuredPopup];
                  
                  //upload side foot image with boundedbox for segmentation
                  [self uploadSideFootForSegmentation:sideFootImageData withSideFootBoundedBox:footBoundedBox andPhoneBoundedBox:phoneBoundedBox];
                  
                  // go to step two
                  step = StepTwo;
                  [self presentImagePicker];
              }
              errorMessage:^(NSString * errorString)
              {
                  NSLog(@"Linux server,(Side foot) Error %@ ",errorString);
                  step              = StepOneRepeat;
                  NSString *message = [NSString stringWithFormat:@"%@ Please retake side foot picture.",errorString];
                  [app_manager showAlertWithTitle:@"" Message:message andAction:PresentImagePicker];
              }];
         }
     }
     errorMessage:^(NSError *error)
     {
         NSLog(@"Linux server,(Side foot) Error%@ ",error);
         isLinuxServerCallForSideFootInProgress = NO;
         [app_manager handleError:error];
     }];
}

-(void)validateFrontFootImage:(NSData *)frontFootImageData
{
    isLinuxServerCallForFrontFootInProgress = YES;
    
    [linux_webservice_manager validateFrontFootImage:frontFootImageData block:^(NSData *data)
     {
         isLinuxServerCallForFrontFootInProgress = NO;
         
         if(!data)
         {
             step = StepTwoRepeat;
             [app_manager showAlertWithTitle:@"Error" Message:@"Unable to get response from server. Please retake front foot picture." andAction:PresentImagePicker];
         }
         else
         {
             [linux_server_response_handler handleResponseForFrontFoot:data block:^(NSArray *boxesArray)
              {
                  BoundedBox footBoundedBox, phoneBoundedBox;
                  
                  NSValue * footBoxValue  = [boxesArray objectAtIndex:0];
                  NSValue * phoneBoxValue = [boxesArray objectAtIndex:1];
                  
                  [footBoxValue getValue:&footBoundedBox];
                  [phoneBoxValue getValue:&phoneBoundedBox];
                  
                  // draw bounded box on original image of front foot
                  [app_manager drawBoxesOnImage:capturedPhoto withFootBoundedBox:footBoundedBox andPhoneBoundedBox:phoneBoundedBox];
                  
                  // crop foot and save
                  CGRect sideFootRect = CGRectMake(footBoundedBox.x, footBoundedBox.y, footBoundedBox.w, footBoundedBox.h);
                  [self cropImage:capturedPhoto withRect:sideFootRect forFoot:@"front"];
                  
                  // show alert
                  [app_manager showMeasuredPopup];
                  
                  if (!isWindowsServerCallForSideFootInProgress)
                  {
                      isWaitingForSideFootWindowsServerResponse = NO;
                      
                      if (!isSideFootErrorAppeared)
                      {
                          // show alert
                          //[app_manager showMeasuredPopup];
                          
                          //upload front foot image with boundedbox for segmentation
                          [self uploadFrontFootForSegmentation:frontFootImageData withFrontFootBoundedBox:footBoundedBox andPhoneBoundedBox:phoneBoundedBox];
                      }
                      else
                      {
                          if (step != StepOneRepeat)
                          {
                              step = StepOneRepeat;
                              [app_manager showAlertWithTitle:@"Side Foot Segmentation Error" Message:sideFootErrorString andAction:PresentImagePicker];
                          }
                      }
                  }
                  else
                  {
                      isWaitingForSideFootWindowsServerResponse = YES;
                      frontFootBoundedBox_Cached                = footBoundedBox;
                      frontFootPhoneBoundedBox_Cached           = phoneBoundedBox;
                      frontFootImageData_Cached                 = frontFootImageData;
                  }
              }
              errorMessage:^(NSString * errorString)
              {
                  NSLog(@"Linux server,(Front foot) Error: %@ ",errorString);
                  
                  isFrontFootErrorAppeared = YES;
                  frontFootErrorString = errorString;
                  if (!isWindowsServerCallForSideFootInProgress && !isSideFootErrorAppeared)
                  {
                      step               = StepTwoRepeat;
                      NSString * message = [NSString stringWithFormat:@"%@ Please retake front foot picture.",errorString];
                      [app_manager showAlertWithTitle:@"" Message:message andAction:PresentImagePicker];
                  }
              }];
         }
     }
     errorMessage:^(NSError *error)
     {
         NSLog(@"Linux server,(Front foot) Error: %@ ",error);
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
         isSideFootErrorAppeared                  = NO;
         _sideFootDescription                     = footDescription;
         
         //step                                     = StepTwo;
         //[self presentImagePicker];
         
         [self sideFootResponseReceivedFromWindowsServerWithSuccess:YES];
     }
     errorMessage:^(NSString *error)
     {
         isWindowsServerCallForSideFootInProgress = NO;
         isSideFootErrorAppeared = YES;
         sideFootErrorString     = error;
         
         [self sideFootResponseReceivedFromWindowsServerWithSuccess:NO];
         
         //         step = StepOneRepeat;
         //
         //         if (error.length > 0)
         //         {
         //             NSString * errorMessage = [NSString stringWithFormat:@"%@. Please retake side foot picture.",error];
         //             [app_manager showAlertWithTitle:@"" Message:errorMessage andAction:PresentImagePicker];
         //         }
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

-(void)sideFootResponseReceivedFromWindowsServerWithSuccess:(BOOL)success
{
    if (success)
    {
        if (isWaitingForSideFootWindowsServerResponse)
        {
            [self uploadFrontFootForSegmentation:frontFootImageData_Cached withFrontFootBoundedBox:frontFootBoundedBox_Cached andPhoneBoundedBox:frontFootPhoneBoundedBox_Cached];
        }
        else if (isFrontFootErrorAppeared)
        {
            step               = StepTwoRepeat;
            NSString * message = [NSString stringWithFormat:@"%@ Please retake front foot picture.",frontFootErrorString];
            [app_manager showAlertWithTitle:@"" Message:message andAction:PresentImagePicker];
        }
    }
    else
    {
        step = StepOneRepeat;
        [app_manager showAlertWithTitle:@"Side Foot Segmentation Error" Message:sideFootErrorString andAction:PresentImagePicker];
    }
    isWaitingForSideFootWindowsServerResponse = NO;
}

////////

//-(void)validateSideFootImage:(NSData *)sideFootImageData
//{
//    isLinuxServerCallForSideFootInProgress = YES;
//    
//    [linux_webservice_manager validateSideFootImage:sideFootImageData block:^(NSData *data)
//    {
//        isLinuxServerCallForSideFootInProgress = NO;
//        NSLog(@"Linux server,(Side foot) Data%@ ",data);
//        
//        if(!data)
//        {
//            step = StepOneRepeat;
//            [app_manager showAlertWithTitle:@"Error" Message:@"Unable to get response from server. Please retake side foot picture." andAction:PresentImagePicker];
//        }
//        else
//        {
//            [linux_server_response_handler handleResponseForSideFoot:data block:^(NSArray *boxesArray)
//            {
//                BoundedBox footBoundedBox, phoneBoundedBox;
//                
//                NSValue * footBoxValue  = [boxesArray objectAtIndex:0];
//                NSValue * phoneBoxValue = [boxesArray objectAtIndex:1];
//                
//                [footBoxValue getValue:&footBoundedBox];
//                [phoneBoxValue getValue:&phoneBoundedBox];
//                
//                // draw bounded box on original image of side foot
//                [app_manager drawBoxesOnImage:capturedPhoto withFootBoundedBox:footBoundedBox andPhoneBoundedBox:phoneBoundedBox];
//                
//                // crop foot and save for result screen
//                CGRect sideFootRect = CGRectMake(footBoundedBox.x, footBoundedBox.y, footBoundedBox.w, footBoundedBox.h);
//                [self cropImage:capturedPhoto withRect:sideFootRect forFoot:@"side"];
//                
//                // show alert
//                [app_manager showMeasuredPopup];
//                
//                //upload side foot image with boundedbox for segmentation
//                [self uploadSideFootForSegmentation:sideFootImageData withSideFootBoundedBox:footBoundedBox andPhoneBoundedBox:phoneBoundedBox];
//            }
//            errorMessage:^(NSString * errorString)
//            {
//                NSLog(@"Linux server,(Side foot) Error %@ ",errorString);
//                step              = StepOneRepeat;
//                NSString *message = [NSString stringWithFormat:@"%@. Please retake side foot picture.",errorString];
//                [app_manager showAlertWithTitle:@"" Message:message andAction:PresentImagePicker];
//            }];
//        }
//    }
//    errorMessage:^(NSError *error)
//    {
//        NSLog(@"Linux server,(Side foot) Error%@ ",error);
//        isLinuxServerCallForSideFootInProgress = NO;
//        [app_manager handleError:error];
//    }];
//}
//
//-(void)validateFrontFootImage:(NSData *)frontFootImageData
//{
//    isLinuxServerCallForFrontFootInProgress = YES;
//    
//    [linux_webservice_manager validateFrontFootImage:frontFootImageData block:^(NSData *data)
//     {
//         isLinuxServerCallForFrontFootInProgress = NO;
//         
//         if(!data)
//         {
//             step = StepTwoRepeat;
//             [app_manager showAlertWithTitle:@"Error" Message:@"Unable to get response from server. Please retake front foot picture." andAction:PresentImagePicker];
//         }
//         else
//         {
//             [linux_server_response_handler handleResponseForFrontFoot:data block:^(NSArray *boxesArray)
//              {
//                  BoundedBox footBoundedBox, phoneBoundedBox;
//                  
//                  NSValue * footBoxValue  = [boxesArray objectAtIndex:0];
//                  NSValue * phoneBoxValue = [boxesArray objectAtIndex:1];
//                  
//                  [footBoxValue getValue:&footBoundedBox];
//                  [phoneBoxValue getValue:&phoneBoundedBox];
//                  
//                  // draw bounded box on original image of front foot
//                  [app_manager drawBoxesOnImage:capturedPhoto withFootBoundedBox:footBoundedBox andPhoneBoundedBox:phoneBoundedBox];
//                  
//                  // crop foot and save
//                  CGRect sideFootRect = CGRectMake(footBoundedBox.x, footBoundedBox.y, footBoundedBox.w, footBoundedBox.h);
//                  [self cropImage:capturedPhoto withRect:sideFootRect forFoot:@"front"];
//                  
//                  // show alert
//                  [app_manager showMeasuredPopup];
//                  
//                  //upload front foot image with boundedbox for segmentation
//                  [self uploadFrontFootForSegmentation:frontFootImageData withFrontFootBoundedBox:footBoundedBox andPhoneBoundedBox:phoneBoundedBox];
//              }
//              errorMessage:^(NSString * errorString)
//              {
//                  NSLog(@"Linux server,(Front foot) Error %@ ",errorString);
//                  step               = StepTwoRepeat;
//                  NSString * message = [NSString stringWithFormat:@"%@. Please retake front foot picture.",errorString];
//                  [app_manager showAlertWithTitle:@"" Message:message andAction:PresentImagePicker];
//              }];
//         }
//     }
//     errorMessage:^(NSError *error)
//     {
//         NSLog(@"Linux server,(Front foot) Error%@ ",error);
//         isLinuxServerCallForFrontFootInProgress = NO;
//         [app_manager handleError:error];
//     }];
//}

//-(void)uploadSideFootForSegmentation:(NSData *)sideFootImageData withSideFootBoundedBox:(BoundedBox)sideFootBox andPhoneBoundedBox:(BoundedBox)phoneBox
//{
//    isWindowsServerCallForSideFootInProgress = YES;
//    [windows_webservice_manager uploadSideFootImageForSegmentation:sideFootImageData withSideFootBoundedBox:sideFootBox andPhoneBoundedBox:phoneBox block:^(FootDescription *footDescription)
//    {
//        isWindowsServerCallForSideFootInProgress = NO;
//        _sideFootDescription                     = footDescription;
//        step                                     = StepTwo;
//        [self presentImagePicker];
//    }
//    errorMessage:^(NSString *error)
//    {
//        isWindowsServerCallForSideFootInProgress = NO;
//    
//        step = StepOneRepeat;
//        
//        if (error.length > 0)
//        {
//            NSString * errorMessage = [NSString stringWithFormat:@"%@. Please retake side foot picture.",error];
//            [app_manager showAlertWithTitle:@"" Message:errorMessage andAction:PresentImagePicker];
//        }
//    }];
//}
//
//-(void)uploadFrontFootForSegmentation:(NSData *)frontFootImageData withFrontFootBoundedBox:(BoundedBox)frontFootBox andPhoneBoundedBox:(BoundedBox)phoneBox
//{
//    NSString * sideID   = _sideFootDescription.sideID;
//    NSString * resultID = _sideFootDescription.resultID;
//    
//    isWindowsServerCallForFrontFootInProgress = YES;
//    [windows_webservice_manager uploadFrontFootImageForSegmentation:frontFootImageData withFrontFootBoundedBox:frontFootBox phoneBoundedBox:phoneBox sideID:sideID andResultID:resultID block:^(FootDescription *footDescription)
//     {
//         isWindowsServerCallForFrontFootInProgress = NO;
//         _frontFootDescription                     = footDescription;
//         
//         if ([self shouldPushResultViewController])
//         {
//             [self pushResultViewController];
//         }
//     }
//     errorMessage:^(NSString *error)
//     {
//         isWindowsServerCallForFrontFootInProgress = NO;
//         if (error.length > 0)
//         {
//             step = StepTwoRepeat;
//             [app_manager showAlertWithTitle:@"Front Foot Error!" Message:error andAction:PresentImagePicker];
//         }
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
    [app_manager stopAnimatingActivityIndicator];
    
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

@end

//
//  AppManager.m
//  FittedSolution
//
//  Created by Waqar Ali on 05/07/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import "AppManager.h"
#import "Reachability.h"
#import "UIImage+Resize.h"
#import "LinuxWebserviceManager.h"
#import "WindowsWebserviceManager.h"
#import "TextToSpeechManager.h"

#import <ImageIO/ImageIO.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import <AssetsLibrary/ALAsset.h>

@interface AppManager() <UIAlertViewDelegate>
{
    UIActivityIndicatorView  * activity;
    NSString                 * actionString;
}
@end

@implementation AppManager

+(AppManager *)sharedInstance
{
    static AppManager *instance = nil;
    
    if (!instance)
    {
        instance = [AppManager new];
    }
    return instance;
}

-(NSString *)getDeviceiOSVersion
{
    return [UIDevice currentDevice].systemVersion;
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (UIImage *)compressImage:(UIImage *)image
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 600.0;
    float maxWidth = 800.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    //float compressionQuality = 0.5;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio)
        {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImagePNGRepresentation(img); //UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
}

- (UIImage *)fixRotation:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

-(void)drawBoxesOnImage:(UIImage *)image withFootBoundedBox:(BoundedBox)footBox andPhoneBoundedBox:(BoundedBox)phoneBox
{
    // begin a graphics context of sufficient size
    UIGraphicsBeginImageContext(image.size);
    
    // draw original image into the context
    [image drawAtPoint:CGPointZero];
    
    // get the context for CoreGraphics
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // set stroking color and draw box
    [[UIColor whiteColor] setStroke];
    
    
    // for foot
    CGRect footBoxRect = CGRectMake(footBox.x,footBox.y,footBox.w,footBox.h);
    footBoxRect = CGRectInset(footBoxRect, 0, 0);
    
    // draw rectangle on foot
    CGContextStrokeRect(ctx, footBoxRect);     // CGContextStrokeEllipseInRect(ctx, circleRect);
    
    //// write text for foot on image
    NSString *text = [NSString stringWithFormat:@"x: %d, y: %d, w: %d, h: %d",footBox.x,footBox.y,footBox.w,footBox.h];
    UIFont *font = [UIFont boldSystemFontOfSize:30];
    CGRect rect = CGRectMake(footBox.x, footBox.y-50, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    
    NSDictionary *attributes = @{ NSFontAttributeName: font , NSStrokeColorAttributeName:[UIColor whiteColor]};
    [text drawInRect:CGRectIntegral(rect) withAttributes:attributes];
    
    //////////////////// for foot end
    
    // set stroking color and draw box
    [[UIColor whiteColor] setStroke];
    
    // for phone
    CGRect phoneBoxRect = CGRectMake(phoneBox.x,phoneBox.y,phoneBox.w,phoneBox.h);
    phoneBoxRect = CGRectInset(phoneBoxRect, 0, 0);
    
    // draw rectangle on phone
    CGContextStrokeRect(ctx, phoneBoxRect);
    
    //// write text for phone on image
    NSString *text2 = [NSString stringWithFormat:@"x: %d, y: %d, w: %d, h: %d",phoneBox.x,phoneBox.y,phoneBox.w,phoneBox.h];
    UIFont *font2 = [UIFont boldSystemFontOfSize:30];
    CGRect rect2 = CGRectMake(phoneBox.x, phoneBox.y-50, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    
    NSDictionary *attributes2 = @{ NSFontAttributeName: font2 , NSStrokeColorAttributeName:[UIColor whiteColor]};
    [text2 drawInRect:CGRectIntegral(rect2) withAttributes:attributes2];
    
    //////////////////// for phone end
    
    
    // make image out of bitmap context
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // free the context
    UIGraphicsEndImageContext();
    
    // original image with bounded box
    UIImageWriteToSavedPhotosAlbum(retImage, self, nil, nil);
    
    // cropped bounded box of foot image
    UIImage *croppedImage = [retImage croppedImage:footBoxRect];
    UIImageWriteToSavedPhotosAlbum(croppedImage, self, nil, nil);
    
}


-(BOOL)isInternetAvailable
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        return NO;
    }
    return YES;
}

//-(void)addActivityIndicatorInMainView
//{
//    activity                    = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    activity.frame              = CGRectMake(round((self.rootViewController.view.frame.size.width - 25) / 2), round((self.rootViewController.view.frame.size.height - 25) / 2), 25, 25);
//    activity.color              = [UIColor whiteColor];
//    activity.hidesWhenStopped   = YES;
//    activity.hidden             = YES;
//    
//    [self.rootViewController.view addSubview:activity];
//    [self.rootViewController.view bringSubviewToFront:activity];
//}

-(void)startAnimatingActivityIndicator
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        self.rootViewController.activityImageView.hidden = NO;
        
        NSArray * imagesArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"loading1.png"],[UIImage imageNamed:@"loading2.png"],[UIImage imageNamed:@"loading3.png"],[UIImage imageNamed:@"loading4.png"],[UIImage imageNamed:@"loading5.png"],nil];
        
        self.rootViewController.activityImageView.animationImages      = imagesArray;
        self.rootViewController.activityImageView.animationDuration    = 1.0f;
        self.rootViewController.activityImageView.animationRepeatCount = 0; //HUGE_VAL;
        [self.rootViewController.activityImageView startAnimating];
        
        self.rootViewController.cameraButton.userInteractionEnabled = NO;
    });
}

-(void)stopAnimatingActivityIndicator
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self.rootViewController.activityImageView stopAnimating];
        self.rootViewController.activityImageView.hidden            = YES;
        self.rootViewController.cameraButton.userInteractionEnabled = YES;
    });
}

-(void)showResetAlertWithTitle:(NSString *)title Message:(NSString *)message
{
    if ([[self getDeviceiOSVersion] floatValue] < 8.0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Yes",nil];
        alert.tag = 5000;
        [alert show];
    }
    else
    {
        UIAlertController * alert        = [UIAlertController
                                            alertControllerWithTitle:title
                                            message:message
                                            preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction     * resetAction  = [UIAlertAction
                                            actionWithTitle:@"Yes"
                                            style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *action)
                                            {
                                                [self stopAnimatingActivityIndicator];
                                                [self resetApp];
                                            }];
        
        UIAlertAction     * cancelAction = [UIAlertAction
                                            actionWithTitle:@"Cancel"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action)
                                            {
                                                [self closeAlertViewWithOutAction];
                                            }];
        
        [alert addAction:resetAction];
        [alert addAction:cancelAction];
        
        [self.rootViewController presentViewController:alert animated:YES completion:nil];
    }
}

-(void)showAlertForInternetErrorWithTitle:(NSString *)title Message:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self stopAnimatingActivityIndicator];
        if (self.rootViewController.step == StepOne || self.rootViewController.step == StepOneRepeat)
        {
            self.rootViewController.resetButton.hidden = YES;
        }
        
        if ([[self getDeviceiOSVersion] floatValue] < 8.0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            UIAlertController * alert       = [UIAlertController
                                               alertControllerWithTitle:title
                                               message:message
                                               preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction     * okButton    = [UIAlertAction
                                               actionWithTitle:@"Ok"
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action)
                                               {
                                                   [self closeAlertViewWithOutAction];
                                               }];
            [alert addAction:okButton];
            [self.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

- (BOOL)text:(NSString *)string containsString:(NSString*)other
{
    if ([string rangeOfString:other].location == NSNotFound)
    {
        return NO;
    }
    return YES;
}

-(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^
       {
           if ([self text:message containsString:@"no device detected"])
           {
               [text_to_speech_manager readText:@"please ensure that your cell phone is not covered up and it is inside the phone grid outlines" afterDelay:0.0];
           }
           else
           {
               [text_to_speech_manager readText:@"please ensure that your feet is inside the feet grid outlines" afterDelay:0.0];
           }
           
           if ([[self getDeviceiOSVersion] floatValue] < 8.0)
           {
               UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Ok",nil];
               [alert show];
           }
           else
           {
               UIAlertController * alert       = [UIAlertController
                                                  alertControllerWithTitle:title
                                                  message:message
                                                  preferredStyle:UIAlertControllerStyleAlert];
               
               UIAlertAction     * okButton    = [UIAlertAction
                                                  actionWithTitle:@"Ok"
                                                  style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                                                  {
                                                      [self closeAlertViewWithOutAction];
                                                  }];
               [alert addAction:okButton];
               [self.rootViewController presentViewController:alert animated:YES completion:nil];
           }
       });
}

-(void)showAlertWithTitle:(NSString *)title Message:(NSString *)message andAction:(NSString *)okAction
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if ([self text:message containsString:@"no device detected"])
        {
            [text_to_speech_manager readText:@"please ensure that your cell phone is not covered up and it is inside the phone grid outlines" afterDelay:0.0];
        }
        else
        {
            [text_to_speech_manager readText:@"please ensure that your feet is inside the feet grid outlines" afterDelay:0.0];
        }
        
        if ([[self getDeviceiOSVersion] floatValue] < 8.0)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                             message:message
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"Ok",nil];
            alert.tag = 6000;
            actionString = okAction;
            [alert show];
        }
        else
        {
            UIAlertController * alert       = [UIAlertController
                                               alertControllerWithTitle:title
                                               message:message
                                               preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction     * okButton    = [UIAlertAction
                                               actionWithTitle:@"Ok"
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action)
                                               {
                                                   if (okAction)
                                                   {
                                                       [self closeAlertViewWithAction:okAction];
                                                   }
                                                   else
                                                   {
                                                       [self closeAlertViewWithOutAction];
                                                   }
                                               }];
            [alert addAction:okButton];
            [self.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if (alertView.tag == 6000)
        {
            if (!actionString) return;
            
            if ([actionString isEqualToString:PresentImagePicker])
            {
                [self.rootViewController presentImagePicker];
            }
        }
    }
    else if (buttonIndex == 1)
    {
        if (alertView.tag == 5000)  // Reset - alert view
        {
            [self stopAnimatingActivityIndicator];
            [self resetApp];
        }
    }
}

-(void)closeAlertViewWithOutAction
{
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)closeAlertViewWithAction:(NSString *)action
{
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil];
    
    if ([action isEqualToString:PresentImagePicker])
    {
        [self.rootViewController presentImagePicker];
    }
}

-(void)handleError:(NSError *)error
{
    if (error.code == -1009)
    {
        [self showAlertForInternetErrorWithTitle:@"Internet Connection Error" Message:@"The Internet connection appears to be offline. Please connect to the internet and then try again."];
    }
    else if (error.code == -1005)
    {
        [self showAlertForInternetErrorWithTitle:@"Internet Connection Error" Message:@"The network connection was lost. Please connect to the internet and then try again."];
    }
    else if (error.code == -1004)
    {
        [self showAlertForInternetErrorWithTitle:@"Error" Message:@"Could not connect to the server. Please try again."];
    }
    else if (error.code == -1001)
    {
        [self showAlertForInternetErrorWithTitle:@"Error" Message:@"The request timed out. Please try again."];
    }
    else
    {
        [self showAlertForInternetErrorWithTitle:@"Error" Message:@"It seems the connection was lost. Please try again."];
    }
}

-(void)resetApp
{
    [linux_webservice_manager   cancelAllRunningTasks];
    [windows_webservice_manager cancelAllRunningTasks];
    
    self.rootViewController.resetButton.hidden  = YES;
    self.rootViewController.step                = StepOne;
    //[self.rootViewController dismissImagePickerController];
    [text_to_speech_manager readText:@"welcome to fitted solution, tap on info for app instructions." afterDelay:0.1];
}

- (void)showMeasuredPopup
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        self.rootViewController.popUpContainerView.alpha  = 0.9;
        self.rootViewController.popUpContainerView.hidden = NO;
        self.rootViewController.popUpView.hidden          = NO;
        self.rootViewController.popUpView.transform       = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
        
        [UIView animateWithDuration:0.3/1.5 animations:^
         {
             self.rootViewController.popUpView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
         }
         completion:^(BOOL finished)
         {
             [UIView animateWithDuration:0.3/2 animations:^
              {
                  self.rootViewController.popUpView.transform = CGAffineTransformIdentity;
              }
              completion:^(BOOL finished)
              {
                  [self performSelector:@selector(hideMeasuredPopup) withObject:nil afterDelay:2.0];
              }];
         }];
    });
}

- (void)hideMeasuredPopup
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [UIView animateWithDuration:0.3/1.5 animations:^
         {
             self.rootViewController.popUpView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
         }
         completion:^(BOOL finished)
         {
             [UIView animateWithDuration:0.3/2 animations:^
              {
                  self.rootViewController.popUpView.transform = CGAffineTransformIdentity;
                  self.rootViewController.popUpContainerView.alpha  = 0;
                  self.rootViewController.popUpContainerView.hidden = YES;
                  self.rootViewController.popUpView.hidden          = YES;
              }];
         }];
    });
}

- (void)removeTutorialViewFromMainViewWithAnimation:(NSString *)animation
{
    [self.rootViewController removeTutorialViewFromMainViewWithAnimation:animation];
}

-(void)makeCircularView:(UIView *)view withCornerRadius:(float)radius
{
    view.layer.cornerRadius  = radius;
    view.layer.masksToBounds = YES;
}

-(NSData *)addPhoneModelAndNameToImageMetaData:(UIImage *)image
{
    NSData *jpeg = UIImageJPEGRepresentation(image, 1);
    
    CGImageSourceRef  source ;
    source = CGImageSourceCreateWithData((CFDataRef)jpeg, NULL);
    
    //get all the metadata in the image
    NSDictionary *metadata = (NSDictionary *) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source,0,NULL));
    
    //make the metadata dictionary mutable so we can add properties to it
    NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];
    
    NSMutableDictionary *TIFFDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyTIFFDictionary]mutableCopy];
    
    if(!TIFFDictionary)
    {
        //if the image does not have an TIFF dictionary (not all images do), then create one for us to use
        TIFFDictionary = [NSMutableDictionary dictionary];
    }
    
    NSLog(@"Device Name : %@", [UIDeviceHardware platformString]);
    
    if ([[UIDeviceHardware platformString] hasPrefix:@"iPhone"])
    {
        [TIFFDictionary setValue:@"iPhone" forKey:(NSString *)kCGImagePropertyTIFFMake];
    }
    else if([[UIDeviceHardware platformString] hasPrefix:@"iPod"])
    {
        [TIFFDictionary setValue:@"iPod" forKey:(NSString *)kCGImagePropertyTIFFMake];
    }
    
    [TIFFDictionary setValue:[UIDeviceHardware platformString] forKey:(NSString *)kCGImagePropertyTIFFModel];
    
    //add our modified TIFF data back into the image’s metadata
    [metadataAsMutable setObject:TIFFDictionary forKey:(NSString *)kCGImagePropertyTIFFDictionary];
    
    
    CFStringRef UTI = CGImageSourceGetType(source); //this is the type of image (e.g., public.jpeg)
    
    //this will be the data CGImageDestinationRef will write into
    NSMutableData *dest_data = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data,UTI,1,NULL);
    
    if(!destination)
    {
        NSLog(@"***Could not create image destination ***");
    }
    
    //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination,source,0, (CFDictionaryRef) metadataAsMutable);
    
    //tell the destination to write the image data and metadata into our data object.
    //It will return false if something goes wrong
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    
    if(!success)
    {
        NSLog(@"***Could not create data from image destination ***");
    }
    
    //now we have the data ready to go, so do whatever you want with it
    //here we just write it to disk at the same path we were passed
    //[dest_data writeToFile:fullPath atomically:YES];
    
    //cleanup
    CFRelease(destination);
    CFRelease(source);

    NSDate *date = [NSDate date];
    ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
    [al writeImageDataToSavedPhotosAlbum:dest_data metadata:metadataAsMutable completionBlock:^(NSURL *assetUrl, NSError *error)
    {
        NSLog(@"Image with metadata saving time : %f ", [[NSDate date] timeIntervalSinceDate:date]);
    }];
    
    return dest_data;
}

@end

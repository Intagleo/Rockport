//
//  WindowsWebserviceManager.m
//  FittedSolution
//
//  Created by Waqar Ali on 05/07/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import "WindowsWebserviceManager.h"
#import "LinuxServerResponseHandler.h"
#import "XMLReader.h"
#import "FootDescription.h"
#import "AppManager.h"

#define WINDOWS_SIDE_FOOT_IMAGE_SEGMENTATIONUPLOAD_URL   @"http://207.178.170.24/FittedSolutionsServices.asmx?op=SideFootUpload"
#define WINDOWS_FRONT_FOOT_IMAGE_SEGMENTATIONUPLOAD_URL  @"http://207.178.170.24/FittedSolutionsServices.asmx?op=FrontFootUpload"

@interface WindowsWebserviceManager()
{
    NSURLSessionDataTask * windowsSideFootSegmentationTask;
    NSURLSessionDataTask * windowsFrontFootSegmentationTask;
}
@end

@implementation WindowsWebserviceManager

+(WindowsWebserviceManager *)sharedInstance
{
    static WindowsWebserviceManager *instance = nil;
    
    if (!instance)
    {
        instance = [WindowsWebserviceManager new];
    }
    return instance;
}

-(void)uploadSideFootImageForSegmentation:(NSData *)sideFootImageData withSideFootBoundedBox:(BoundedBox)sideFootBox andPhoneBoundedBox:(BoundedBox)phoneBox block:(void (^)(FootDescription *))response errorMessage:(void(^)(NSString *)) error
{
    NSLog(@"Windows--> Side Foot JPEG Image length : %f Kb",(unsigned long)sideFootImageData.length/1024.0f);
    NSLog(@"Windows--> Side Foot JPEG Image length : %f Mb",(unsigned long)sideFootImageData.length/1024.0f/1024.0);
    
    NSString * deviceLength;
    if (linux_webservice_manager.isHaar)
    {
        deviceLength  = [UIDeviceHardware deviceLength];
    }
    else
    {
        deviceLength  = @"5.44";
    }
    
    NSDictionary * headers              = @{ @"SOAPAction": @"http://tempuri.org/SideFootUpload",
                                             @"content-type": @"text/xml; charset=utf-8",
                                             @"cache-control": @"no-cache",
                                           };
    NSString     * base64String         = [sideFootImageData base64EncodedStringWithOptions:0];
    
    NSString * sideFootBoxX = [NSString stringWithFormat:@"%d",sideFootBox.x];
    NSString * sideFootBoxY = [NSString stringWithFormat:@"%d",sideFootBox.y];
    NSString * sideFootBoxW = [NSString stringWithFormat:@"%d",sideFootBox.w];
    NSString * sideFootBoxH = [NSString stringWithFormat:@"%d",sideFootBox.h];

    NSString * phoneBoxX    = [NSString stringWithFormat:@"%d",phoneBox.x];
    NSString * phoneBoxY    = [NSString stringWithFormat:@"%d",phoneBox.y];
    NSString * phoneBoxW    = [NSString stringWithFormat:@"%d",phoneBox.w];
    NSString * phoneBoxH    = [NSString stringWithFormat:@"%d",phoneBox.h];
    
    
    NSData   * segmentData  = [[NSData alloc] initWithData:[
                                                                [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><SideFootUpload xmlns=\"http://tempuri.org/\"><Image>%@</Image><pointA>%@</pointA><pointB>%@</pointB><pointC>%@</pointC><pointD>%@</pointD><Left_x1_device>%@</Left_x1_device><Top_y1_device>%@</Top_y1_device><width_device>%@</width_device><height_device>%@</height_device><deviceLengthFromCode>%@</deviceLengthFromCode></SideFootUpload></soap:Body></soap:Envelope>",base64String,sideFootBoxX,sideFootBoxY,sideFootBoxW,sideFootBoxH,phoneBoxX,phoneBoxY,phoneBoxW,phoneBoxH, deviceLength]
                                                                dataUsingEncoding:NSUTF8StringEncoding]
                                                            ];
    
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:WINDOWS_SIDE_FOOT_IMAGE_SEGMENTATIONUPLOAD_URL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:segmentData];
    [request setTimeoutInterval:5*60];
    
    windowsSideFootSegmentationTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *_data, NSURLResponse *_response, NSError *_error)
    {
         NSString * errorString;
        
        if (_error)
        {
            [app_manager handleError:_error];
            errorString = @"";
            error(errorString);
        }
        else
        {
            NSDictionary * responseDict = [XMLReader dictionaryForXMLData:_data options:XMLReaderOptionsProcessNamespaces error:&_error];
            
            NSLog(@"windowsSideFootSegmentationTask response : %@",responseDict);
            
            NSString     * errorMsg = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"SideFootUploadResponse"] valueForKey:@"SideFootUploadResult"] valueForKey:@"ErrorMessage"] valueForKey:@"text"];
            
            if ([errorMsg length] != 0)
            {
                errorString = [NSString stringWithFormat:@"Error : %@",errorMsg];
                error(errorString);
            }
            else
            {
                FootDescription * footDescription = [[FootDescription alloc] init];
                
                footDescription.sideID       = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"SideFootUploadResponse"] valueForKey:@"SideFootUploadResult"] valueForKey:@"sideID"] valueForKey:@"text"];
                footDescription.resultID     = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"SideFootUploadResponse"] valueForKey:@"SideFootUploadResult"] valueForKey:@"resultID"] valueForKey:@"text"];
                footDescription.archDistance = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"SideFootUploadResponse"] valueForKey:@"SideFootUploadResult"] valueForKey:@"ArchDistance"] valueForKey:@"text"];
                footDescription.archHeight   = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"SideFootUploadResponse"] valueForKey:@"SideFootUploadResult"] valueForKey:@"ArchHeight"] valueForKey:@"text"];
                footDescription.footLength   = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"SideFootUploadResponse"] valueForKey:@"SideFootUploadResult"] valueForKey:@"FootLength"] valueForKey:@"text"];
                footDescription.men_Euro     = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"SideFootUploadResponse"]valueForKey:@"SideFootUploadResult"] valueForKey:@"MenEuro"] valueForKey:@"text"];
                footDescription.men_UK       = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"SideFootUploadResponse"] valueForKey:@"SideFootUploadResult"] valueForKey:@"MenUK"] valueForKey:@"text"];
                footDescription.men_US       = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"SideFootUploadResponse"]valueForKey:@"SideFootUploadResult"] valueForKey:@"MenUS"] valueForKey:@"text"];
                footDescription.resultID     = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"SideFootUploadResponse"]valueForKey:@"SideFootUploadResult"] valueForKey:@"ResultID"] valueForKey:@"text"];
                footDescription.sideID       = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"SideFootUploadResponse"] valueForKey:@"SideFootUploadResult"] valueForKey:@"SideID"] valueForKey:@"text"];
                footDescription.talusHeight  = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"SideFootUploadResponse"]valueForKey:@"SideFootUploadResult"] valueForKey:@"TalusHeight"] valueForKey:@"text"];
                footDescription.talusSlope   = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"SideFootUploadResponse"]valueForKey:@"SideFootUploadResult"] valueForKey:@"TalusSlope"] valueForKey:@"text"];
                footDescription.toeBoxHeight = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"SideFootUploadResponse"]valueForKey:@"SideFootUploadResult"] valueForKey:@"ToeBoxHeight"] valueForKey:@"text"];
                footDescription.women_Euro   = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"SideFootUploadResponse"]valueForKey:@"SideFootUploadResult"] valueForKey:@"WomenEuro"] valueForKey:@"text"];
                footDescription.women_UK     = [[[[[[responseDict valueForKey:@"Envelope"]valueForKey:@"Body"] valueForKey:@"SideFootUploadResponse"]valueForKey:@"SideFootUploadResult"] valueForKey:@"WomenUK"] valueForKey:@"text"];
                footDescription.women_US     = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"SideFootUploadResponse"]                  valueForKey:@"SideFootUploadResult"] valueForKey:@"WomenUS"] valueForKey:@"text"];
                 
                response(footDescription);
            }
         }
     }];
    [windowsSideFootSegmentationTask resume];
}

-(void)uploadFrontFootImageForSegmentation:(NSData *)frontFootImageData withFrontFootBoundedBox:(BoundedBox)frontFootBox phoneBoundedBox:(BoundedBox)phoneBox sideID:(NSString *)sideID andResultID:(NSString *)resultID block:(void (^)(FootDescription *))response errorMessage:(void(^)(NSString *)) error
{
    NSLog(@"Windows--> Front Foot JPEG Image length : %f Kb",(unsigned long)frontFootImageData.length/10240.0f);
    NSLog(@"Windows--> Front Foot JPEG Image length : %f Mb",(unsigned long)frontFootImageData.length/10240.0f/1024.0f);
    
    NSLog(@"------------____------ resultID : %@",resultID);
    
    NSString * deviceLength;
    if (linux_webservice_manager.isHaar)
    {
        deviceLength  = [UIDeviceHardware deviceLength];
    }
    else
    {
        deviceLength  = @"5.44";
    }
    
    NSDictionary * headers              =   @{ @"SOAPAction": @"http://tempuri.org/FrontFootUpload",
                                               @"content-type": @"text/xml; charset=utf-8",
                                               @"cache-control": @"no-cache",
                                             };
    
    NSString     * base64String         =    [frontFootImageData base64EncodedStringWithOptions:0];

    NSString * frontFootBoxX = [NSString stringWithFormat:@"%d",frontFootBox.x];
    NSString * frontFootBoxY = [NSString stringWithFormat:@"%d",frontFootBox.y];
    NSString * frontFootBoxW = [NSString stringWithFormat:@"%d",frontFootBox.w];
    NSString * frontFootBoxH = [NSString stringWithFormat:@"%d",frontFootBox.h];
    
    NSString * phoneBoxX     = [NSString stringWithFormat:@"%d",phoneBox.x];
    NSString * phoneBoxY     = [NSString stringWithFormat:@"%d",phoneBox.y];
    NSString * phoneBoxW     = [NSString stringWithFormat:@"%d",phoneBox.w];
    NSString * phoneBoxH     = [NSString stringWithFormat:@"%d",phoneBox.h];
    
    NSData   * segmentData   =    [[NSData alloc] initWithData:[
                                                                   [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><FrontFootUpload xmlns=\"http://tempuri.org/\"><Image>%@</Image><pointA>%@</pointA><pointB>%@</pointB><pointC>%@</pointC><pointD>%@</pointD><SideID>%@</SideID><ResultID>%@</ResultID><Left_x1_device>%@</Left_x1_device><Top_y1_device>%@</Top_y1_device><width_device>%@</width_device><height_device>%@</height_device><deviceLengthFromCode>%@</deviceLengthFromCode></FrontFootUpload></soap:Body></soap:Envelope>",base64String,frontFootBoxX,frontFootBoxY,frontFootBoxW,frontFootBoxH,sideID,resultID,phoneBoxX,phoneBoxY,phoneBoxW,phoneBoxH, deviceLength]
                                                                   dataUsingEncoding:NSUTF8StringEncoding]
                                                                ];
    
    NSMutableURLRequest *request        = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:WINDOWS_FRONT_FOOT_IMAGE_SEGMENTATIONUPLOAD_URL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:segmentData];
    [request setTimeoutInterval:5*60];
    
    windowsFrontFootSegmentationTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *_response, NSError *_error)
    {
          NSString * errorString;
        
          if (_error)
          {
              NSLog(@"%@", _error);
              [app_manager handleError:_error];
              errorString = @"";
              error(errorString);
          }
          else
          {
              NSDictionary * responseDict  = [XMLReader dictionaryForXMLData:data options:XMLReaderOptionsProcessNamespaces error:&_error];
              
              NSLog(@"windowsFrontFootSegmentationTask response : %@",responseDict);
              
              NSString     * errorMsg      = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"FrontFootUploadResponse"] valueForKey:@"FrontFootUploadResult"] valueForKey:@"ErrorMessage"] valueForKey:@"text"];
              
              if ([errorMsg length] != 0)
              {
                  errorString = [NSString stringWithFormat:@"Error : %@",errorMsg];
                  error(errorString);
              }
              else
              {
                  FootDescription * footDescription = [[FootDescription alloc] init];
                
                  footDescription.footWidh          = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"FrontFootUploadResponse"] valueForKey:@"FrontFootUploadResult"] valueForKey:@"FootWidth"] valueForKey:@"text"];
                  footDescription.menWidthCode      = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"FrontFootUploadResponse"] valueForKey:@"FrontFootUploadResult"] valueForKey:@"MenWidthCode"] valueForKey:@"text"];
                  footDescription.womenWidthCode    = [[[[[[responseDict valueForKey:@"Envelope"] valueForKey:@"Body"] valueForKey:@"FrontFootUploadResponse"] valueForKey:@"FrontFootUploadResult"] valueForKey:@"WomenWidthCode"] valueForKey:@"text"];
                  
                  response(footDescription);
              }
          }
    }];
    
    [windowsFrontFootSegmentationTask resume];
}

-(void)cancelAllRunningTasks
{
    if (windowsSideFootSegmentationTask)
    {
        [windowsSideFootSegmentationTask cancel];
    }
    
    if (windowsFrontFootSegmentationTask)
    {
        [windowsFrontFootSegmentationTask cancel];
    }
}

@end

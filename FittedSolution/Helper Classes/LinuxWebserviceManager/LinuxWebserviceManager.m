//
//  LinuxWebserviceManager.m
//  FittedSolution
//
//  Created by Waqar Ali on 05/07/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import "LinuxWebserviceManager.h"
#import "AppManager.h"

// new
// 198.199.89.153 or 207.178.170.24
// @"http://198.199.89.153:5060/detect_side"
// @"http://198.199.89.153:5060/detect_front"

// old
// @"http://45.55.156.47:5060/detect_side"
// @"http://45.55.156.47:5060/detect_front"


//intagleo new
#define CNN_Linux_SideFoot_URL @"http://35.160.0.102/detect_side.php"
#define CNN_Linux_FronFoot_URL @"http://35.160.0.102/detect_front.php"

//client
#define Haar_Linux_SideFoot_URL @"http://162.243.160.160:5060/detect_side"
#define Haar_Linux_FronFoot_URL @"http://162.243.160.160:5060/detect_front"

@interface LinuxWebserviceManager()
{
    NSURLSessionTask * footImagesValidationTask       ;
    NSURLSessionTask * linuxSideFootValidationTask    ;
    NSURLSessionTask * linuxFrontFootValidationTask   ;
}

@end

@implementation LinuxWebserviceManager

static LinuxWebserviceManager *instance = nil;

+(LinuxWebserviceManager *)sharedInstance
{
    if (!instance)
    {
        instance = [LinuxWebserviceManager new];
    }
    return instance;
}


-(void)validateSideFootImage:(NSData *)sideFootImageData andFrontFootImage:(NSData *)frontFootImageData block:(void (^)(NSData *responseData))responseData errorMessage:(void(^)(NSError * error))error
{
    //NSString * postLength            = [NSString stringWithFormat:@"%d", (int)[sideFootImageData length]];
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
    
//    if (_isHaar)
//    {
//        [request setURL:[NSURL URLWithString:Haar_Linux_SideFoot_URL]];
//    }
//    else
//    {
//        [request setURL:[NSURL URLWithString:CNN_Linux_SideFoot_URL]];
//    }
    
    [request setURL:[NSURL URLWithString:@"http://192.168.101.51:8080/newservice/send_images.php"]];
    
    
    //    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    //    [request setHTTPBody:sideFootImageData];
        [request setTimeoutInterval:1390.0];
    
    
    //////////////////
    
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"BOUNDRY";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"sideFoot\"; filename=\"sideFoot.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:sideFootImageData]];
    
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"frontFoot\"; filename=\"frontFoot.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:frontFootImageData]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    ///////////////////
    
    
    footImagesValidationTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable _data, NSURLResponse * _Nullable _response, NSError * _Nullable _error)
                                   {
                                       if (_error)
                                       {
                                           error(_error);
                                       }
                                       else
                                       {
                                           responseData(_data);
                                       }
                                   }];
    
    [footImagesValidationTask resume];
}



-(void)validateSideFootImage:(NSData *)sideFootImageData block:(void (^)(NSData *responseData))responseData errorMessage:(void(^)(NSError * error))error
{
    //NSData   * sideFootImageData     = UIImagePNGRepresentation(sideFootImage); //UIImageJPEGRepresentation(sideFootImage, ImageCompressionRate);
    
    NSString * postLength            = [NSString stringWithFormat:@"%d", (int)[sideFootImageData length]];
    
    NSLog(@"Linux--> Side Foot JPEG Image length : %f Kb",(unsigned long)sideFootImageData.length/1024.0f);
    NSLog(@"Linux--> Side Foot JPEG Image length : %f Mb",(unsigned long)sideFootImageData.length/1024.0f/1024.0f);
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
    
    if (_isHaar)
    {
        [request setURL:[NSURL URLWithString:Haar_Linux_SideFoot_URL]];
    }
    else
    {
        [request setURL:[NSURL URLWithString:CNN_Linux_SideFoot_URL]];
    }
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:sideFootImageData];
    [request setTimeoutInterval:1390.0];
    
    linuxSideFootValidationTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable _data, NSURLResponse * _Nullable _response, NSError * _Nullable _error)
    {
        if (_error)
        {
            error(_error);
        }
        else
        {
            responseData(_data);
        }
    }];
    
    [linuxSideFootValidationTask resume];
}

-(void)validateFrontFootImage:(NSData *)frontFootImageData block:(void (^)(NSData *responseData))responseData errorMessage:(void(^)(NSError * error)) error
{
    //NSData   * frontFootImageData   = UIImagePNGRepresentation(frontFootImage); //UIImageJPEGRepresentation(frontFootImage, ImageCompressionRate);
    
    NSString * postLength           = [NSString stringWithFormat:@"%d", (int)[frontFootImageData length]];
    
    NSLog(@"Linux--> Front Foot JPEG Image length : %f Kb",(unsigned long)frontFootImageData.length/1024.0f);
    NSLog(@"Linux--> Front Foot JPEG Image length : %f Mb",(unsigned long)frontFootImageData.length/1024.0f/1024.0f);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    if (_isHaar)
    {
        [request setURL:[NSURL URLWithString:Haar_Linux_FronFoot_URL]];
    }
    else
    {
        [request setURL:[NSURL URLWithString:CNN_Linux_FronFoot_URL]];
    }
    
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:frontFootImageData];
    [request setTimeoutInterval:1390.0];
    
    
    linuxFrontFootValidationTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable _data, NSURLResponse * _Nullable _response, NSError * _Nullable _error)
      {
          if (_error)
          {
              error(_error);
          }
          else
          {
              responseData(_data);
          }
      }];
    [linuxFrontFootValidationTask resume];
}

-(void)cancelAllRunningTasks
{
    if (footImagesValidationTask)
    {
        [footImagesValidationTask cancel];
    }
    
    if (linuxSideFootValidationTask)
    {
        [linuxSideFootValidationTask cancel];
    }
    
    if (linuxFrontFootValidationTask)
    {
        [linuxFrontFootValidationTask cancel];
    }
}

@end

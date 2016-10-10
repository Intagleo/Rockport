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


#define Linux_SideFoot_URL @"http://198.199.89.153:5060/detect_side"
#define Linux_FronFoot_URL @"http://198.199.89.153:5060/detect_front"

@interface LinuxWebserviceManager()
{
    NSURLSessionTask * linuxSideFootValidationTask    ;
    NSURLSessionTask * linuxFrontFootValidationTask   ;
}
@end

@implementation LinuxWebserviceManager

+(LinuxWebserviceManager *)sharedInstance
{
    static LinuxWebserviceManager *instance = nil;
    
    if (!instance)
    {
        instance = [LinuxWebserviceManager new];
    }
    return instance;
}

-(void)validateSideFootImage:(NSData *)sideFootImageData block:(void (^)(NSData *responseData))responseData errorMessage:(void(^)(NSError * error))error
{
    //NSData   * sideFootImageData     = UIImagePNGRepresentation(sideFootImage); //UIImageJPEGRepresentation(sideFootImage, ImageCompressionRate);
    
    NSString * postLength            = [NSString stringWithFormat:@"%d", (int)[sideFootImageData length]];
    
    NSLog(@"Linux--> Side Foot JPEG Image length : %f Kb",(unsigned long)sideFootImageData.length/1024.0f);
    NSLog(@"Linux--> Side Foot JPEG Image length : %f Mb",(unsigned long)sideFootImageData.length/1024.0f/1024.0f);
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:Linux_SideFoot_URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:sideFootImageData];
    [request setTimeoutInterval:90.0];
    
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
    [request setURL:[NSURL URLWithString:Linux_FronFoot_URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:frontFootImageData];
    [request setTimeoutInterval:90.0];
    
    
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

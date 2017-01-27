//
//  LinuxWebserviceManager.m
//  FittedSolution
//
//  Created by Waqar Ali on 05/07/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import "LinuxWebserviceManager.h"
#import "AppManager.h"

//intagleo new
#define CNN_Linux_SideFoot_URL @"http://52.25.36.236/detection/side"
#define CNN_Linux_FronFoot_URL @"http://52.25.36.236/detection/front"

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

- (void)uploadToServerUsingSideImage:(NSData *)sideImageData frontImageData:(NSData *)frontImageData withSideFileName:(NSString *)sideFilename andFrontFileName:(NSString *)frontFilename
{
    // set this to your server's address
    NSString *urlString =  @"http://192.168.101.51:8080/newservice/servicetest.php"; //@"http://192.168.101.51:8080/newservice/send_images.php";
    
    // set the content type, in this case it needs to be: "Content-Type: image/jpg"
    // Extract 'jpg' or 'png' from the last three characters of 'filename'
//    if (([filename length] -3 ) > 0)
//    {
//        NSString *contentType = [NSString stringWithFormat:@"Content-Type: image/%@", [filename substringFromIndex:[filename length] - 3]];
//    }
    
    // allocate and initialize the mutable URLRequest, set URL and method.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    // define the boundary and newline values
    NSString *boundary = @"uwhQ9Ho7y873Ha";
    NSString *kNewLine = @"\r\n";
    
    // Set the URLRequest value property for the HTTP Header
    // Set Content-Type as a multi-part form with boundary identifier
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // prepare a mutable data object used to build message body
    NSMutableData *body = [NSMutableData data];
    
    // set the first boundary
    [body appendData:[[NSString stringWithFormat:@"--%@%@", boundary, kNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Set the form type and format
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"%@", @"side_uploaded_file", sideFilename, kNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: image/jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Now append the image itself.  For some servers, two carriage-return line-feeds are necessary before the image
    [body appendData:[[NSString stringWithFormat:@"%@%@", kNewLine, kNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:sideImageData];
    [body appendData:[kNewLine dataUsingEncoding:NSUTF8StringEncoding]];
    
    //
    
    // set the first boundary
    [body appendData:[[NSString stringWithFormat:@"--%@%@", boundary, kNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Set the form type and format
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"%@", @"front_uploaded_file", frontFilename, kNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: image/jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Now append the image itself.  For some servers, two carriage-return line-feeds are necessary before the image
    [body appendData:[[NSString stringWithFormat:@"%@%@", kNewLine, kNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:frontImageData];
    [body appendData:[kNewLine dataUsingEncoding:NSUTF8StringEncoding]];
    
    //
    
    // Add the terminating boundary marker & append a newline
    [body appendData:[[NSString stringWithFormat:@"--%@--", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[kNewLine dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Setting the body of the post to the request.
    [request setHTTPBody:body];
    
    // TODO: Next three lines are only used for testing using synchronous conn.
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"==> sendSyncReq returnString: %@", returnString);
    
    // You will probably want to replace above 3 lines with asynchronous connection
    //    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

-(void)validateSideFootImage:(NSData *)sideFootImageData andFrontFootImage:(NSData *)frontFootImageData block:(void (^)(NSData *responseData))responseData errorMessage:(void(^)(NSError * error))error
{
    [self uploadToServerUsingSideImage:sideFootImageData frontImageData:frontFootImageData withSideFileName:@"sideFoot.jpg" andFrontFileName:@"frontFoot.jpg"];
}

/////////////////////////////////////////////////////////////////////////////////////


- (void)validateFrontFootImage:(NSData *)frontImageData withSideFootLength:(NSString *)sideFootLength block:(void (^)(NSData *responseData))responseData errorMessage:(void(^)(NSError * error)) error
{
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:[NSString stringWithFormat:@"%@",sideFootLength] forKey:@"sideFootLength"];
    
    NSString *BoundaryConstant  = @"----------V2ymHFg03ehbqgZCaKO6jy";
    NSString *FileParamConstant = @"file";
    
    NSURL* requestURL = [NSURL URLWithString:CNN_Linux_FronFoot_URL];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:200];
    [request setHTTPMethod:@"POST"];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    for (NSString *param in _params)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    if (frontImageData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"frontFoot.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:frontImageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setURL:requestURL];
    
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


-(void)validateSideFootImage:(NSData *)sideFootImageData block:(void (^)(NSData *responseData))responseData errorMessage:(void(^)(NSError * error))error
{
    NSString * postLength         = [NSString stringWithFormat:@"%d", (int)[sideFootImageData length]];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:CNN_Linux_SideFoot_URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:sideFootImageData];
    [request setTimeoutInterval:200];
    
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
    NSString * postLength        = [NSString stringWithFormat:@"%d", (int)[frontFootImageData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:CNN_Linux_FronFoot_URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:frontFootImageData];
    [request setTimeoutInterval:200];
    
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


////// HAAR //////

-(void)validateHAARSideFootImage:(NSData *)sideFootImageData block:(void (^)(NSData *responseData))responseData errorMessage:(void(^)(NSError * error))error
{
    NSString * postLength         = [NSString stringWithFormat:@"%d", (int)[sideFootImageData length]];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:Haar_Linux_SideFoot_URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:sideFootImageData];
    [request setTimeoutInterval:200];
    
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

-(void)validateHAARFrontFootImage:(NSData *)frontFootImageData block:(void (^)(NSData *responseData))responseData errorMessage:(void(^)(NSError * error)) error
{
    NSString * postLength        = [NSString stringWithFormat:@"%d", (int)[frontFootImageData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:Haar_Linux_FronFoot_URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:frontFootImageData];
    [request setTimeoutInterval:200];
    
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

//////////////////



@end

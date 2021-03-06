//
//  LinuxWebserviceManager.h
//  FittedSolution
//
//  Created by Waqar Ali on 05/07/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define linux_webservice_manager [LinuxWebserviceManager sharedInstance]

@interface LinuxWebserviceManager : NSObject

+(LinuxWebserviceManager *)sharedInstance;

-(void)validateSideFootImage:(NSData *)sideFootImageData andFrontFootImage:(NSData *)frontFootImageData block:(void (^)(NSData *responseData))responseData errorMessage:(void(^)(NSError * error))error;

-(void)validateSideFootImage:(NSData *)sideFootImageData block:(void (^)(NSData *responseData))res errorMessage:(void(^)(NSError * error)) err     ;
-(void)validateFrontFootImage:(NSData *)frontFootImageData block:(void (^)(NSData *responseData))res errorMessage:(void(^)(NSError * error)) err   ;
-(void)cancelAllRunningTasks;
- (void)validateFrontFootImage:(NSData *)frontImageData withSideFootLength:(NSString *)sideFootLength block:(void (^)(NSData *responseData))responseData errorMessage:(void(^)(NSError * error)) error;


////// HAAR //////

-(void)validateHAARSideFootImage:(NSData *)sideFootImageData block:(void (^)(NSData *responseData))responseData errorMessage:(void(^)(NSError * error))error;
-(void)validateHAARFrontFootImage:(NSData *)frontFootImageData block:(void (^)(NSData *responseData))responseData errorMessage:(void(^)(NSError * error)) error;

@end

//
//  LinuxServerResponseHandler.h
//  FittedSolution
//
//  Created by Waqar Ali on 01/08/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+Resize.h"
#import "AppManager.h"
#import "LinuxWebserviceManager.h"

#define linux_server_response_handler [LinuxServerResponseHandler sharedInstance]

@interface LinuxServerResponseHandler : NSObject

+(LinuxServerResponseHandler *)sharedInstance;

-(void)handleResponseForSideFoot:(NSData *)responseData block:(void (^)(NSArray *ba))boundedBoxArray errorMessage:(void(^)(NSString *))error;
-(void)handleResponseForFrontFoot:(NSData *)responseData block:(void (^)(NSArray *ba))boundedBoxArray errorMessage:(void(^)(NSString *))error;

@end


//
//  WindowsWebserviceManager.h
//  FittedSolution
//
//  Created by Waqar Ali on 05/07/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LinuxServerResponseHandler.h"
#import "FootDescription.h"

#define windows_webservice_manager [WindowsWebserviceManager sharedInstance]

@interface WindowsWebserviceManager : NSObject

+(WindowsWebserviceManager *)sharedInstance;

-(void)uploadSideFootImageForSegmentation:(NSData *)sideFootImageData withSideFootBoundedBox:(BoundedBox)sideFootBox andPhoneBoundedBox:(BoundedBox)phoneBox block:(void (^)(FootDescription *))response errorMessage:(void(^)(NSString *)) error;
-(void)uploadFrontFootImageForSegmentation:(NSData *)frontFootImageData withFrontFootBoundedBox:(BoundedBox)frontFootBox phoneBoundedBox:(BoundedBox)phoneBox sideID:(NSString *)sideID andResultID:(NSString *)resultID block:(void (^)(FootDescription *))response errorMessage:(void(^)(NSString *)) error;
-(void)cancelAllRunningTasks;

@end

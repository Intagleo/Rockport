//
//  CacheManager.h
//  FittedSolution
//
//  Created by Waqar Ali on 16/09/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import <Foundation/Foundation.h>

#define cache_manager             [CacheManager sharedInstance]

@interface CacheManager : NSObject

+(CacheManager *)sharedInstance;

- (void)saveAppLaunched;
- (BOOL)isAppAlreadyLaunched;

@end

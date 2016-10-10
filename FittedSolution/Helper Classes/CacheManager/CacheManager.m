//
//  CacheManager.m
//  FittedSolution
//
//  Created by Waqar Ali on 16/09/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import "CacheManager.h"

@implementation CacheManager

+(CacheManager *)sharedInstance
{
    static CacheManager *instance = nil;
    
    if (!instance)
    {
        instance = [CacheManager new];
    }
    return instance;
}

- (void)saveAppLaunched
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AppAlreadyLaunched"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isAppAlreadyLaunched
{
    BOOL isAppAlreadyLaunched = [[NSUserDefaults standardUserDefaults] boolForKey:@"AppAlreadyLaunched"];
    if (isAppAlreadyLaunched)
    {
        return YES;
    }
    return NO;
}

@end

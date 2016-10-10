//
//  UIDeviceHardware.h
//

#import <Foundation/Foundation.h>

@interface UIDeviceHardware : NSObject
    + (NSString *) platform;
    + (NSString *) platformString;
    + (float) deviceSizeDiagonal;
    + (NSString *) deviceLength;
@end

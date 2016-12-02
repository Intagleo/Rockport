//
//  LinuxServerResponseHandler.m
//  FittedSolution
//
//  Created by Waqar Ali on 01/08/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import "LinuxServerResponseHandler.h"
#import "XMLReader.h"

@implementation LinuxServerResponseHandler

+(LinuxServerResponseHandler *)sharedInstance
{
    static LinuxServerResponseHandler * instance = nil;
    
    if (!instance)
    {
        instance = [LinuxServerResponseHandler new];
    }
    return instance;
}

-(void)handleResponseForSideFoot:(NSData *)responseData block:(void (^)(NSArray *ba))boundedBoxArray errorMessage:(void(^)(NSString *))error
{
    if (linux_webservice_manager.isHaar)
    {
        // client old response handler
        NSString     * responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
        NSDictionary * toDict         = [self parseServerResponseFromString:responseString];
        
        if (!responseString)
        {
            error(@"Nil");
            return;
        }
        
        if ([[toDict objectForKey:@"code"] intValue] <= 0)
        {
            error([toDict objectForKey:@"error"]);
        }
        else if ([[toDict objectForKey:@"code"] intValue] == 1)
        {
            error(@"No bounding box for device received");
        }
        else if ([[toDict objectForKey:@"code"] intValue] == 2)
        {
            error(@"No bounding box for side foot received");
        }
        else if ([[toDict objectForKey:@"code"] intValue] == 3)
        {
            BoundedBox footBox, phoneBox;
            
            NSArray * footBoxArray   = [toDict objectForKey:@"footBoundedBox"];
            NSArray * phoneBoxArray  = [toDict objectForKey:@"phoneBoundedBox"];
            
            footBox.x                = [[footBoxArray objectAtIndex:0] intValue];
            footBox.y                = [[footBoxArray objectAtIndex:1] intValue];
            footBox.w                = [[footBoxArray objectAtIndex:2] intValue];
            footBox.h                = [[footBoxArray objectAtIndex:3] intValue];
            
            NSValue * footBoxObject  = [NSValue valueWithBytes:&footBox objCType:@encode(BoundedBox)];
            
            phoneBox.x               = [[phoneBoxArray objectAtIndex:0] intValue];
            phoneBox.y               = [[phoneBoxArray objectAtIndex:1] intValue];
            phoneBox.w               = [[phoneBoxArray objectAtIndex:2] intValue];
            phoneBox.h               = [[phoneBoxArray objectAtIndex:3] intValue];
            
            NSValue * phoneBoxObject = [NSValue valueWithBytes:&phoneBox objCType:@encode(BoundedBox)];
            
            NSArray * boxesArray     = [NSArray arrayWithObjects:footBoxObject,phoneBoxObject, nil];
            boundedBoxArray(boxesArray);
        }
        else
        {
            error(@"Side Foot image seems invalid");
        }
    }
    else
    {
        // intagleo new response handler
        NSError      * _error;
        NSDictionary * toDict         = [XMLReader dictionaryForXMLData:responseData options:XMLReaderOptionsProcessNamespaces error:&_error];
        NSString     * code           = [[[toDict objectForKey:@"data"] objectForKey:@"Code"] objectForKey:@"text"];
        
        NSLog(@"Side foot dict:\n %@",toDict);
        
        if ([code intValue] <= 0)
        {
            error([[[toDict objectForKey:@"data"] objectForKey:@"Error"] objectForKey:@"text"]);
        }
        else if ([code intValue] == 1)
        {
            error(@"No bounding box for device received.");
        }
        else if ([code intValue] == 2)
        {
            error(@"No bounding box for side foot received.");
        }
        else if ([code intValue] == 3)
        {
            BoundedBox footBox, phoneBox;
            
            footBox.x                = [[[[[toDict objectForKey:@"data"] objectForKey:@"FootBox"] objectForKey:@"pointX"] objectForKey:@"text"] intValue];
            footBox.y                = [[[[[toDict objectForKey:@"data"] objectForKey:@"FootBox"] objectForKey:@"pointY"] objectForKey:@"text"] intValue];
            footBox.w                = [[[[[toDict objectForKey:@"data"] objectForKey:@"FootBox"] objectForKey:@"width" ] objectForKey:@"text"] intValue];
            footBox.h                = [[[[[toDict objectForKey:@"data"] objectForKey:@"FootBox"] objectForKey:@"height"] objectForKey:@"text"] intValue];
            
            NSValue * footBoxObject  = [NSValue valueWithBytes:&footBox objCType:@encode(BoundedBox)];
            
            phoneBox.x               = [[[[[toDict objectForKey:@"data"] objectForKey:@"PhoneBox"] objectForKey:@"pointX"] objectForKey:@"text"] intValue];
            phoneBox.y               = [[[[[toDict objectForKey:@"data"] objectForKey:@"PhoneBox"] objectForKey:@"pointY"] objectForKey:@"text"] intValue];
            phoneBox.w               = [[[[[toDict objectForKey:@"data"] objectForKey:@"PhoneBox"] objectForKey:@"width" ] objectForKey:@"text"] intValue];
            phoneBox.h               = [[[[[toDict objectForKey:@"data"] objectForKey:@"PhoneBox"] objectForKey:@"height"] objectForKey:@"text"] intValue];
            
            NSValue * phoneBoxObject = [NSValue valueWithBytes:&phoneBox objCType:@encode(BoundedBox)];
            
            NSArray * boxesArray     = [NSArray arrayWithObjects:footBoxObject,phoneBoxObject, nil];
            boundedBoxArray(boxesArray);
        }
        else
        {
            error(@"Side Foot image seems invalid");
        }
    }
}

-(void)handleResponseForFrontFoot:(NSData *)responseData block:(void (^)(NSArray *ba))boundedBoxArray errorMessage:(void(^)(NSString *))error
{
    if (linux_webservice_manager.isHaar)
    {
        // client old response handler
        NSString     * responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
        NSDictionary * toDict         = [self parseServerResponseFromString:responseString];
        
        if (!responseString)
        {
            error(@"Nil");
            return;
        }
        
        if ([[toDict objectForKey:@"code"] intValue] <= 0)
        {
            error([toDict objectForKey:@"error"]);
        }
        else if ([[toDict objectForKey:@"code"] intValue] == 1)
        {
            error(@"No bounding box for device received");
        }
        else if ([[toDict objectForKey:@"code"] intValue] == 2)
        {
            error(@"No bounding box for front foot received");
        }
        else if ([[toDict objectForKey:@"code"] intValue] == 3)
        {
            BoundedBox footBox, phoneBox;
            
            NSArray * footBoxArray   = [toDict objectForKey:@"footBoundedBox"];
            NSArray * phoneBoxArray  = [toDict objectForKey:@"phoneBoundedBox"];
            
            footBox.x                = [[footBoxArray objectAtIndex:0] intValue];
            footBox.y                = [[footBoxArray objectAtIndex:1] intValue];
            footBox.w                = [[footBoxArray objectAtIndex:2] intValue];
            footBox.h                = [[footBoxArray objectAtIndex:3] intValue];
            
            NSValue * footBoxObject  = [NSValue valueWithBytes:&footBox objCType:@encode(BoundedBox)];
            
            phoneBox.x               = [[phoneBoxArray objectAtIndex:0] intValue];
            phoneBox.y               = [[phoneBoxArray objectAtIndex:1] intValue];
            phoneBox.w               = [[phoneBoxArray objectAtIndex:2] intValue];
            phoneBox.h               = [[phoneBoxArray objectAtIndex:3] intValue];
            
            NSValue * phoneBoxObject = [NSValue valueWithBytes:&phoneBox objCType:@encode(BoundedBox)];
            
            NSArray * boxesArray     = [NSArray arrayWithObjects:footBoxObject,phoneBoxObject, nil];
            boundedBoxArray(boxesArray);
        }
        else
        {
            error(@"Front Foot image seems invalid");
        }
    }
    else
    {
        // intagleo new response handler
        NSError      * _error;
        NSDictionary * toDict         = [XMLReader dictionaryForXMLData:responseData options:XMLReaderOptionsProcessNamespaces error:&_error];
        NSString     * code           = [[[toDict objectForKey:@"data"] objectForKey:@"Code"] objectForKey:@"text"];
        
        NSLog(@"Front foot dict:\n %@",toDict);
        
        if ([code intValue] <= 0)
        {
            error([[[toDict objectForKey:@"data"] objectForKey:@"Error"] objectForKey:@"text"]);
        }
        else if ([code intValue] == 1)
        {
            error(@"No bounding box for device received.");
        }
        else if ([code intValue] == 2)
        {
            error(@"No bounding box for front foot received.");
        }
        else if ([code intValue] == 3)
        {
            BoundedBox footBox, phoneBox;
            
            footBox.x                = [[[[[toDict objectForKey:@"data"] objectForKey:@"FootBox"] objectForKey:@"pointX"] objectForKey:@"text"] intValue];
            footBox.y                = [[[[[toDict objectForKey:@"data"] objectForKey:@"FootBox"] objectForKey:@"pointY"] objectForKey:@"text"] intValue];
            footBox.w                = [[[[[toDict objectForKey:@"data"] objectForKey:@"FootBox"] objectForKey:@"width" ] objectForKey:@"text"] intValue];
            footBox.h                = [[[[[toDict objectForKey:@"data"] objectForKey:@"FootBox"] objectForKey:@"height"] objectForKey:@"text"] intValue];
            
            NSValue * footBoxObject  = [NSValue valueWithBytes:&footBox objCType:@encode(BoundedBox)];
            
            phoneBox.x               = [[[[[toDict objectForKey:@"data"] objectForKey:@"PhoneBox"] objectForKey:@"pointX"] objectForKey:@"text"] intValue];
            phoneBox.y               = [[[[[toDict objectForKey:@"data"] objectForKey:@"PhoneBox"] objectForKey:@"pointY"] objectForKey:@"text"] intValue];
            phoneBox.w               = [[[[[toDict objectForKey:@"data"] objectForKey:@"PhoneBox"] objectForKey:@"width" ] objectForKey:@"text"] intValue];
            phoneBox.h               = [[[[[toDict objectForKey:@"data"] objectForKey:@"PhoneBox"] objectForKey:@"height"] objectForKey:@"text"] intValue];
            
            NSValue * phoneBoxObject = [NSValue valueWithBytes:&phoneBox objCType:@encode(BoundedBox)];
            
            NSArray * boxesArray     = [NSArray arrayWithObjects:footBoxObject,phoneBoxObject, nil];
            boundedBoxArray(boxesArray);
        }
        else
        {
            error(@"Front Foot image seems invalid");
        }
    }
}

#pragma mark - helper methods

-(NSDictionary *)parseServerResponseFromString:(NSString *)response
{
    response = [response stringByReplacingOccurrencesOfString:@"None" withString:@"()"];
    
    NSMutableDictionary * mutableDictionary = [[NSMutableDictionary alloc] init];
    
    NSArray * colonSeparatedResponseArray   = [response componentsSeparatedByString:@":"];
    
    NSString * code                         = [colonSeparatedResponseArray objectAtIndex:0];
    NSString * errorMsg;
    NSArray  * tempArray0, * tempArray1, * tempArray2, * tempArray3, * footBoundedBox, * phoneBoundedBox;
    
    NSMutableArray * footBox, * phoneBox;
    
    [mutableDictionary setObject:code forKey:@"code"];
    
    if ([code intValue] <= 0)
    {
        errorMsg             = [colonSeparatedResponseArray objectAtIndex:1];
        [mutableDictionary setObject:errorMsg forKey:@"error"];
    }
    else if ([code intValue] == 1)
    {
        tempArray0        = [response componentsSeparatedByString:@"()"];
        tempArray1        = [[tempArray0 objectAtIndex:0] componentsSeparatedByString:@"("];
        tempArray2        = [[tempArray1 objectAtIndex:1] componentsSeparatedByString:@")"] ;
        footBoundedBox    = [[tempArray2 objectAtIndex:0] componentsSeparatedByString:@","];
        
        footBox           = [[NSMutableArray alloc] init];
        footBox[0]        = [[footBoundedBox objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        footBox[1]        = [[footBoundedBox objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        footBox[2]        = [[footBoundedBox objectAtIndex:2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        footBox[3]        = [[footBoundedBox objectAtIndex:3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        [mutableDictionary setObject:footBox forKey:@"footBoundedBox"];
    }
    else if ([code intValue] == 2)
    {
        tempArray0        = [response componentsSeparatedByString:@"()"];
        tempArray1        = [[tempArray0 objectAtIndex:1] componentsSeparatedByString:@"("];
        tempArray2        = [[tempArray1 objectAtIndex:1] componentsSeparatedByString:@")"];
        phoneBoundedBox   = [[tempArray2 objectAtIndex:0] componentsSeparatedByString:@","];
        
        phoneBox          = [[NSMutableArray alloc] init];
        phoneBox[0]       = [[phoneBoundedBox objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        phoneBox[1]       = [[phoneBoundedBox objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        phoneBox[2]       = [[phoneBoundedBox objectAtIndex:2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        phoneBox[3]       = [[phoneBoundedBox objectAtIndex:3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        [mutableDictionary setObject:phoneBox forKey:@"phoneBoundedBox"];
    }
    else if ([code intValue] == 3)
    {
        tempArray1        = [[colonSeparatedResponseArray objectAtIndex:1] componentsSeparatedByString:@"("];
        tempArray2        = [[tempArray1 objectAtIndex:1] componentsSeparatedByString:@")"] ;
        tempArray3        = [[tempArray1 objectAtIndex:2] componentsSeparatedByString:@")"] ;
        footBoundedBox    = [[tempArray2 objectAtIndex:0] componentsSeparatedByString:@","];
        phoneBoundedBox   = [[tempArray3 objectAtIndex:0] componentsSeparatedByString:@","];
        
        footBox           = [[NSMutableArray alloc] init];
        footBox[0]        = [[footBoundedBox objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        footBox[1]        = [[footBoundedBox objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        footBox[2]        = [[footBoundedBox objectAtIndex:2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        footBox[3]        = [[footBoundedBox objectAtIndex:3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        [mutableDictionary setObject:footBox forKey:@"footBoundedBox"];
        
        phoneBox          = [[NSMutableArray alloc] init];
        phoneBox[0]       = [[phoneBoundedBox objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        phoneBox[1]       = [[phoneBoundedBox objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        phoneBox[2]       = [[phoneBoundedBox objectAtIndex:2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        phoneBox[3]       = [[phoneBoundedBox objectAtIndex:3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        [mutableDictionary setObject:phoneBox forKey:@"phoneBoundedBox"];
    }
    
    return mutableDictionary;
}

@end

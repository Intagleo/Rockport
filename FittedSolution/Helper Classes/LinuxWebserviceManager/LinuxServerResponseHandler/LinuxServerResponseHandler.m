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

-(void)handleResponseForSideFoot:(NSData *)responseData block:(void (^)(FootDescription *))sideFootDescription errorMessage:(void(^)(NSString *))error
{
    NSError      * _error;
    NSDictionary * toDict         = [XMLReader dictionaryForXMLData:responseData options:XMLReaderOptionsProcessNamespaces error:&_error];
    NSString     * code           = [[[toDict objectForKey:@"data"] objectForKey:@"Code"] objectForKey:@"text"];
    
    NSLog(@"Side foot dict:\n %@ \n____________________\n",toDict);
    
    if ([code intValue] <= 0)
    {
        error([[[toDict objectForKey:@"data"] objectForKey:@"Error"] objectForKey:@"text"]);
    }
    else if([code intValue] == 1)
    {
        FootDescription * footDescription = [[FootDescription alloc] init];
        
        footDescription.archDistance = [[[toDict objectForKey:@"data"] objectForKey:@"ArchDistance"] objectForKey:@"text"];
        footDescription.archHeight   = [[[toDict objectForKey:@"data"] objectForKey:@"ArchHeight"] objectForKey:@"text"];
        footDescription.footLength   = [[[toDict objectForKey:@"data"] objectForKey:@"FootLength"] objectForKey:@"text"];
        footDescription.talusHeight  = [[[toDict objectForKey:@"data"] objectForKey:@"TalusHeight"] objectForKey:@"text"];
        footDescription.talusSlope   = [[[toDict objectForKey:@"data"] objectForKey:@"TalusSlope"] objectForKey:@"text"];
        footDescription.toeBoxHeight = [[[toDict objectForKey:@"data"] objectForKey:@"ToeBoxHeight"] objectForKey:@"text"];
        footDescription.sideFootCutOutImageUrl = [[[toDict objectForKey:@"data"] objectForKey:@"ImagePath"] objectForKey:@"text"];
        
        sideFootDescription(footDescription);
    }
    else if ([code intValue] == 2)
    {
        error([[[toDict objectForKey:@"data"] objectForKey:@"Error"] objectForKey:@"text"]);
    }
    else
    {
        error(@"Side Foot image seems invalid");
    }
}

-(void)handleResponseForFrontFoot:(NSData *)responseData block:(void (^)(FootDescription *))frontFootDescription errorMessage:(void(^)(NSString *))error
{
    // intagleo new response handler
    NSError      * _error;
    NSDictionary * toDict         = [XMLReader dictionaryForXMLData:responseData options:XMLReaderOptionsProcessNamespaces error:&_error];
    NSString     * code           = [[[toDict objectForKey:@"data"] objectForKey:@"Code"] objectForKey:@"text"];
    
    NSLog(@"Front foot dict:\n %@ \n____________________\n",toDict);
    
    if ([code intValue] <= 0)
    {
        error([[[toDict objectForKey:@"data"] objectForKey:@"Error"] objectForKey:@"text"]);
    }
    else if ([code intValue] == 1)
    {
        FootDescription * footDescription = [[FootDescription alloc] init];
        footDescription.footWidh = [[[toDict objectForKey:@"data"] objectForKey:@"FootWidth"] objectForKey:@"text"];

        footDescription.men_Euro     = [[[toDict objectForKey:@"data"] objectForKey:@"MenEuro"] objectForKey:@"text"];
        footDescription.men_UK       = [[[toDict objectForKey:@"data"] objectForKey:@"MenUK"] objectForKey:@"text"];
        footDescription.men_US       = [[[toDict objectForKey:@"data"] objectForKey:@"MenUs"] objectForKey:@"text"];
        footDescription.women_Euro   = [[[toDict objectForKey:@"data"] objectForKey:@"WomenEuro"] objectForKey:@"text"];
        footDescription.women_UK     = [[[toDict objectForKey:@"data"] objectForKey:@"WomenUK"] objectForKey:@"text"];
        footDescription.women_US     = [[[toDict objectForKey:@"data"] objectForKey:@"WomenUs"] objectForKey:@"text"];
        footDescription.frontFootCutOutImageUrl = [[[toDict objectForKey:@"data"] objectForKey:@"ImagePath"] objectForKey:@"text"];
        
        frontFootDescription(footDescription);
    }
    else if ([code intValue] == 2)
    {
        error([[[toDict objectForKey:@"data"] objectForKey:@"Error"] objectForKey:@"text"]);
    }
    else
    {
        error(@"Front Foot image seems invalid");
    }
}


//////////// HAAR /////////

-(void)handleHAARResponseForSideFoot:(NSData *)responseData block:(void (^)(NSArray *ba))boundedBoxArray errorMessage:(void(^)(NSString *))error
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

-(void)handleHAARResponseForFrontFoot:(NSData *)responseData block:(void (^)(NSArray *ba))boundedBoxArray errorMessage:(void(^)(NSString *))error
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

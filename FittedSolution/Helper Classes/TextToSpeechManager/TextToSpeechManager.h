//
//  TextToSpeechManager.h
//  FittedSolution
//
//  Created by Waqar Ali on 05/07/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define text_to_speech_manager [TextToSpeechManager sharedInstance]

@interface TextToSpeechManager : NSObject <AVSpeechSynthesizerDelegate>

+(TextToSpeechManager *)sharedInstance;

-(void)setUp;
-(void)readText:(NSString*)text afterDelay:(float)delay;
-(BOOL)isSpeaking;
-(void)stopSpeaking;

@end

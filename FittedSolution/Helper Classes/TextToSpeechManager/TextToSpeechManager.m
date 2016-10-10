//
//  TextToSpeechManager.m
//  FittedSolution
//
//  Created by Waqar Ali on 05/07/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import "TextToSpeechManager.h"
#import "AppManager.h"

#define Pitch  1.0;
#define Volume 1.0;

@interface TextToSpeechManager()

@property (strong, nonatomic) AVAudioSession            * session               ;
@property (strong, nonatomic) AVSpeechSynthesizer       * speechSynthesizer     ;
@property (strong, nonatomic) AVSpeechSynthesisVoice    * synthesizeVoice       ;

@end


@implementation TextToSpeechManager

+(TextToSpeechManager *)sharedInstance
{
    static TextToSpeechManager *instance = nil;
    
    if (!instance)
    {
        instance = [TextToSpeechManager new];
    }
    return instance;
}

-(void)setUp
{
    _session = [AVAudioSession sharedInstance];
    [_session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    _speechSynthesizer = [[AVSpeechSynthesizer alloc] init]             ;
    [_speechSynthesizer setDelegate:self]                               ;
}

-(void)readText:(NSString*)text afterDelay:(float)delay
{
    AVSpeechUtterance * utterance  = [AVSpeechUtterance speechUtteranceWithString:text]     ;
    _synthesizeVoice               = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"]    ;
    utterance.voice                = _synthesizeVoice                                       ;
    utterance.pitchMultiplier      = Pitch                                                  ;
    utterance.volume               = Volume                                                 ;
    
    if ([[app_manager getDeviceiOSVersion] floatValue] >= 9.0)
    {
        utterance.rate             = AVSpeechUtteranceDefaultSpeechRate                     ;
    }
    else if ([[app_manager getDeviceiOSVersion] floatValue] >= 8.0 && [[app_manager getDeviceiOSVersion] floatValue] < 9.0)
    {
        utterance.rate             = 0.11; //0.15
    }
    else
    {
        utterance.rate             = 0.27;
    }
    
    utterance.preUtteranceDelay    = 0                                                      ;
    utterance.postUtteranceDelay   = 0                                                      ;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^
    {
        [_speechSynthesizer speakUtterance:utterance];
    });
}

- (void)stopSpeaking
{
    [_speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    //AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@""];
    //[_speechSynthesizer speakUtterance:utterance];
    //[_speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

-(BOOL)isSpeaking
{
    return [_speechSynthesizer isSpeaking];
}

#pragma mark - AVSpeechSynthesizerDelegate

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance
{
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance
{
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance;
{
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance
{
}


@end

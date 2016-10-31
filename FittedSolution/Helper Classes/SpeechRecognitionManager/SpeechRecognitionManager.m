//
//  SpeechRecognitionManager.m
//  FittedSolution
//
//  Created by Waqar Ali on 05/07/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import "SpeechRecognitionManager.h"

#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEEventsObserver.h>

@interface SpeechRecognitionManager () <OEEventsObserverDelegate>
{
    NSString * lmPath  ;
    NSString * dicPath ;
}

@property (strong, nonatomic) OEEventsObserver * openEarsEventsObserver;

@end
    
@implementation SpeechRecognitionManager

+(SpeechRecognitionManager *)sharedInstance
{
    static SpeechRecognitionManager *instance = nil;
    
    if (!instance)
    {
        instance = [SpeechRecognitionManager new];
    }
    return instance;
}

-(void)setUpSpeechRecognition
{
    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    
    NSArray  * words = [NSArray arrayWithObjects:@"capture", nil];
    NSString * name  = @"LanguageModelEnglish";
    NSError  * err   = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    // Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
    
    lmPath  = nil;
    dicPath = nil;
    
    if(err == nil)
    {
        lmPath  = [lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"LanguageModelEnglish"];
        dicPath = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"LanguageModelEnglish"];
    }
    else
    {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
}

-(void)startListeningClickVoice
{
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
    [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
    // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.

    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];
}

-(void)stopListeningClickVoice
{
    [[OEPocketsphinxController sharedInstance] setActive:FALSE error:nil];
    [[OEPocketsphinxController sharedInstance] stopListening];
}

-(BOOL)isListening
{
    return [OEPocketsphinxController sharedInstance].isListening;
}

#pragma mark - OEEventsObserverDelegate

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID
{
    if (_delegate && [_delegate respondsToSelector:@selector(pocketsphinxDidReceiveHypothesis:recognitionScore:utteranceID:)])
    {
        [_delegate pocketsphinxDidReceiveHypothesis:hypothesis recognitionScore:recognitionScore utteranceID:utteranceID];
    }
}

- (void) pocketsphinxDidStartListening
{
    NSLog(@"Started Listening...");
    
    if (_delegate && [_delegate respondsToSelector:@selector(pocketsphinxDidStartListening)])
    {
        [_delegate pocketsphinxDidStartListening];
    }
}

- (void) pocketsphinxDidDetectSpeech
{
    if (_delegate && [_delegate respondsToSelector:@selector(pocketsphinxDidDetectSpeech)])
    {
        [_delegate pocketsphinxDidDetectSpeech];
    }
}

- (void) pocketsphinxDidDetectFinishedSpeech
{
    if (_delegate && [_delegate respondsToSelector:@selector(pocketsphinxDidDetectFinishedSpeech)])
    {
        [_delegate pocketsphinxDidDetectFinishedSpeech];
    }
}

- (void) pocketsphinxDidStopListening
{
    NSLog(@"Stoped Listening...");
    
    if (_delegate && [_delegate respondsToSelector:@selector(pocketsphinxDidStopListening)])
    {
        [_delegate pocketsphinxDidStopListening];
    }
}

- (void) pocketsphinxDidSuspendRecognition
{
    if (_delegate && [_delegate respondsToSelector:@selector(pocketsphinxDidSuspendRecognition)])
    {
        [_delegate pocketsphinxDidSuspendRecognition];
    }
}

- (void) pocketsphinxDidResumeRecognition
{
    if (_delegate && [_delegate respondsToSelector:@selector(pocketsphinxDidResumeRecognition)])
    {
        [_delegate pocketsphinxDidResumeRecognition];
    }
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString
{
    if (_delegate && [_delegate respondsToSelector:@selector(pocketsphinxDidChangeLanguageModelToFile:andDictionary:)])
    {
        [_delegate pocketsphinxDidChangeLanguageModelToFile:newLanguageModelPathAsString andDictionary:newDictionaryPathAsString];
    }
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure
{
    if (_delegate && [_delegate respondsToSelector:@selector(pocketSphinxContinuousSetupDidFailWithReason:)])
    {
        [_delegate pocketSphinxContinuousSetupDidFailWithReason:reasonForFailure];
    }
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure
{
    if (_delegate && [_delegate respondsToSelector:@selector(pocketSphinxContinuousTeardownDidFailWithReason:)])
    {
        [_delegate pocketSphinxContinuousTeardownDidFailWithReason:reasonForFailure];
    }
}

- (void) testRecognitionCompleted
{
    if (_delegate && [_delegate respondsToSelector:@selector(testRecognitionCompleted)])
    {
        [_delegate testRecognitionCompleted];
    }
}


@end

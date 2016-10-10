//
//  SpeechRecognitionManager.h
//  FittedSolution
//
//  Created by Waqar Ali on 05/07/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import <Foundation/Foundation.h>

#define speech_recognition_manager [SpeechRecognitionManager sharedInstance]

@protocol SpeechRecognitionManagerDelegate <NSObject>

@required
- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID;

@optional
- (void) pocketsphinxDidStartListening;
- (void) pocketsphinxDidDetectSpeech;
- (void) pocketsphinxDidDetectFinishedSpeech;
- (void) pocketsphinxDidStopListening;
- (void) pocketsphinxDidSuspendRecognition;
- (void) pocketsphinxDidResumeRecognition;
- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString;
- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure;
- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure;
- (void) testRecognitionCompleted;

@end



@interface SpeechRecognitionManager : NSObject

@property (nonatomic, weak) id<SpeechRecognitionManagerDelegate> delegate;

+(SpeechRecognitionManager *)sharedInstance;
-(void)setUpSpeechRecognition;
-(void)startListeningClickVoice;
-(void)stopListeningClickVoice;

@end

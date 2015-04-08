//
//  SERecorder.h
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "bass.h"

@protocol SERecorderDelegate;

@interface SERecorder : NSObject

@property (nonatomic, assign) HRECORD recordChannel;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) int channelCount;
@property (nonatomic, assign) int sampleRate;
@property (nonatomic, assign) int bitDepth;
@property (nonatomic, assign) int updatePeriod;
@property (nonatomic, assign) UInt64 updatePeriodBytes;

- (instancetype) initWithDelegate:(id<SERecorderDelegate>)delegate
                      shouldStart:(BOOL)shouldstart;

- (instancetype) initWithDelegate:(id<SERecorderDelegate>)delegate
                           device:(DWORD)device
                       sampleRate:(int)sampleRate
                     channelCount:(int)channelCount
                       bufferSize:(int)bufferSize
                      shouldStart:(BOOL)start;
- (void) start;
- (void) stop;

@end

@protocol SERecorderDelegate <NSObject>

- (void) recorder:(SERecorder*)recorder didGetData:(const void*) buffer ofLength:(UInt32)length;

@optional

- (void) recorderDidChangeRecordState:(SERecorder*)recorder;

@end

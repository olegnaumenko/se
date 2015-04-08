//
//  SERecordController.m
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import "SERecordController.h"

@implementation SERecordController

- (instancetype)initWithRecodringDevice:(SERecordingDeviceInfo*)device
{
    if (self = [super init]) {
        self.device = device;
    }
    return self;
}

- (BOOL) isRunning
{
    return self.recorder.isRecording;
}

- (void) startRecording
{
    self.recorder = [[SERecorder alloc]initWithDelegate:self recordingDevice:self.device shouldStart:YES];
    UInt32 bufferSize = 2*(UInt32)self.recorder.updatePeriodBytes;
    self.tape = [[SEDataTape alloc]initWithBufferSize:bufferSize];
}

- (void) pauseRecording
{
    [self.recorder stop];
}

- (void) stopRecording
{
    [self.recorder stop];
    self.recorder = nil;
}

- (void)recorderDidChangeRecordState:(SERecorder *)recorder
{
//    NSLog(@"%@", recorder);
}

- (void)recorder:(SERecorder *)recorder didGetData:(const void *)buffer ofLength:(UInt32)length
{
//    NSLog(@"rec: %u", length);
    [self.tape putData:buffer ofLength:length];
}

@end

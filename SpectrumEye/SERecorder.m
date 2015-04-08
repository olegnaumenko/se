//
//  SERecorder.m
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import "SERecorder.h"

@interface SERecorder ()
@property (nonatomic, weak) id<SERecorderDelegate> delegate;
@end

@implementation SERecorder

BOOL __SERecorderRecordProc (HRECORD handle, const void *buffer, DWORD length, void *user)
{
//    float time = BASS_ChannelBytes2Seconds(handle, length);
    SERecorder * recorder = (__bridge SERecorder*)user;
    [recorder.delegate recorder:recorder didGetData:buffer ofLength:length];
//    NSLog(@"rec: %2.4f", time);
    return YES;
}

- (instancetype) initWithDelegate:(id<SERecorderDelegate>)delegate
                      shouldStart:(BOOL)shouldstart
{
    DWORD handle = -1;
//    BASS_RecordInit(handle);
    int channels = 2;
    int sampleRate = 88200;
    return [self initWithDelegate:delegate deviceHandle:handle sampleRate:sampleRate channelCount:channels bufferSize:0 shouldStart:shouldstart];
}

- (instancetype) initWithDelegate:(id<SERecorderDelegate>)delegate
                  recordingDevice:(SERecordingDeviceInfo*)device
                      shouldStart:(BOOL)shouldstart
{
//    BASS_RecordInit(device.bassHandle);
    int channels = 2;
    int sampleRate = 44100;
    return [self initWithDelegate:delegate deviceHandle:device.bassHandle sampleRate:sampleRate channelCount:channels bufferSize:0 shouldStart:shouldstart];
}

- (instancetype) initWithDelegate:(id<SERecorderDelegate>)delegate
                     deviceHandle:(DWORD)handle
                       sampleRate:(int)sampleRate
                     channelCount:(int)channelCount
                       bufferSize:(int)bufferSize
                      shouldStart:(BOOL)start
{
    if (self = [super init]) {
        
        self.delegate = delegate;
        self.updatePeriod = 100;
//        BASS_RecordInit(handle);
        
        BASS_RecordSetDevice(handle);
        
        BASS_RECORDINFO rinfo = {0};
        if(!BASS_RecordGetInfo(&rinfo)) NSLog(@"Could not get recordinfo, err = %d", BASS_ErrorGetCode());
        
        int chSupported = rinfo.formats>>24;
        
        if (chSupported < channelCount) {
            NSLog(@"Device has less channels than requested! dev: %d req: %d", chSupported, channelCount);
            channelCount = chSupported;
        }
        
        if (!channelCount) {
            NSLog(@"Could not use device!");
            return nil;
        }
        
        DWORD flags = BASS_SAMPLE_FLOAT;
        if (!start) {
            flags |= BASS_RECORD_PAUSE;
        }
        flags = MAKELONG(flags, (DWORD)self.updatePeriod);
        self.recordChannel = BASS_RecordStart(sampleRate, channelCount, flags, __SERecorderRecordProc, (__bridge void*)self);
        if (!self.recordChannel) {
            NSLog(@"Error creating recording channel: %d", BASS_ErrorGetCode());
            return nil;
        } else if (self.isRecording) {
            BASS_CHANNELINFO chinfo = {0};
            BASS_ChannelGetInfo(self.recordChannel, &chinfo);
            NSLog(@"Recorder STARTED: sr: %d, chCount: %d", chinfo.freq, chinfo.chans);
            [self reportStateChange];
        }
    }
    return self;
}

- (void) dealloc
{
    BASS_RecordFree(self.recordChannel);
    self.recordChannel = 0;
}

- (UInt64)updatePeriodBytes
{
    if (!self.recordChannel) {
        NSLog(@"No channel on updatePeriodBytes");
        return 0;
    }
    float time = self.updatePeriod/1000.0f;
    QWORD bytes = BASS_ChannelSeconds2Bytes(self.recordChannel, time);
    return bytes;
}

- (void) setIsRecording:(BOOL)isRecording
{
    if (isRecording) {
        [self start];
    } else {
        [self stop];
    }
}

- (BOOL) isRecording
{
    return (BASS_ChannelIsActive(self.recordChannel) == BASS_ACTIVE_PLAYING);
}

- (void) reportStateChange
{
    if ([self.delegate respondsToSelector:@selector(recorderDidChangeRecordState:)]) {
        [self.delegate recorderDidChangeRecordState:self];
    }
}

- (void) start
{
    if (self.isRecording) {
        NSLog(@"Recording already!");
        return;
    }
    if(!BASS_ChannelPlay(self.recordChannel, NO)) {
        NSLog(@"Could not start recording: %d", BASS_ErrorGetCode());
    } else {
        NSLog(@"Recorder STARTED");
        [self reportStateChange];
    }
}

- (void) stop
{
    if (!self.isRecording) {
        NSLog(@"STOP failed: not recording now!");
        return;
    }
    if(!BASS_ChannelPause(self.recordChannel)) {
        NSLog(@"Could not pause recording: %d", BASS_ErrorGetCode());
    } else {
        NSLog(@"Recorder STOPPED");
        [self reportStateChange];
    }
}

- (int) channelCount
{
    BASS_CHANNELINFO chinfo = {0};
    if(BASS_ChannelGetInfo(self.recordChannel, &chinfo))
        return chinfo.chans;
    else {
        NSLog(@"Error getting channelcount: %d", BASS_ErrorGetCode());
        return 0;
    }
}

- (int) sampleRate
{
    BASS_CHANNELINFO chinfo = {0};
    if(BASS_ChannelGetInfo(self.recordChannel, &chinfo))
        return chinfo.freq;
    else {
        NSLog(@"Error getting channelcount: %d", BASS_ErrorGetCode());
        return 0;
    }
}

- (int) bitDepth
{
    return 32;
}

@end

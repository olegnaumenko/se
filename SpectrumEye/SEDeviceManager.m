//
//  SEDeviceManager.m
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import "SEDeviceManager.h"

@interface SEDeviceManager ()
@property (nonatomic, weak) id <SEDeviceManagerDelegate> delegate;
@end

@implementation SEDeviceManager

- (instancetype)initWithDelegate:(id<SEDeviceManagerDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
        [self rescanPlaybackDevices];
        [self rescanRecordingDevices];
    }
    return  self;
}

- (void) rescanRecordingDevices
{
    NSMutableArray * recordDevices = @[].mutableCopy;
    
    int a;
    BASS_DEVICEINFO info;
    for (a=0; BASS_RecordGetDeviceInfo(a, &info); a++) {
        if ((info.flags&BASS_DEVICE_ENABLED)) {
            SERecordingDevice * device = [[SERecordingDevice alloc]initWithHandle:a delegate:self];
            if (info.name) {
                device.name = [NSString stringWithUTF8String:info.name];
            }
            if (info.driver) {
                device.driver = [NSString stringWithUTF8String:info.driver];
            }
            device.isDefault = (BOOL)info.flags&BASS_DEVICE_DEFAULT;
            [recordDevices addObject:device];
        }
    }
    self.recordDevices = recordDevices.copy;
    if (!self.currentRecordingDevice && self.recordDevices.count) {
        self.currentRecordingDevice = [self.recordDevices objectAtIndex:0];
    }
    NSLog(@"REC DEV: \n%@", self.recordDevices);
}

- (void) rescanPlaybackDevices
{
    NSMutableArray * playbackDevices = @[].mutableCopy;
    
    int a, count=0;
    BASS_DEVICEINFO info;
    for (a=1; BASS_GetDeviceInfo(a, &info); a++) {
        if (info.flags&BASS_DEVICE_ENABLED) {
            count++; // count it
            SEAudioDevice * device = [[SEPlaybackDevice alloc]initWithHandle:a delegate: self];
            if (info.name) {
                device.name = [NSString stringWithUTF8String:info.name];
            }
            if (info.driver) {
                device.driver = [NSString stringWithUTF8String:info.driver];
            }
            device.isDefault = (BOOL)info.flags&BASS_DEVICE_DEFAULT;
            [playbackDevices addObject:device];
        }
    }
    self.playbackDevices = playbackDevices.copy;
    if (!self.currentPlaybackDevice && self.playbackDevices.count) {
        self.currentPlaybackDevice = [self.playbackDevices objectAtIndex:0];
    }
    NSLog(@"PB DEV: \n%@", self.playbackDevices);
}

- (SERecordingDevice*)recordingDeviceForHandle:(DWORD)handle
{
    for (SERecordingDevice * dev in self.recordDevices) {
        if (dev.bassHandle == handle) {
            return dev;
        }
    }
    return nil;
}

- (SEPlaybackDevice*)defaultPlaybackDevice
{
    for (SEPlaybackDevice * dev in self.playbackDevices) {
        if (dev.isDefault) {
            return dev;
        }
    }
    return nil;
}

- (SERecordingDevice*)defaultRecordingDevice
{
    for (SERecordingDevice * dev in self.recordDevices) {
        if (dev.isDefault) {
            return dev;
        }
    }
    return nil;
}

- (void) audioDeviceDidChange:(SEAudioDevice*)device
{
    
}

- (void) audioDeviceDidDisconnect:(SEAudioDevice*)device
{
    
}

@end

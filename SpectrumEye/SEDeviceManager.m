//
//  SEDeviceManager.m
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SEDeviceManager.h"

@interface SEDeviceManager ()
@property (nonatomic, weak) id <SEDeviceManagerDelegate> delegate;
@end

@implementation SEDeviceManager

OSStatus __SEDeviceChangeListener(AudioObjectID                       inObjectID,
                                  UInt32                              inNumberAddresses,
                                  const AudioObjectPropertyAddress    inAddresses[],
                                  void*                               inClientData)
{
    if (inNumberAddresses) {
        SEDeviceManager * manager = (__bridge SEDeviceManager*)inClientData;
        AudioObjectPropertyAddress addr = inAddresses[0];
        
        if (addr.mSelector == kAudioHardwarePropertyDefaultOutputDevice) {
            [manager _rescanPlaybackDevices];
            if ([manager.delegate respondsToSelector:@selector(defaultPlaybackDeviceChanged:)]) {
                [manager.delegate defaultPlaybackDeviceChanged:manager];
            }
            return noErr;
        } else if (addr.mSelector == kAudioHardwarePropertyDefaultInputDevice) {
            [manager _rescanRecordingDevices];
            if ([manager.delegate respondsToSelector:@selector(defaultRecordingDeviceChanged:)]) {
                [manager.delegate defaultRecordingDeviceChanged:manager];
            }
            return noErr;
        } else if (addr.mSelector == kAudioHardwarePropertyDevices) {
            [manager rescan];
            return noErr;
        }
    }
    return -1;
}

- (instancetype)initWithDelegate:(id<SEDeviceManagerDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
        [self _rescanPlaybackDevices];
        [self _rescanRecordingDevices];
        [self _addDeviceLayoutListeners];
    }
    return  self;
}

- (void) dealloc
{
    [self _removeDeviceLayoutListeners];
}

- (void) _addDeviceLayoutListeners
{
    AudioObjectPropertyAddress propertyAddress;
    propertyAddress.mScope		= kAudioObjectPropertyScopeGlobal;
    propertyAddress.mElement	= kAudioObjectPropertyElementMaster;
    
    propertyAddress.mSelector	= kAudioHardwarePropertyDefaultOutputDevice;
    OSStatus err =  AudioObjectAddPropertyListener(kAudioObjectSystemObject, &propertyAddress, __SEDeviceChangeListener, (__bridge void*)self);
    if (err != noErr) {
        NSLog(@"Could not set Default Output Device listener!");
    }
    
    propertyAddress.mSelector	= kAudioHardwarePropertyDefaultInputDevice;
    err =  AudioObjectAddPropertyListener(kAudioObjectSystemObject, &propertyAddress, __SEDeviceChangeListener, (__bridge void*)self);
    if (err != noErr) {
        NSLog(@"Could not set Default Input Device listener!");
    }
    
    propertyAddress.mSelector   = kAudioHardwarePropertyDevices;
    err =  AudioObjectAddPropertyListener(kAudioObjectSystemObject, &propertyAddress, __SEDeviceChangeListener, (__bridge void*)self);
    
    if (err != noErr) {
        NSLog(@"Could not set Devices List listener!");
    }
}

- (void) _removeDeviceLayoutListeners
{
    AudioObjectPropertyAddress propertyAddress;
    propertyAddress.mScope		= kAudioObjectPropertyScopeGlobal;
    propertyAddress.mElement	= kAudioObjectPropertyElementMaster;
    
    propertyAddress.mSelector	= kAudioHardwarePropertyDefaultOutputDevice;
    AudioObjectRemovePropertyListener(kAudioObjectSystemObject, &propertyAddress, __SEDeviceChangeListener, (__bridge void*)self);
    
    propertyAddress.mSelector	= kAudioHardwarePropertyDefaultInputDevice;
    AudioObjectRemovePropertyListener(kAudioObjectSystemObject, &propertyAddress, __SEDeviceChangeListener, (__bridge void*)self);
    
    propertyAddress.mSelector = kAudioHardwarePropertyDevices;
    AudioObjectRemovePropertyListener(kAudioObjectSystemObject, &propertyAddress, __SEDeviceChangeListener, (__bridge void*)self);
}

- (void) _rescanRecordingDevices
{
    NSMutableArray * recordDevices = @[].mutableCopy;
    
    int a;
    BASS_DEVICEINFO info;
    for (a=0; BASS_RecordGetDeviceInfo(a, &info); a++) {
        if (info.flags&BASS_DEVICE_ENABLED) {
            SERecordingDeviceInfo * device = [[SERecordingDeviceInfo alloc]initWithHandle:a delegate:self];
            [device run];
            [device stop];
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
    
    NSArray * newDevices = recordDevices.copy;
    
    @synchronized(self) {
        BOOL isChange = self.allRecordingDeviceInfos.count != newDevices.count;
        
        self.allRecordingDeviceInfos = newDevices;
        if (!self.currentRecordingDevice && self.allRecordingDeviceInfos.count) {
            _currentRecordingDevice = [self.allRecordingDeviceInfos objectAtIndex:0];
        }
        if (isChange && [self.delegate respondsToSelector:@selector(recordingDeviceListChanged:)]) {
            [self.delegate recordingDeviceListChanged:self];
        }
    }
}

- (void) _rescanPlaybackDevices
{
    NSMutableArray * playbackDevices = @[].mutableCopy;
    
    int a, count=0;
    BASS_DEVICEINFO info;
    for (a=1; BASS_GetDeviceInfo(a, &info); a++) {
        if (info.flags&BASS_DEVICE_ENABLED) {
            count++; // count it
            SEPlaybackDeviceInfo * device = [[SEPlaybackDeviceInfo alloc]initWithHandle:a delegate: self];
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
    
    NSArray * newDevices = playbackDevices.copy;
    
    @synchronized(self) {
        BOOL isChange = self.allPlaybackDeviceInfos.count != newDevices.count;
        
        self.allPlaybackDeviceInfos = newDevices;
        if (!self.currentPlaybackDevice && self.allPlaybackDeviceInfos.count) {
            _currentPlaybackDevice = [self.allPlaybackDeviceInfos objectAtIndex:0];
        }
        if(isChange && [self.delegate respondsToSelector:@selector(playbackDeviceListChanged:)]) {
            [self.delegate playbackDeviceListChanged:self];
        }
    }
}


- (void) rescan
{
    [self _rescanPlaybackDevices];
    [self _rescanRecordingDevices];
}

- (SERecordingDeviceInfo*)recordingDeviceForHandle:(DWORD)handle
{
    for (SERecordingDeviceInfo * dev in self.allRecordingDeviceInfos) {
        if (dev.bassHandle == handle) {
            return dev;
        }
    }
    return nil;
}

- (SEPlaybackDeviceInfo*)defaultPlaybackDevice
{
    for (SEPlaybackDeviceInfo * dev in self.allPlaybackDeviceInfos) {
        if (dev.isDefault) {
            return dev;
        }
    }
    return nil;
}

- (SERecordingDeviceInfo*)defaultRecordingDevice
{
    for (SERecordingDeviceInfo * dev in self.allRecordingDeviceInfos) {
        if (dev.isDefault) {
            return dev;
        }
    }
    return nil;
}


#pragma mark - AudioDevice Delegate

- (void) audioDeviceDidChange:(SEAudioDeviceInfo*)device
{
    
}

- (void) audioDeviceDidDisconnect:(SEAudioDeviceInfo*)device
{
    
}

@end

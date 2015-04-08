//
//  SEDeviceManager.h
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SERecordingDevice.h"
#import "SEPlaybackDevice.h"
#import "bass.h"

@protocol SEDeviceManagerDelegate;

@interface SEDeviceManager : NSObject <SEAudioDeviceDelegate>

@property (nonatomic, strong) SERecordingDevice * currentRecordingDevice;
@property (nonatomic, strong) SEPlaybackDevice * currentPlaybackDevice;
@property (nonatomic, readonly) SERecordingDevice * defaultRecordingDevice;
@property (nonatomic, readonly) SEPlaybackDevice * defaultPlaybackDevice;
@property (nonatomic, strong) NSArray * recordDevices;
@property (nonatomic, strong) NSArray * playbackDevices;

- (instancetype)initWithDelegate:(id<SEDeviceManagerDelegate>)delegate;
- (void) rescanRecordingDevices;
- (void) rescanPlaybackDevices;

@end

@protocol SEDeviceManagerDelegate <NSObject>

- (void) recordingDeviceListChanged:(SEDeviceManager*)manager;
- (void) playbackDeviceListChanged:(SEDeviceManager*)manager;

@end

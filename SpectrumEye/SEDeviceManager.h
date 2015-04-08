//
//  SEDeviceManager.h
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SERecordingDeviceInfo.h"
#import "SEPlaybackDeviceInfo.h"
#import "bass.h"

@protocol SEDeviceManagerDelegate;

@interface SEDeviceManager : NSObject <SEAudioDeviceDelegate>

@property (nonatomic, readonly) SERecordingDeviceInfo * currentRecordingDevice;
@property (nonatomic, readonly) SEPlaybackDeviceInfo * currentPlaybackDevice;
@property (nonatomic, readonly) SERecordingDeviceInfo * defaultRecordingDevice;
@property (nonatomic, readonly) SEPlaybackDeviceInfo * defaultPlaybackDevice;
@property (nonatomic, strong) NSArray * allRecordingDeviceInfos;
@property (nonatomic, strong) NSArray * allPlaybackDeviceInfos;

- (instancetype)initWithDelegate:(id<SEDeviceManagerDelegate>)delegate;
- (void) rescan;

@end

@protocol SEDeviceManagerDelegate <NSObject>
@optional
- (void) recordingDeviceListChanged:(SEDeviceManager*)manager;
- (void) playbackDeviceListChanged:(SEDeviceManager*)manager;
- (void) defaultRecordingDeviceChanged:(SEDeviceManager*)manager;
- (void) defaultPlaybackDeviceChanged:(SEDeviceManager*)manager;
@end

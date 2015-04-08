//
//  SEController.m
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import "SEController.h"

@implementation SEController

- (instancetype)init
{
    if (self = [super init]) {
        self.deviceManager = [[SEDeviceManager alloc]initWithDelegate:self];
    }
    return self;
}

- (void) start
{
    self.recordController = [[SERecordController alloc]initWithRecodringDevice:self.deviceManager.currentRecordingDevice];
    [self.recordController startRecording];
}

- (void) appWillTerminate
{
    [self.recordController stopRecording];
}

#pragma mark - DeviceManager Delegate

- (void) recordingDeviceListChanged:(SEDeviceManager*)manager
{
    NSLog(@"REC DEV: \n%@", manager.allRecordingDeviceInfos);
}

- (void) playbackDeviceListChanged:(SEDeviceManager*)manager
{
    NSLog(@"PB DEV: \n%@", manager.allPlaybackDeviceInfos);
}

- (void) defaultRecordingDeviceChanged:(SEDeviceManager *)manager
{
    NSLog(@"DEFAULT REC DEVICE: %@", manager.defaultRecordingDevice);
}

- (void) defaultPlaybackDeviceChanged:(SEDeviceManager *)manager
{
    NSLog(@"DEFAULT PB DEVICE: %@", manager.defaultPlaybackDevice);
}
@end

//
//  SERecordController.h
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SERecorder.h"
#import "SEDataTape.h"
#import "SERecordingDeviceInfo.h"

@interface SERecordController : NSObject <SERecorderDelegate>
@property (nonatomic, strong) SERecordingDeviceInfo * device;
@property (nonatomic, strong) SERecorder * recorder;
@property (nonatomic, strong) SEDataTape * tape;
@property (nonatomic, readonly) BOOL isRunning;

- (instancetype)initWithRecodringDevice:(SERecordingDeviceInfo*)device;
- (void) startRecording;
- (void) stopRecording;
- (void) pauseRecording;

@end

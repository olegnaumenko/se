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

@interface SERecordController : NSObject <SERecorderDelegate>
@property (nonatomic, strong) SERecorder * recorder;
@property (nonatomic, strong) SEDataTape * tape;
@property (nonatomic, readonly) BOOL isRunning;

- (void) startRecording;
- (void) stopRecording;
- (void) pauseRecording;

@end

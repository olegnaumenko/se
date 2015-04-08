//
//  SERecordingDevice.h
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SEAudioDeviceInfo.h"

@interface SERecordingDeviceInfo : SEAudioDeviceInfo
@property (nonatomic, readonly) int inputCount;
@property (nonatomic, readonly) int sampleRate;
@property (nonatomic, readonly) NSArray * inputNames;

+ (BASS_RECORDINFO) recordInfo;

@end


//
//  SEAudioDevice.h
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "bass.h"

@protocol SEAudioDeviceDelegate;

@interface SEAudioDevice : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * driver;
@property (nonatomic, assign) BOOL isDefault;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, readonly) DWORD bassHandle;

- (instancetype) initWithHandle:(DWORD) deviceHandle delegate:(id<SEAudioDeviceDelegate>)delegate;
- (void) run;
- (void) stop;
@end

@protocol SEAudioDeviceDelegate <NSObject>

- (void) audioDeviceDidChange:(SEAudioDevice*)device;
- (void) audioDeviceDidDisconnect:(SEAudioDevice*)device;

@end
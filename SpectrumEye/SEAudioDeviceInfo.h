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

@interface SEAudioDeviceInfo : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * driver;
@property (nonatomic, readonly) NSString * typeString;
@property (nonatomic, assign) BOOL isDefault;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, readonly) DWORD bassHandle;
@property (nonatomic, readonly) DWORD bassType;

- (instancetype) initWithHandle:(DWORD) deviceHandle delegate:(id<SEAudioDeviceDelegate>)delegate;
- (void) run;
- (void) stop;
- (void) set;
@end

@protocol SEAudioDeviceDelegate <NSObject>

- (void) audioDeviceDidChange:(SEAudioDeviceInfo*)device;
- (void) audioDeviceDidDisconnect:(SEAudioDeviceInfo*)device;

@end
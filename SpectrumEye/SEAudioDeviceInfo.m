//
//  SEAudioDevice.m
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import "SEAudioDeviceInfo.h"
#import "bass.h"

@interface SEAudioDeviceInfo ()
@property (nonatomic, weak) id <SEAudioDeviceDelegate> delegate;
@end

@implementation SEAudioDeviceInfo

- (instancetype) initWithHandle:(DWORD) deviceHandle delegate:(id<SEAudioDeviceDelegate>)delegate
{
    if (self = [super init]) {
        _bassHandle = deviceHandle;
        self.delegate = delegate;
    }
    return self;
}

- (NSString*) description
{
    NSString * isDefault = (self.isDefault?@"<Default>":@"");
    NSString * isInit = (self.isRunning?@"<Init>":@"");
    return [NSString stringWithFormat:@"%d %@: %@ - %@ : %@ %@%@", self.bassHandle, super.description, self.name, self.driver, self.typeString, isDefault, isInit];
}

- (void) run{}
- (void) stop{}
- (void) set{}

- (DWORD)bassType
{
    DWORD flags = self.deviceInfo.flags;
    return flags&BASS_DEVICE_TYPE_MASK;
}

- (NSString*)typeString
{
    DWORD type = [self bassType];
    switch (type) {
        case BASS_DEVICE_TYPE_NETWORK:
            return @"Network";
            break;
        case BASS_DEVICE_TYPE_SPEAKERS:
            return @"Speakers";
            break;
        case BASS_DEVICE_TYPE_LINE:
            return @"Line";
            break;
        case BASS_DEVICE_TYPE_HEADPHONES:
            return @"Headphones";
            break;
        case BASS_DEVICE_TYPE_MICROPHONE:
            return @"Micropone";
            break;
        case BASS_DEVICE_TYPE_HEADSET:
            return @"Micropone";
            break;
        case BASS_DEVICE_TYPE_HANDSET:
            return @"Micropone";
            break;
        case BASS_DEVICE_TYPE_DIGITAL:
            return @"Digital";
            break;
        case BASS_DEVICE_TYPE_SPDIF	:
            return @"SPDIF";
            break;
        case BASS_DEVICE_TYPE_HDMI	:
            return @"HDMI";
            break;
        case BASS_DEVICE_TYPE_DISPLAYPORT:
            return @"Displayport";
            break;
            
        default:
            return @"External";
            break;
    }
    return nil;
}

- (BASS_DEVICEINFO) deviceInfo
{
    assert(0);//should be overridden!
    BASS_DEVICEINFO info = {0};
    return info;
}
@end

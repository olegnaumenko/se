//
//  SEPlaybackDevice.m
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import "SEPlaybackDevice.h"
#import "bass.h"

@implementation SEPlaybackDevice


- (BASS_DEVICEINFO) deviceInfo
{
    BASS_DEVICEINFO info = {0};
    BASS_GetDeviceInfo(self.bassHandle, &info);
    return info;
}

@end

//
//  SERecordingDevice.m
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import "SERecordingDevice.h"
#import "bass.h"

@implementation SERecordingDevice

- (void) run
{
    if (!BASS_RecordInit(self.bassHandle)) {
        DWORD err = BASS_ErrorGetCode();//should not happen, in theory...
        NSLog(@"Failed Recording device init! err: %d", err);
        if (err == BASS_ERROR_INIT) {
            if(!BASS_RecordSetDevice(self.bassHandle))
            {
                NSLog(@"Could Not set Rec Device! err: %d", BASS_ErrorGetCode());
            }
        }
    }
}

- (void) stop
{
    BASS_RecordFree();
}

- (BOOL) isRunning
{
    return ([self deviceInfo].flags&BASS_DEVICE_INIT);
}

- (BASS_DEVICEINFO) deviceInfo
{
    BASS_DEVICEINFO info = {0};
    BASS_RecordGetDeviceInfo(self.bassHandle, &info);
    return info;
}
@end

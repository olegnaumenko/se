//
//  SERecordingDevice.m
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import "SERecordingDeviceInfo.h"
#import "bass.h"

@implementation SERecordingDeviceInfo
@synthesize inputCount = _inputCount, sampleRate = _sampleRate, inputNames = _inputNames;

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
    } else {//success
        BASS_RECORDINFO rinfo = [self.class recordInfo];
        _inputCount = rinfo.formats>>24;
        _sampleRate = rinfo.freq;
    }
}

- (void) stop
{
    if(!BASS_RecordSetDevice(self.bassHandle))
    {
        NSLog(@"Could Not set Rec Device! err: %d", BASS_ErrorGetCode());
    } else {
        BASS_RecordFree();
    }
}

- (void) set
{
    if (!self.isRunning) {
        [self run];
    }
}

- (BOOL) isRunning
{
    return ([self deviceInfo].flags&BASS_DEVICE_INIT);
}

- (int) inputCount
{
    if (!_inputCount) {
        if (!self.isRunning) {
            [self run];
            [self stop];
        }
    }
    return _inputCount;
}

- (int) sampleRate
{
    if (!self.isRunning) {
        [self run];
        [self stop];
    }
    return _sampleRate;
}

- (NSArray*) inputNames
{
    if (!_inputNames) {
        @synchronized(self)
        {
            NSMutableArray * names = @[].mutableCopy;
            BOOL wasRunning = self.isRunning;
            if (!wasRunning) {
                [self run];
            }
            int n;
            const char * name;
            for (n = 0; (name = BASS_RecordGetInputName(n)); n++) {
//                float vol;
//                int s = BASS_RecordGetInput(n, &vol);
                [names addObject:[NSString stringWithUTF8String:name]];
        //        printf("%s [%s : %g]\n", name, s&BASS_INPUT_OFF?"off":"on", vol);
            }
            if (!wasRunning) {
                [self stop];
            }
            _inputNames = names.copy;
        }
    }
    return _inputNames;
}

- (BASS_DEVICEINFO) deviceInfo
{
    BASS_DEVICEINFO info = {0};
    BASS_RecordGetDeviceInfo(self.bassHandle, &info);
    return info;
}

+ (BASS_RECORDINFO) recordInfo
{
    BASS_RECORDINFO info = {0};
    BASS_RecordGetInfo(&info);
    return info;
}
@end

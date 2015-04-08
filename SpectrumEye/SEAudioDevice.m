//
//  SEAudioDevice.m
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import "SEAudioDevice.h"
#import "bass.h"

@interface SEAudioDevice ()
@property (nonatomic, weak) id <SEAudioDeviceDelegate> delegate;
@end

@implementation SEAudioDevice

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
    return [NSString stringWithFormat:@"%d %@: %@ - %@  %@%@", self.bassHandle, super.description, self.name, self.driver, isDefault, isInit];
}

- (void) run
{
    
}

- (void) stop
{
    
}

- (BASS_DEVICEINFO) deviceInfo
{
    assert(0);//should be overridden!
    BASS_DEVICEINFO info = {0};
    return info;
}
@end

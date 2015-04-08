//
//  SEController.h
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SERecordController.h"
#import "SEDeviceManager.h"

@interface SEController : NSObject <SEDeviceManagerDelegate>

@property (nonatomic, strong) SERecordController * recordController;
@property (nonatomic, strong) SEDeviceManager * deviceManager;

- (void) start;
- (void) appWillTerminate;

@end

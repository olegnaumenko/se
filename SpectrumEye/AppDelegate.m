//
//  AppDelegate.m
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.mainController = [[SEController alloc]init];
    [self.mainController start];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    [self.mainController appWillTerminate];
}

@end

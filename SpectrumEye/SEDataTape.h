//
//  SEDataTape.h
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SEDataSink.h"

@interface SEDataTape : NSObject <SEDataSinkDatasource>

@property (nonatomic, readonly) UInt32 writeOffset;
@property (nonatomic, readonly) UInt32 readOffset;
@property (nonatomic, readonly) UInt32 size;
@property (nonatomic, assign) BOOL lock;

- (instancetype) initWithBufferSize:(UInt32)bufferSize;
- (void) putData:(const void*) buffer ofLength:(UInt32)length;
- (UInt32) getData:(void*)inBuffer ofLength:(UInt32)length;
- (UInt32) copyDataOfLength:(UInt32) length toBuffer:(void*)buffer;
@end

//
//  SEDataSink.h
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SEDataSinkDatasource;

@interface SEDataSink : NSObject

@property (nonatomic, strong) id<SEDataSinkDatasource> dataSourceTape;

@end

@protocol SEDataSinkDatasource <NSObject>

- (UInt32) copyDataOfLength:(UInt32) length toBuffer:(void*)buffer;
- (UInt32) getData:(void*)inBuffer ofLength:(UInt32)length;

@end

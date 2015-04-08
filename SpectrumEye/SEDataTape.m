//
//  SEDataTape.m
//  SpectrumEye
//
//  Created by Oleg Naumenko on 4/7/15.
//  Copyright (c) 2015 Coppertino Inc. All rights reserved.
//

#import "SEDataTape.h"
#import <pthread/pthread.h>

@implementation SEDataTape
{
    UInt8 * _buffer;
    pthread_mutex_t _mutex;
}

- (instancetype) initWithBufferSize:(UInt32)bufferSize
{
    if (self = [super init]) {
        _buffer = calloc(bufferSize, 1);
        _size = bufferSize;//sizeof(_buffer);
        _readOffset = 0;
        _writeOffset = 0;
        if (pthread_mutex_init(&_mutex, NULL) != 0) {
            NSLog(@"\n mutex init failed\n");
        }
        NSLog(@"Tape Size: %u", (unsigned int)bufferSize);
    }
    return self;
}

- (void) dealloc
{
    pthread_mutex_lock(&_mutex);
    if (_buffer) {
        free(_buffer);
    }
    _buffer = NULL;
    pthread_mutex_unlock(&_mutex);
    pthread_mutex_destroy(&_mutex);
}

- (void) setLock:(BOOL)lock
{
    if (lock) {
        pthread_mutex_lock(&_mutex);
    } else {
        pthread_mutex_unlock(&_mutex);
    }
    _lock = lock;
}

- (void) putData:(const void *)buffer ofLength:(UInt32)length
{
    pthread_mutex_lock(&_mutex);
    
    if (!_buffer) {
        NSLog(@"PutData: BUFFER IS NULL!");
        return;
    }
    
    if (length > self.size) {
        
        UInt8 * newPtr = realloc(_buffer, length);
        if (newPtr) {
            NSLog(@"Resize: %u , buffer = %u", self.size, length);
            _buffer = newPtr;
            _size = length;
        } else {
            
            NSLog(@"Fail getting data, Wrong size: %u , buffer = %u", length, self.size);
            return;
        }
    }
    
    UInt32 endPos = _writeOffset + length;
    
    if (endPos > self.size) {
        
        UInt32 sizeToFree = endPos - self.size;
        UInt32 sizeToMove = self.size - sizeToFree;
        memmove(_buffer, _buffer + sizeToFree, sizeToMove);
        _writeOffset -= sizeToFree;
        while (_readOffset >= sizeToFree) {
            _readOffset -= sizeToFree;
        }
    }
    assert(_writeOffset + length <= self.size && ((int)_writeOffset) >= 0 && ((int)_readOffset) >= 0);
    
    UInt8 * startPos = _buffer + _writeOffset;
    memcpy(startPos, buffer, length);
    _writeOffset += length;
    
    pthread_mutex_unlock(&_mutex);
}

- (UInt32) getData:(void*)inBuffer ofLength:(UInt32)length
{
    inBuffer = _buffer + _readOffset;
    return (length < self.size - _readOffset ? length : 0);
}

- (UInt32) copyDataOfLength:(UInt32) length toBuffer:(void*)buffer
{
    pthread_mutex_lock(&_mutex);
    
    if (length > self.size) {
        NSLog(@"Wrong length on Copy data: %d, buffer = %d", length, self.size);
        length = self.size;
    }
    memcpy(buffer, _buffer, length);
    
    pthread_mutex_unlock(&_mutex);
    return length;
}

@end

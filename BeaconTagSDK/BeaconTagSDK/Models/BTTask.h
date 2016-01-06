/*
 * Copyright (c) 2015 Orange.
 *
 * This library is free software; you can redistribute it and/or modify it under the terms of
 * the GNU Lesser General Public License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License, which can be found in the file 'LICENSE.txt' in
 * this package distribution or at 'http://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html'
 * for more details.
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BTTaskType) {
    btTaskTypeUnknown,
    btTaskTypeCheckUUID,
    btTaskTypeWriteValue
};

typedef NS_ENUM(NSUInteger, BTTaskState) {
    btTaskStateUnknown = 0,
    btTaskStateCancelled,
    btTaskStateNotStarted,
    btTaskStateRunning,
    btTaskStateFinished,
    btTaskStateFailed
};


@interface BTTask : NSObject
@property (nonatomic, readonly) BTTaskType type;
@property (nonatomic) BTTaskState state;
// For optional tasks there are no 'failed' state, only 'finished'.
@property (nonatomic) BOOL optional;
@property (nonatomic) BOOL disconnectAfterFinishing;

// Tasks we wait to finish before starting this task.
@property (nonatomic, readonly) NSArray *dependencies;
- (void)addDependency:(BTTask *)task;

// Identify target Beacon Tag by its iBeacon UUID.
@property (nonatomic, copy) NSUUID *beaconTagUUID;
@property (nonatomic, copy) NSNumber *beaconTagMajor;
@property (nonatomic, copy) NSNumber *beaconTagMinor;
@property (nonatomic, readonly) NSString *beaconTagIdentifier;

@property (nonatomic, copy) NSString *serviceUUID;

// Characteristac UUID (NSString) -> characteristic value(NSData)
@property (nonatomic, readonly) NSMutableDictionary *characteristicValues;

@property (nonatomic) NSTimeInterval timeout;

@property (nonatomic, copy) void(^completed)(BTTask *task);
@property (nonatomic, copy) void(^failed)(NSError *error);

+ (instancetype)taskWithType:(BTTaskType)taskType;
@end

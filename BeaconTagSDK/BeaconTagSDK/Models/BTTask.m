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

#import "BTTask.h"

// Utils and constants
#import "KVCUtils.h"


@interface BTTask ()
@property (nonatomic, readwrite) BTTaskType type;
@property (nonatomic, readwrite) NSMutableDictionary *characteristicValues;
@property (nonatomic, readwrite) NSArray *dependencies;
@end


@implementation BTTask

#pragma mark - Object lifecycle

+ (instancetype)taskWithType:(BTTaskType)taskType
{
    BTTask *instance = [[BTTask alloc] init];
    instance.type = taskType;
    instance.characteristicValues = [[NSMutableDictionary alloc] init];
    instance.dependencies = @[];
    return instance;
}

#pragma mark - Public methods

- (void)addDependency:(BTTask *)task
{
    NSMutableArray *dependencies = [self mutableArrayValueForKey:STR_PROP(dependencies)];
    [dependencies addObject:task];
}

- (NSString *)beaconTagIdentifier
{
    return [NSString stringWithFormat:@"%@:%04X:%04X",
        self.beaconTagUUID.UUIDString, self.beaconTagMajor.intValue, self.beaconTagMinor.intValue];
}

@end

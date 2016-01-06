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

#import "BeaconTagConfiguration.h"


static BeaconTagTxPower const kDefaultBeaconTagTxPower = beaconTagTxPower_0;
static UInt16 const kDefaultAdvertisingInterval = 160;
static SInt8 const kDefaultTemperatureLowerBoundary = 15;
static SInt8 const kDefaultTemperatureUpperBoundary = 25;
static WorkflowConditionType const kDefaultWorkflowConditionType = workflowConditionTypeEnterRegion;
static UInt16 const kDefaultSleepDelay = 0;
static Float32 const kDefaultAccelerationThreshold = 0.980665f;


@implementation BeaconTagConfiguration

#pragma mark - Object lifecycle.

- (instancetype)init
{
    self = [super init];
    if (self) {
        _beaconTagUUID = nil;
        _beaconTagMajor = nil;
        _beaconTagMinor = nil;
        _workflowConditionType = kDefaultWorkflowConditionType;
        _txPower = kDefaultBeaconTagTxPower;
        _advertisingInterval = kDefaultAdvertisingInterval;
        _sleepDelay = kDefaultSleepDelay;
        _accelerationWakeLevel = kDefaultAccelerationThreshold;
        _temperatureLowerBoundary = kDefaultTemperatureLowerBoundary;
        _temperatureUpperBoundary = kDefaultTemperatureUpperBoundary;
    }
    return self;
}

@end

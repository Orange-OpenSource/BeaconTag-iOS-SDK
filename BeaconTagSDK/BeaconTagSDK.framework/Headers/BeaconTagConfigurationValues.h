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

typedef NS_ENUM(NSInteger, WorkflowConditionType) {
    workflowConditionTypeUnknown = 0,
    workflowConditionTypeEnterRegion,
    workflowConditionTypeLeaveRegion,
	workflowConditionTypeEnterAndLeaveRegion,
    workflowConditionTypeTouchAnObject,
    workflowConditionTypeMovement,    
    workflowConditionTypeTemperature
};


typedef NS_ENUM(NSInteger, BeaconTagMode) {
    beaconTagModeUnknown = 0,
    beaconTagModePulsar,
    beaconTagModeAccelerometer,
    beaconTagModeThermo
};
BeaconTagMode beaconTagModeForConditionType(WorkflowConditionType conditionType);


typedef NS_ENUM(NSUInteger, BeaconTagTxPower) {
    beaconTagTxPowerUnknown = 0,
    beaconTagTxPower_minus_62,
    beaconTagTxPower_minus_52,
    beaconTagTxPower_minus_48,
    beaconTagTxPower_minus_44,
    beaconTagTxPower_minus_40,
    beaconTagTxPower_minus_36,
    beaconTagTxPower_minus_32,
    beaconTagTxPower_minus_30,
    beaconTagTxPower_minus_20,
    beaconTagTxPower_minus_16,
    beaconTagTxPower_minus_12,
    beaconTagTxPower_minus_8,
    beaconTagTxPower_minus_4,
    beaconTagTxPower_0,
    beaconTagTxPower_plus_4
};
SInt8 valueForBeaconTagTxPower(BeaconTagTxPower power);


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

#import "BeaconTagConfigurationValues.h"

SInt8 valueForBeaconTagTxPower(BeaconTagTxPower power)
{
    switch (power) {
        case beaconTagTxPower_minus_62: return -62;
        case beaconTagTxPower_minus_52: return -52;
        case beaconTagTxPower_minus_48: return -48;
        case beaconTagTxPower_minus_44: return -44;
        case beaconTagTxPower_minus_40: return -40;
        case beaconTagTxPower_minus_36: return -36;
        case beaconTagTxPower_minus_32: return -32;
        case beaconTagTxPower_minus_30: return -30;
        case beaconTagTxPower_minus_20: return -20;
        case beaconTagTxPower_minus_16: return -16;
        case beaconTagTxPower_minus_12: return -12;
        case beaconTagTxPower_minus_8: return -8;
        case beaconTagTxPower_minus_4: return -4;
        case beaconTagTxPower_0: return 0;
        case beaconTagTxPower_plus_4: return 4;
        default: return 0xFF;
    }
}

BeaconTagMode beaconTagModeForConditionType(WorkflowConditionType conditionType)
{
    switch (conditionType) {
        case workflowConditionTypeEnterRegion:
        case workflowConditionTypeLeaveRegion:
		case workflowConditionTypeEnterAndLeaveRegion:
        case workflowConditionTypeTouchAnObject:
            return beaconTagModePulsar;
        
        case workflowConditionTypeTemperature:
            return beaconTagModeThermo;
        
        case workflowConditionTypeMovement:
            return beaconTagModeAccelerometer;

        default:
            return beaconTagModeUnknown;
    }
}
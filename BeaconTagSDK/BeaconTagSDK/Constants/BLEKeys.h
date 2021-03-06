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

// Standard keys.
extern NSString *const kBLEFirmwareRevisionUUIDString;

extern NSString *const kBLEBatteryLevelServiceUUIDString;
extern NSString *const kBLEBatteryLevelCharacteristicUUIDString;

// Custom Orange BeaconTags keys.
extern NSString *const kBLEBeaconUUIDUUIDString;
extern NSString *const kBLEBeaconMajorUUIDString;
extern NSString *const kBLEBeaconMinorUUIDString;

extern NSString *const kBLEBeaconBatteryThresholdUUIDString;

extern NSString *const kBLEConfigurationModeService;
extern NSString *const kBLEConfigurationTxPowerCharacteristic;
extern NSString *const kBLEConfigurationIntervalCharacteristic;

extern NSString *const kBLEWakeUpServiceUUIDString;
extern NSString *const kBLEWakeUpSleepDelayCharacteristic;
extern NSString *const kBLEWakeUpAccelerationCharacteristic;
extern NSString *const kBLEWakeUpThermometerCharacteristic;
extern NSString *const kBLEWakeUpAngularCharacteristic;

// Max number of iBeacon regions that can be monitored by system.
extern NSInteger kMaxMonitoredBeaconRegions;
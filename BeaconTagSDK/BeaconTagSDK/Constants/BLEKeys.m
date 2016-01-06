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
 
#import "BLEKeys.h"

NSString *const kBLEFirmwareRevisionUUIDString = @"2A26";

NSString *const kBLEBatteryLevelServiceUUIDString = @"180F";
NSString *const kBLEBatteryLevelCharacteristicUUIDString = @"2A19";

NSString *const kBLEBeaconUUIDUUIDString = @"59EC0A00-0B1E-4063-8B16-B00B50AA3A7E";
NSString *const kBLEBeaconMajorUUIDString = @"59EC0A02-0B1E-4063-8B16-B00B50AA3A7E";
NSString *const kBLEBeaconMinorUUIDString = @"59EC0A01-0B1E-4063-8B16-B00B50AA3A7E";

NSString *const kBLEBeaconBatteryThresholdUUIDString = @"59EC0A0A-0B1E-4063-8B16-B00B50AA3A7E";

NSString *const kBLEConfigurationModeService = @"59EC0800-0B1E-4063-8B16-B00B50AA3A7E";
NSString *const kBLEConfigurationTxPowerCharacteristic = @"59EC0A05-0B1E-4063-8B16-B00B50AA3A7E";
NSString *const kBLEConfigurationIntervalCharacteristic = @"59EC0A04-0B1E-4063-8B16-B00B50AA3A7E";

NSString *const kBLEWakeUpServiceUUIDString = @"59EC0802-0B1E-4063-8B16-B00B50AA3A7E";
NSString *const kBLEWakeUpSleepDelayCharacteristic = @"59EC0A07-0B1E-4063-8B16-B00B50AA3A7E";
NSString *const kBLEWakeUpAccelerationCharacteristic = @"59EC0A0B-0B1E-4063-8B16-B00B50AA3A7E";
NSString *const kBLEWakeUpThermometerCharacteristic = @"59EC0A08-0B1E-4063-8B16-B00B50AA3A7E";
NSString *const kBLEWakeUpAngularCharacteristic = @"59EC0A09-0B1E-4063-8B16-B00B50AA3A7E";

NSInteger kMaxMonitoredBeaconRegions = 20;
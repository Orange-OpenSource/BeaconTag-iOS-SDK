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
#import <BeaconTagSDK/BeaconTagConfiguration.h>
#import <BeaconTagSDK/BeaconTagConfigurationValues.h>

/**
 *
 * For proper functioning of this library you must follow the next rules:
 *
 * 1. In the host app target build settings turn on linking with
 *    CoreLocation and CoreBluetooth frameworks.
 *
 * 2. In the host app target build settings add custom linker flag "-ObjC".
 *
 * 3. In the host app target Info.plist file add appropriate value for the
 *    NSLocationAlwaysUsageDescription key.
 *
 */


/**
 * Library version.
 *
 * Don't edit this string manualy. Value is copied automatically
 * from latest Git tag message on each build.
 */
#define BEACON_TAG_SDK_VERSION @"1.1.1"


@class BeaconTagSDK;


@protocol BeaconTagDelegate <NSObject>
- (void)beaconTag:(BeaconTagSDK *)beaconTag
triggeredActionForConfiguration:(BeaconTagConfiguration *)configuration bIsInside:(BOOL) bIsInside;
@optional
- (void)beaconTag:(BeaconTagSDK *)beaconTag
didWriteConfiguration:(BeaconTagConfiguration *)configuration;
@end


@interface BeaconTagSDK : NSObject
@property (nonatomic, weak) id<BeaconTagDelegate> delegate;

/**
 * Beacon Tag configurations.
 * This values will be written during pairing with specified Beacon Tag.
 * You are expected to set all the values before starting the library.
 */
@property (nonatomic, copy) NSArray *configurations;

/**
 * Default instance of BeaconTag library, that is always available.
 * You are still welcome to create an instance manually.
 */
+ (instancetype)sharedInstance;

/**
 * This methods enable / disable iBeacons monitoring.
 * To receive alerts library instance must be started.
 */
- (void)start;
- (void)stop;
@end

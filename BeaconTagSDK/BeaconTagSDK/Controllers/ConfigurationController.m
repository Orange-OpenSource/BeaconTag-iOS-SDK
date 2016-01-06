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

#import "ConfigurationController.h"
#import "BTTaskManager.h"
#import "BTTask.h"
#import "BLEKeys.h"
#import "BeaconTagConfiguration.h"
#import "BeaconTagConfiguration+Private.h"
#import "BeaconTagConfigurationValues.h"
#import "KVCUtils.h"
#import "LoggingRoutines.h"

#import <CoreBluetooth/CoreBluetooth.h>


@interface ConfigurationController () <CBCentralManagerDelegate>
@property (nonatomic) CBCentralManager *btManager;
@property (nonatomic) BTTaskManager *taskManager;
@property (nonatomic) BOOL started;
@end


@implementation ConfigurationController

#pragma mark - Object lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _taskManager = [[BTTaskManager alloc] init];
        _started = NO;
    }
    return self;
}


#pragma mark - Public methods

- (void)start
{
    self.started = YES;
    [self forceBTStatusCheck];
}

- (void)stop
{
    self.started = NO;
    [self.taskManager cancelAllTasks];
}

- (void)forceBTStatusCheck
{
    self.btManager.delegate = nil;
    self.btManager = nil;
    
    self.btManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()
        options:@{
            CBCentralManagerOptionShowPowerAlertKey:@YES
        }];
}

#pragma mark - Accessors

- (BOOL)btPoweredOn
{
    return self.btManager.state == CBCentralManagerStatePoweredOn;
}

#pragma mark - Private methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self willChangeValueForKey:STR_PROP(btPoweredOn)];
    [self didChangeValueForKey:STR_PROP(btPoweredOn)];

    NSDictionary *stateNames = @{
        @(CBCentralManagerStateUnknown): @"CBCentralManagerStateUnknown",
        @(CBCentralManagerStateResetting): @"CBCentralManagerStateResetting",
        @(CBCentralManagerStateUnsupported): @"CBCentralManagerStateUnsupported",
        @(CBCentralManagerStateUnauthorized): @"CBCentralManagerStateUnauthorized",
        @(CBCentralManagerStatePoweredOff): @"CBCentralManagerStatePoweredOff",
        @(CBCentralManagerStatePoweredOn): @"CBCentralManagerStatePoweredOn"
    };

    DDLogInfo(@"BT state is now %@.", stateNames[@(central.state)]);
    
    // Start scanning if we were waiting for BT manager to power on.
    if (self.btManager.state == CBCentralManagerStatePoweredOn && self.started) {
        [self scheduleConfigTasks];
    }
}

- (void)scheduleConfigTasks
{
    [self.taskManager cancelAllTasks];

    NSArray *configurations = [self.dataSource configurationsForController:self];

    typeof(self) __weak wself= self;
    
    for (BeaconTagConfiguration *configuration in configurations) {
        [self uploadConfiguration:configuration withCompletion:^(NSError *error) {
            typeof(wself) __strong sself = wself;
            [sself.delegate configurationController:sself finishedConfiguration:configuration
                successfully:error == nil];
        }];
    }
}

- (NSDictionary *)dataForBeaconTagWakeUpConfiguration:(BeaconTagConfiguration *)configuration
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];

    // Accelerometer configuration.
    Byte accelerationEnabled = configuration.mode == beaconTagModeAccelerometer;
    Float32 acceleration = configuration.accelerationWakeLevel;
    NSMutableData *accelerationData = [[NSMutableData alloc] initWithCapacity:5];
    [accelerationData appendBytes:&accelerationEnabled length:sizeof(Byte)];
    [accelerationData appendBytes:&acceleration length:sizeof(Float32)];
    data[kBLEWakeUpAccelerationCharacteristic] = accelerationData;

    // Thermometer configuration.
    Byte thermometerEnabled = configuration.mode == beaconTagModeThermo;
    SInt8 lowerBoundary = configuration.temperatureLowerBoundary;
    SInt8 upperBoundary = configuration.temperatureUpperBoundary;
    NSMutableData *thermometerData = [[NSMutableData alloc] initWithCapacity:3];
    [thermometerData appendBytes:&thermometerEnabled length:sizeof(Byte)];
    [thermometerData appendBytes:&lowerBoundary length:sizeof(SInt8)];
    [thermometerData appendBytes:&upperBoundary length:sizeof(SInt8)];
    data[kBLEWakeUpThermometerCharacteristic] = thermometerData;

    // Angular speed configuration.
    Byte angularEnabled = NO;
    Float32 angularThreshold = 0;
    NSMutableData *angularData = [[NSMutableData alloc] initWithCapacity:5];
    [angularData appendBytes:&angularEnabled length:sizeof(Byte)];
    [angularData appendBytes:&angularThreshold length:sizeof(Float32)];
    data[kBLEWakeUpAngularCharacteristic] = angularData;

    // Sleep delay configuration.
    UInt16 sleepDelay = configuration.sleepDelay;
    NSMutableData *sleepDelayData = [[NSMutableData alloc] initWithCapacity:2];
    [sleepDelayData appendBytes:&sleepDelay length:sizeof(UInt16)];
    data[kBLEWakeUpSleepDelayCharacteristic] = sleepDelayData;

    return data;
}

- (NSDictionary *)dataForBeaconTagGeneralConnfiguration:(BeaconTagConfiguration *)configuration
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    
    // Advertising interval configuration.
    UInt16 advertisingInterval = configuration.advertisingInterval;
    NSMutableData *intervalData = [[NSMutableData alloc] initWithCapacity:2];
    [intervalData appendBytes:&advertisingInterval length:sizeof(UInt16)];
    data[kBLEConfigurationIntervalCharacteristic] = intervalData;
    
    // TxPower configuration.
    signed char txPowerValue = valueForBeaconTagTxPower(configuration.txPower);
    NSMutableData *txPowerData = [[NSMutableData alloc] initWithCapacity:1];
    [txPowerData appendBytes:&txPowerValue length:1];
    data[kBLEConfigurationTxPowerCharacteristic] = txPowerData;
    
    return data;
}

- (void)uploadConfiguration:(BeaconTagConfiguration *)configuration
    withCompletion:(void (^)(NSError *))completion
{
    typeof(self) __weak wself = self;

    BTTask *wakeUpConfigTask = [BTTask taskWithType:btTaskTypeWriteValue];
    wakeUpConfigTask.serviceUUID = kBLEWakeUpServiceUUIDString;
    wakeUpConfigTask.optional = YES;
    wakeUpConfigTask.disconnectAfterFinishing = YES;
    [wakeUpConfigTask.characteristicValues addEntriesFromDictionary:
        [self dataForBeaconTagWakeUpConfiguration:configuration]];
    wakeUpConfigTask.completed = ^(BTTask *task) {
            DDLogInfo(@"Completed task (write wakeup config).");
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil);
                    });
            }

			/*	Arret des taches de configuration : deconnexion du beacon
			[wself.taskManager cancelAllTasks];

			//	relance l'ecoute apres 35 Sec
			typeof(wself) __strong sself = wself;
			NSTimer *timer = [NSTimer timerWithTimeInterval:35.
														 target:sself selector:@selector(scheduleConfigTasks) userInfo:nil repeats:NO];
			[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
			 */
        };
    wakeUpConfigTask.failed = ^(NSError *error) {
            DDLogError(@"Error while configuring Beacon Tag: %@.", error);
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                        completion(error);
                    });
            }
        
            typeof(wself) __strong sself = wself;
            [sself scheduleConfigTasks];
        };
    
    BTTask *generalConfigTask = [BTTask taskWithType:btTaskTypeWriteValue];
    generalConfigTask.serviceUUID = kBLEConfigurationModeService;
    [generalConfigTask.characteristicValues addEntriesFromDictionary:
        [self dataForBeaconTagGeneralConnfiguration:configuration]];
    generalConfigTask.completed = ^(BTTask *task) {
            DDLogInfo(@"Completed task (write general config).");
            task.state = btTaskStateFinished;
        };
    generalConfigTask.failed = ^(NSError *error) {
            DDLogError(@"Error while configuring Beacon Tag: %@.", error);
        
            wakeUpConfigTask.state = btTaskStateCancelled;
        
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                        completion(error);
                    });
            }
        
            typeof(wself) __strong sself = wself;
            [sself scheduleConfigTasks];
        };

    BTTask *checkBeaconTagUUIDTask = [BTTask taskWithType:btTaskTypeCheckUUID];
    checkBeaconTagUUIDTask.serviceUUID = kBLEConfigurationModeService;
    checkBeaconTagUUIDTask.beaconTagUUID = configuration.beaconTagUUID;
    checkBeaconTagUUIDTask.beaconTagMajor = configuration.beaconTagMajor;
    checkBeaconTagUUIDTask.beaconTagMinor = configuration.beaconTagMinor;
    checkBeaconTagUUIDTask.characteristicValues[kBLEBeaconUUIDUUIDString] = [NSNull null];
    checkBeaconTagUUIDTask.characteristicValues[kBLEBeaconMajorUUIDString] = [NSNull null];
    checkBeaconTagUUIDTask.characteristicValues[kBLEBeaconMinorUUIDString] = [NSNull null];
    checkBeaconTagUUIDTask.optional = NO;
    checkBeaconTagUUIDTask.completed = ^(BTTask *task) {
            DDLogInfo(@"Completed task (check BeaconTag UUID).");
            task.state = btTaskStateFinished;
        };
    checkBeaconTagUUIDTask.failed = ^(NSError *error) {
            generalConfigTask.state = btTaskStateCancelled;
            wakeUpConfigTask.state = btTaskStateCancelled;
            DDLogError(@"Error while checking Beacon Tag UUID: %@.", error);
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                        completion(error);
                    });
            }
        
            typeof(wself) __strong sself = wself;
            [sself scheduleConfigTasks];
        };

    [generalConfigTask addDependency:checkBeaconTagUUIDTask];
    [wakeUpConfigTask addDependency:generalConfigTask];
    
    [self.taskManager enqueueTask:wakeUpConfigTask];
    [self.taskManager enqueueTask:generalConfigTask];
    [self.taskManager enqueueTask:checkBeaconTagUUIDTask];
    [self.taskManager start];
}


@end

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

#import "BTTaskManager.h"

// Models
#import "BTTask.h"

// Utils and constants
#import "LoggingRoutines.h"
#import "BLEKeys.h"
#import "KVCUtils.h"
#import "CBUUID+String.h"
#import "BeaconTagErrors.h"

// Libraries
#import <CoreBluetooth/CoreBluetooth.h>


static NSTimeInterval const optionalTaskTimeout = 4;


@interface BTTaskManager () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic) NSMutableArray *tasks;
@property (atomic) dispatch_queue_t tasksQueue;
@property (atomic) BTTask *currentTask;
@property (nonatomic) NSTimer *optionalTaskTimer;
@property (nonatomic) CBCentralManager *btManager;
@property (nonatomic) CBPeripheral *connectingPeripheral;
@property (nonatomic) NSMutableSet *connectedPeripherals;
@property (nonatomic) NSMutableSet *disconnectedPeripherals; // UUID strings of peripherals that should not be reconnected.
@property (nonatomic) NSMutableDictionary *checkUUIDTasks; // UUID:Major:Minor -> checkUUIDTask
@property (nonatomic) NSMutableDictionary *peripheralUUIDs; // peripheral.identifier -> {UUID/M/m}
@end


@implementation BTTaskManager

#pragma mark - Object lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tasks = [[NSMutableArray alloc] init];
        _checkUUIDTasks = [[NSMutableDictionary alloc] init];
        _peripheralUUIDs = [[NSMutableDictionary alloc] init];
        _tasksQueue = dispatch_queue_create("TasksQueue", DISPATCH_QUEUE_SERIAL);
        _connectedPeripherals = [[NSMutableSet alloc] init];
        _disconnectedPeripherals = [[NSMutableSet alloc] init];
        _btManager = [[CBCentralManager alloc] initWithDelegate:self queue:_tasksQueue options:@{
                CBCentralManagerOptionShowPowerAlertKey:@NO
            }];
    }
    return self;
}

#pragma mark - Public methods

- (void)enqueueTask:(BTTask *)newTask
{
    newTask.state = btTaskStateNotStarted;
    
    dispatch_async(self.tasksQueue, ^{
            [self.tasks addObject:newTask];
        });
}

- (void)cancelAllTasks
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.optionalTaskTimer invalidate];
        self.optionalTaskTimer = nil;
    });
    
    [self.btManager stopScan];

    for (CBPeripheral *peripheral in self.connectedPeripherals) {
        [self.btManager cancelPeripheralConnection:peripheral];
    }
    [self.connectedPeripherals removeAllObjects];
    
    [self.disconnectedPeripherals removeAllObjects];

    self.currentTask = nil;
    dispatch_async(self.tasksQueue, ^{
            [self.tasks removeAllObjects];
        });    
}

#pragma mark - Private methods

- (void)start
{
    if (self.btManager.state != CBCentralManagerStatePoweredOn) {
        return;
    }

    if (self.currentTask) {
        DDLogVerbose(@"BT tasks queue is already started.");
        return;
    }
    
    dispatch_async(self.tasksQueue, ^{
        NSMutableArray *tasksToRemove = [[NSMutableArray alloc] init];
        for (BTTask *task in self.tasks) {
            // Skip finished and cancelled tasks.
            if (task.state != btTaskStateNotStarted) {
                if (task.state == btTaskStateCancelled ||
                    task.state == btTaskStateFailed ||
                    task.state == btTaskStateFinished) {
                
                    [tasksToRemove addObject:task];
                }
            
                continue;
            }
            
            // Wait for dependencies.
            BOOL waitingForDependencies = NO;
            for (BTTask *dependency in task.dependencies) {
                if (dependency.state != btTaskStateFinished) {
                    waitingForDependencies = YES;
                    break;
                }
            }
            
            if (task.type == btTaskTypeCheckUUID) {
                self.checkUUIDTasks[task.beaconTagIdentifier] = task;
                task.state = btTaskStateRunning;
                continue;
            }
            
            // Start task if it is ready.
            if (!waitingForDependencies && !self.currentTask) {
                [self executeTask:task];
            }
        }
        
        [self.tasks removeObjectsInArray:tasksToRemove];

        [self startSearch];
    });
}

- (void)forceRetry
{
    if (self.currentTask) {
        [self executeTask:self.currentTask];
    }
    else {
        [self start];
    }
}

- (void)startSearch
{
    if (self.btManager.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    for (BTTask *task in self.checkUUIDTasks.allValues) {
        [self scanPeripheralsForTask:task];
    }
}

- (void)executeTask:(BTTask *)task
{
    if (self.btManager.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    self.currentTask = task;
    
    [self scanPeripheralsForTask:self.currentTask];
    
    // Allow skipping optional services tasks.
    if (self.currentTask.optional) {
        DDLogDebug(@"Starting optional task.");
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.optionalTaskTimer invalidate];
            
            self.optionalTaskTimer = [NSTimer timerWithTimeInterval:optionalTaskTimeout
                target:self selector:@selector(optionalTaskTimeout:) userInfo:self.currentTask repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:self.optionalTaskTimer forMode:NSRunLoopCommonModes];
        });
    }
}

- (void)scanPeripheralsForTask:(BTTask *)task
{
    // Scan devices with needed service.
    NSArray *servicesUUIDs;
    if (task.serviceUUID.length > 0) {
        servicesUUIDs = @[[CBUUID UUIDWithString:task.serviceUUID]];
    }
    // Scan all visible devices.
    else {
        servicesUUIDs = nil;
    }

    NSArray *alreadyConnected = [self.btManager retrieveConnectedPeripheralsWithServices:
        servicesUUIDs];

    // We may need to reconnect (if peripheral is connected by another app).
    for (CBPeripheral *peripheral in alreadyConnected) {
        if (![self.connectedPeripherals containsObject:peripheral]) {
            [self.btManager connectPeripheral:peripheral options:nil];
        }
    }
    
    // Look for the service in connected peripherals.
    if (servicesUUIDs) {
        for (CBPeripheral *peripheral in self.connectedPeripherals) {
            // TODO: we can reuse peripheral.services for already discovered services.
            [peripheral discoverServices:servicesUUIDs];
        }
    }
    
    [self.btManager scanForPeripheralsWithServices:servicesUUIDs options:nil];
}

- (void)optionalTaskTimeout:(NSTimer *)timer
{
    self.optionalTaskTimer = nil;

    BTTask *task = timer.userInfo;

    DDLogWarn(@"Optional task timeout for service with UUID: %@.", task.serviceUUID);
    
    task.state = btTaskStateFinished;
    if (task.completed) {
        task.completed(task);
    }
    
    if (self.currentTask == task) {
        self.currentTask = nil;
    }

    [self start];
}

- (BOOL)checkDeviceUUID
{
    NSData *uuidData = self.currentTask.characteristicValues[kBLEBeaconUUIDUUIDString];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDBytes:uuidData.bytes];
    if (self.currentTask.beaconTagUUID && ![self.currentTask.beaconTagUUID isEqual:uuid]) {
        return NO;
    }
    
    NSData *majorData = self.currentTask.characteristicValues[kBLEBeaconMajorUUIDString];
    UInt16 major = *((UInt16 *)majorData.bytes);
    if (self.currentTask.beaconTagMajor && self.currentTask.beaconTagMajor.intValue != major) {
        return NO;
    }

    NSData *minorData = self.currentTask.characteristicValues[kBLEBeaconMinorUUIDString];
    UInt16 minor = *((UInt16 *)minorData.bytes);
    if (self.currentTask.beaconTagMinor && self.currentTask.beaconTagMinor.intValue != minor) {
        return NO;
    }
    
    return YES;
}

NSString *identifierStringFromData(NSDictionary *dataValues)
{
    NSData *uuidData = dataValues[kBLEBeaconUUIDUUIDString];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDBytes:uuidData.bytes];
    
    NSData *majorData = dataValues[kBLEBeaconMajorUUIDString];
    UInt16 major = *((UInt16 *)majorData.bytes);

    NSData *minorData = dataValues[kBLEBeaconMinorUUIDString];
    UInt16 minor = *((UInt16 *)minorData.bytes);
    
    return [NSString stringWithFormat:@"%@:%04X:%04X", uuid.UUIDString, major, minor];
}

#pragma mark - BT centrtal manager callbacks

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // Restart scanning if we were waiting for BT manager to power on.
    if (self.btManager.state == CBCentralManagerStatePoweredOn) {
        if (self.currentTask) {
            [self forceRetry];
        }
        else {
            [self start];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
    advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSNumber *connectableValue = advertisementData[CBAdvertisementDataIsConnectable];
    if (connectableValue && !connectableValue.boolValue) {
        DDLogVerbose(@"Discovered peripheral which is not connectable: %@.", peripheral);
    }

    // Already connecting - skip.
    if (peripheral.state == CBPeripheralStateConnecting) {
        return;
    }
    
    // Connected earlier - discover services.
    else if (peripheral.state == CBPeripheralStateConnected) {
        return;
    }
    
    else if ([self.disconnectedPeripherals containsObject:peripheral.identifier.UUIDString]) {
        DDLogDebug(@"Skipping reconnection to peripheral %@.", peripheral.identifier.UUIDString);
        return;
    }

    // Ready to connect.
    self.connectingPeripheral = peripheral;

    DDLogDebug(@"Connecting peripheral %@.", peripheral);
    peripheral.delegate = self;
    [central connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    DDLogDebug(@"Connected peripheral %@.", peripheral.identifier.UUIDString);
    
    if ([self.disconnectedPeripherals containsObject:peripheral.identifier.UUIDString]) {
        DDLogDebug(@"Skip reconnecting to peripheral %@...", peripheral.identifier.UUIDString);
        [central cancelPeripheralConnection:peripheral];
    }

    [self.connectedPeripherals addObject:peripheral];

    if (self.currentTask) {
        if (self.currentTask.serviceUUID.length > 0) {
            [peripheral discoverServices:@[[CBUUID UUIDWithString:self.currentTask.serviceUUID]]];
        }
        else {
            [peripheral discoverServices:nil];
        }
    }
    else if (self.checkUUIDTasks.count > 0) {
        [peripheral discoverServices:@[[CBUUID UUIDWithString:kBLEConfigurationModeService]]];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral
    error:(NSError *)error
{
    DDLogError(@"Error while trying to connect peripheral %@: %@", peripheral.identifier.UUIDString,
        error);
    self.connectingPeripheral = nil;
    self.currentTask.state = btTaskStateFailed;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        DDLogError(@"Error while discovering services for periperal '%@': %@",
            peripheral.identifier.UUIDString, error);
        return;
    }
    
    DDLogVerbose(@"Peripheral '%@' discovered services: %@", peripheral.identifier.UUIDString,
        [peripheral.services valueForKey:STR_PROP(UUID)]);
    
    // Discover only needed characteristics by UUIDs.
    if (self.currentTask.characteristicValues.count > 0) {
        NSMutableArray *characteristics = [[NSMutableArray alloc] initWithCapacity:
            self.currentTask.characteristicValues.count];
        for (NSString *characteristicUUID in self.currentTask.characteristicValues.allKeys) {
            [characteristics addObject:[CBUUID UUIDWithString:characteristicUUID]];
        }
        for (CBService *service in peripheral.services) {
            // Check if characteristic is from current service.
            NSString *neededService = self.currentTask.serviceUUID;
            if (neededService.length > 0 && ![service.UUID.stringValue isEqualToString:neededService]) {
                continue;
            }
            [peripheral discoverCharacteristics:characteristics forService:service];
        }
    }
    
    // Discover all characteristics.
    else {
        for (CBService *service in peripheral.services) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
    didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        DDLogError(@"Error while discovering characteristics for service %@: %@", service.UUID,
            error);
        self.currentTask.state = btTaskStateFailed;
        // [self failCurrentTaskWithError:error];
        return;
    }

    DDLogVerbose(@"Peripheral '%@' discovered characteristics for service '%@': %@.",
        peripheral.identifier.UUIDString, service.UUID,
        [service.characteristics valueForKey:STR_PROP(UUID)]);

    // Write data for current task.
    if (self.currentTask) {
        [self writeCharacteristicsForService:service fromPeripheral:peripheral];
    }
    
    // Check UUID/Major/Minor.
    else {
        BTTask *checkUUIDTask = self.checkUUIDTasks.allValues.firstObject;
        for (CBCharacteristic *characteristic in service.characteristics) {
            NSString *characteristicUUID = characteristic.UUID.stringValue;
            if (checkUUIDTask && checkUUIDTask.characteristicValues[characteristicUUID]) {
                [peripheral readValueForCharacteristic:characteristic];
            }
        }
    }
}

- (void)writeCharacteristicsForService:(CBService *)service fromPeripheral:(CBPeripheral *)peripheral
{
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSString *characteristicUUID = characteristic.UUID.stringValue;
        NSData *value = self.currentTask.characteristicValues[characteristicUUID];
        if (value) {
            DDLogDebug(@"Writing value %@ for characteristic %@.", value,
                [characteristic.UUID stringValue]);
            
            [peripheral writeValue:value forCharacteristic:characteristic
                type:CBCharacteristicWriteWithResponse];
            
            [self.currentTask.characteristicValues removeObjectForKey:characteristicUUID];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:
    (CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        DDLogError(@"Error while reading value for characteristic '%@' on service '%@': %@",
            characteristic.UUID, characteristic.service.UUID, error);
        return;
    }

    if (!self.currentTask && !self.checkUUIDTasks.count) {
        DDLogWarn(@"Got value for characteristic while there are no active tasks.");
        [self start];
        return;
    }

    DDLogDebug(@"Characteristic %@ value: %@.", characteristic.UUID.stringValue, characteristic.value);
    
    if (!self.currentTask) {
        NSMutableDictionary *readValues = self.peripheralUUIDs[peripheral.identifier.UUIDString];
        if (!readValues) {
            readValues = [[NSMutableDictionary alloc] init];
        }
        readValues[characteristic.UUID.stringValue] = characteristic.value;
        self.peripheralUUIDs[peripheral.identifier.UUIDString] = readValues;
        
        // All values (UUID/M/m) were read for current peripheral.
        if (readValues.count == 3) {
            DDLogDebug(@"Checking BeaconTag UUID...");
            NSString *identifierString = identifierStringFromData(readValues);
            BTTask *checkUUIDTask = self.checkUUIDTasks[identifierString];
            if (checkUUIDTask) {
                DDLogInfo(@"BeaconTag matched (%@)", identifierString);
                [checkUUIDTask.characteristicValues addEntriesFromDictionary:readValues];
                checkUUIDTask.state = btTaskStateFinished;
                if (checkUUIDTask.completed) {
                    checkUUIDTask.completed(self.currentTask);
                }
                [self.checkUUIDTasks removeObjectForKey:identifierString];
            }
            else {
                DDLogInfo(@"We are not interested in BeaconTag %@...", identifierString);
                [self.peripheralUUIDs removeObjectForKey:peripheral.identifier.UUIDString];
                
                DDLogDebug(@"From now will ignore peripheral %@.", peripheral.identifier.UUIDString);
                [self.disconnectedPeripherals addObject:peripheral.identifier.UUIDString];

                [self.btManager cancelPeripheralConnection:peripheral];
                return;
            }
        }
        else {
            return;
        }
    }

    // Execute next task.
    [self start];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:
    (CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        DDLogError(@"Error while writing value for characteristic %@: %@.", characteristic, error);
        self.currentTask.state = btTaskStateFailed;
        if (self.currentTask.failed) {
            self.currentTask.failed(error);
        }
        self.currentTask = nil;
        [self start];
        return;
    }
    
    DDLogDebug(@"Did write value for characteristic %@.", characteristic.UUID.stringValue);
    [self.currentTask.characteristicValues removeObjectForKey:characteristic.UUID.stringValue];
    
    // All fields written.
    if (self.currentTask.characteristicValues.count == 0) {
        self.currentTask.state = btTaskStateFinished;
        
        if (self.currentTask.disconnectAfterFinishing) {
            for (CBPeripheral *peripheral in self.connectedPeripherals) {
                [self.btManager cancelPeripheralConnection:peripheral];

                DDLogDebug(@"From now will ignore peripheral %@.", peripheral.identifier.UUIDString);
                [self.disconnectedPeripherals addObject:peripheral.identifier.UUIDString];
            }
        }
        
        if (self.currentTask.completed) {
            self.currentTask.completed(self.currentTask);
        }
        
        if (self.currentTask.optional) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.optionalTaskTimer invalidate];
                self.optionalTaskTimer = nil;
            });
        }
        
        self.currentTask = nil;
        
        [self start];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral
    error:(NSError *)error
{
    self.connectingPeripheral = nil;

    if (error) {
        DDLogDebug(@"Error while disconnecting peripheral %@: %@.",
            peripheral.identifier.UUIDString, error);
        if (!self.currentTask) {
            [self start];
        }
    }
    else {
        DDLogDebug(@"Disconnected peripheral %@.", peripheral.identifier.UUIDString);
    }

    [self.connectedPeripherals removeObject:peripheral];
    [self start];
}

@end

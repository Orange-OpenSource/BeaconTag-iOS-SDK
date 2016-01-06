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

#import "TriggeringController.h"

// Utils
#import "LoggingRoutines.h"

// Models
#import "BeaconTag.h"
#import "BeaconTagConfiguration.h"

// Libraries
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>


static NSTimeInterval kAutoLeaveInterval = 30.0;
static NSTimeInterval kMoveAwayInterval = 5.0;


@interface TriggeringController () <CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSTimer *autoleaveTimer;
@property (nonatomic) BOOL shouldUpdateAfterAuthorization;

// Array of iBeacon identifiers (UUID:MAJOR:MINOR strings).
@property (nonatomic) NSMutableArray *insideBeacons;

// iBeacon identifier (UUID:MAJOR:MINOR string) -> Service.
@property (nonatomic) NSMutableDictionary *lastSeenBeacons;

@property (nonatomic) NSMutableArray *regions;
@property (nonatomic) NSMutableDictionary *configurationsById;
@end


@implementation TriggeringController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shouldUpdateAfterAuthorization = NO;
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
            [self.locationManager requestAlwaysAuthorization];
        }
        
        _insideBeacons = [[NSMutableArray alloc] init];
        _lastSeenBeacons = [[NSMutableDictionary alloc] init];
        _regions = [[NSMutableArray alloc] init];
        _configurationsById = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:
            @selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification
            object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:
            @selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification
            object:nil];

    }
    return self;
}

#pragma mark - Public methods

- (void)start
{
    [self refreshMonitoredRegions];
}

- (void)stop
{
    NSSet *regions = self.locationManager.monitoredRegions;
    for (CLBeaconRegion *region in regions) {
        [self.locationManager stopMonitoringForRegion:region];
    }
}

#pragma mark - Accessors

- (void)setConfigurations:(NSArray *)configurations
{
    _configurations = [configurations copy];
    
    NSMutableArray *regions = [[NSMutableArray alloc] init];
    NSMutableDictionary *configurationsById = [[NSMutableDictionary alloc] init];
    for (BeaconTagConfiguration *configuration in self.configurations) {
        NSString *regionId = [NSString stringWithFormat:@"%@:%04X:%04X",
            configuration.beaconTagUUID.UUIDString, configuration.beaconTagMajor.intValue,
            configuration.beaconTagMinor.intValue];
    
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:
            configuration.beaconTagUUID major:configuration.beaconTagMajor.intValue
            minor:configuration.beaconTagMinor.intValue identifier:regionId];
        
        [regions addObject:region];
        configurationsById[regionId] = configuration;
    }
    self.regions = regions;
    self.configurationsById = configurationsById;

}

#pragma mark - Private methods

- (WorkflowConditionType)conditionTypeForRegion:(CLBeaconRegion *)region
{
    BeaconTagConfiguration *configuration = self.configurationsById[region.identifier];
    return configuration.workflowConditionType;
}

- (void)locationManager:(CLLocationManager *)manager
    didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self.delegate triggeringController:self changedAuthenticationStatus:
        status == kCLAuthorizationStatusAuthorizedAlways];

    // Force location services authorization request.
    if (status == kCLAuthorizationStatusNotDetermined) {
        // iOS 8.
        if ([manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [manager requestAlwaysAuthorization];
        }
        // iOS 7.
        else {
            [manager startUpdatingLocation];
            [manager stopUpdatingLocation];
        }
    }
    
    if (status == kCLAuthorizationStatusAuthorizedAlways && self.shouldUpdateAfterAuthorization) {
        [self refreshMonitoredRegions];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state
    forRegion:(CLBeaconRegion *)region
{
    if (state == CLRegionStateInside) {
        DDLogDebug(@"Did enter region %@.", region.identifier);
        [self.locationManager startRangingBeaconsInRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLBeaconRegion *)region
{
    [self leaveRegion:(CLBeaconRegion *)region];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons
    inRegion:(CLBeaconRegion *)region
{
    BeaconTagConfiguration *configuration = self.configurationsById[region.identifier];
    WorkflowConditionType workflowCondition = configuration.workflowConditionType;
    
    for (CLBeacon *beacon in beacons) {
        NSString *beaconID = beaconIdentifierString(beacon);

        BeaconTag *beaconTag = self.lastSeenBeacons[beaconID];
        if (!beaconTag) {
            beaconTag = [[BeaconTag alloc] init];
        }
		DDLogVerbose(@"Ranged %@: proximity = %ld lastSignalProximity = %ld", beaconID, (long)beacon.proximity, (long)beaconTag.lastSignalProximity);

        // Check if we are going away.
        if (beaconTag.lastSignalProximity != CLProximityUnknown &&
			beacon.proximity < beaconTag.lastSignalProximity) {
            beaconTag.movingAway = YES;
            beaconTag.movingAwayTimestamp = [NSDate date];
            DDLogDebug(@"Beacon %@ is moving away.", beaconID);
        }

        if (beaconTag.movingAway &&
            [beaconTag.movingAwayTimestamp timeIntervalSinceNow] < -kMoveAwayInterval) {
            beaconTag.movingAway = NO;
            beaconTag.movingAwayTimestamp = nil;
        }

        beaconTag.lastSignalProximity = beacon.proximity;

        // Don't change state on UNKNOWN proximity.
        // This fixes accedental 'enter region' event after leaving region on iOS 7.0.
        if (beacon.proximity == CLProximityUnknown) {
            if (beaconTag.movingAway) {
                [self leaveBeaconWithID:beaconID];
            }
            continue;
        }
        
        // Remember timestamp of last ping.
        // After a timeout the leave event will be triggered.
        if (workflowConditionTriggersOnProximity(workflowCondition, beacon.proximity)) {
            beaconTag.lastSignalTimestamp = [NSDate date];
        }
        
        // State didn't change (already inside).
        if ([self.insideBeacons containsObject:beaconID]) {
            continue;
        }
        
        BOOL isInside = beacon.proximity != CLProximityUnknown;

        if (isInside) {
            [self.insideBeacons addObject:beaconID];
            [self startAutoleaveTimer];
            
            if (workflowConditionTriggersOnProximity(workflowCondition, beacon.proximity)) {
                [self.delegate triggeringController:self triggeredOnConfiguration:configuration bIsInside:YES];
                // For "touch an object" we're inside only in immediate zone.
                self.lastSeenBeacons[beaconID] = beaconTag;
            }
        }

        // Remember timestamp of last ping.
        // After a timeout the leave event will be triggered.
        if (isInside) {
            beaconTag.lastSignalTimestamp = [NSDate date];
        }
    }
}

- (void)leaveRegion:(CLBeaconRegion *)region
{
    [self.locationManager stopRangingBeaconsInRegion:region];
    NSString *regionUUID = region.proximityUUID.UUIDString;
    DDLogDebug(@"Did leave region %@.", regionUUID);

    // Update beacons list.
    NSMutableArray *outsideBeacons = [[NSMutableArray alloc] init];
    for (NSString *beaconIdentifier in self.insideBeacons) {
        if ([beaconIdentifier hasPrefix:regionUUID]) {
            [outsideBeacons addObject:beaconIdentifier];
        }
    }

    for (NSString *beaconID in outsideBeacons) {
        [self leaveBeaconWithID:beaconID];
    }
}

- (void)refreshMonitoredRegions
{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        self.shouldUpdateAfterAuthorization = YES;
        return;
    }
    
    self.shouldUpdateAfterAuthorization = NO;

    // Monitoring works more reliable after restarting...
    NSSet *monitoredRegions = self.locationManager.monitoredRegions;
    for (CLBeaconRegion *region in monitoredRegions) {
        DDLogDebug(@"Stop monitoring for region %@.", region.proximityUUID.UUIDString);
        [self.locationManager stopMonitoringForRegion:region];
        [self.locationManager stopRangingBeaconsInRegion:region];
    }

    for (CLBeaconRegion *region in self.regions) {
        DDLogDebug(@"Start monitoring for region %@.", region.proximityUUID.UUIDString);
        [self.locationManager startMonitoringForRegion:region];
    }
}

- (void)startAutoleaveTimer
{
	//DDLogDebug(@"startAutoleaveTimer()");
    [self stopAutoleaveTimer];
    
    // Don't start timer in BG mode (system may kill the app if it runs for too long.).
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
	
    self.autoleaveTimer = [NSTimer scheduledTimerWithTimeInterval:kAutoLeaveInterval/10.0
        target:self selector:@selector(autoleaveTimerTick:) userInfo:nil repeats:YES];
}

- (void)stopAutoleaveTimer
{
	//DDLogDebug(@"stopAutoleaveTimer()");
    if (self.autoleaveTimer.isValid) {
        [self.autoleaveTimer invalidate];
    }
    self.autoleaveTimer = nil;
}

- (void)autoleaveTimerTick:(NSTimer *)timer
{
    NSMutableArray *autoLeavedBeacons = [[NSMutableArray alloc] init];
    [self.lastSeenBeacons enumerateKeysAndObjectsUsingBlock:
        ^(NSString *beaconID, BeaconTag *beaconTag, BOOL *stop) {
            NSTimeInterval lastSignalInterval = [beaconTag.lastSignalTimestamp timeIntervalSinceNow];
			//DDLogDebug(@"autoleaveTimerTick() lastSignalInterval = %f\nbeaconTag.movingAway = %@", lastSignalInterval, beaconTag.movingAway ? @"true" : @"false");
			
            if (lastSignalInterval <= -kAutoLeaveInterval ||
                (beaconTag.movingAway && lastSignalInterval <= -kMoveAwayInterval)) {
                [autoLeavedBeacons addObject:beaconID];
            }
        }];
    
    for (NSString *leavedBeacon in autoLeavedBeacons) {
        [self leaveBeaconWithID:leavedBeacon];
    }
}

- (void)leaveBeaconWithID:(NSString *)beaconId
{
    DDLogDebug(@"Leaving region for beacon %@.", beaconId);

    [self.insideBeacons removeObject:beaconId];
    if (self.insideBeacons.count == 0) {
        [self stopAutoleaveTimer];
    }
    
    BeaconTag *beaconTag = self.lastSeenBeacons[beaconId];
    beaconTag.lastSignalTimestamp = nil;
    beaconTag.lastSignalProximity = CLProximityUnknown;
    
    BeaconTagConfiguration *configuration = self.configurationsById[beaconId];
    BOOL triggerOnExit = configuration.workflowConditionType == workflowConditionTypeLeaveRegion || configuration.workflowConditionType == workflowConditionTypeEnterAndLeaveRegion;
    
    if (triggerOnExit) {
        [self.delegate triggeringController:self triggeredOnConfiguration:configuration bIsInside:NO];
    }
    
    [self refreshMonitoredRegions];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self stopAutoleaveTimer];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (self.insideBeacons.count > 0) {
        [self startAutoleaveTimer];
    }
}

BOOL workflowConditionTriggersOnProximity(WorkflowConditionType condition, CLProximity proximity)
{
    switch (condition) {
        case workflowConditionTypeEnterRegion:
		case workflowConditionTypeEnterAndLeaveRegion:
        case workflowConditionTypeTemperature:
        case workflowConditionTypeMovement:
            return proximity == CLProximityFar ||
                proximity == CLProximityNear || proximity == CLProximityImmediate;
        
        case workflowConditionTypeTouchAnObject:
            return proximity == CLProximityImmediate;
        
        case workflowConditionTypeLeaveRegion:
            return proximity == CLProximityUnknown;
        
        default:
            return NO;
    }
}

NSString *beaconIdentifierString(CLBeacon *beacon)
{
    return [NSString stringWithFormat:@"%@:%X:%X", beacon.proximityUUID.UUIDString,
        beacon.major.intValue, beacon.minor.intValue];
}


@end

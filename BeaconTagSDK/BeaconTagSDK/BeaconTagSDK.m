#import "BeaconTagSDK.h"
#import "ConfigurationController.h"
#import "TriggeringController.h"
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

#import "LoggingRoutines.h"
#import "BeaconTagConfiguration.h"

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>


@interface BeaconTagSDK () <TriggeringControllerDelegate, ConfigurationControllerDataSource,
    ConfigurationControllerDelegate>
@property (nonatomic) TriggeringController *triggeringController;
@property (nonatomic) ConfigurationController *configurationController;
@property (nonatomic) BOOL started;
@end


@implementation BeaconTagSDK

#pragma mark - Public methods

- (void)start
{
    self.started = YES;
    
    self.triggeringController = [[TriggeringController alloc] init];
    self.triggeringController.delegate = self;
    self.triggeringController.configurations = self.configurations;
    [self.triggeringController start];
    
    BOOL configurationModeEnabled = NO;
    for (BeaconTagConfiguration *configuration in self.configurations) {
        if (configuration.configurationModeEnabled) {
            configurationModeEnabled = YES;
            break;
        }
    }
    if (configurationModeEnabled) {
        [self setupConfigurationController];
    }
}

- (void)stop
{
    self.started = NO;
    
    [self.triggeringController stop];
    [self.configurationController stop];
}

#pragma mark - Accessors

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static id _sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (void)setConfigurations:(NSArray *)configurations
{
    _configurations = [configurations copy];
    self.triggeringController.configurations = configurations;
}

#pragma mark - Private methods

- (void)setupConfigurationController
{
    // Just in case.
    [self.configurationController stop];
    self.configurationController = nil;

    self.configurationController = [[ConfigurationController alloc] init];
    self.configurationController.delegate = self;
    self.configurationController.dataSource = self;
    [self.configurationController start];
}

#pragma mark Controllers callbacks

- (void)triggeringController:(TriggeringController *)triggeringController
	triggeredOnConfiguration:(BeaconTagConfiguration *)configuration bIsInside:(BOOL) bIsInside
{
	[self.delegate beaconTag:self triggeredActionForConfiguration:configuration bIsInside:bIsInside];
}

- (void)triggeringController:(TriggeringController *)triggeringController
    changedAuthenticationStatus:(BOOL)authenticated
{
    DDLogInfo(@"New authorization status: %i.", authenticated);
}

- (NSArray *)configurationsForController:(ConfigurationController *)configurationController
{
    return self.configurations;
}

- (void)configurationController:(ConfigurationController *)configurationController
    finishedConfiguration:(BeaconTagConfiguration *)configuration successfully:(BOOL)successfully
{
    if (successfully) {
        if ([self.delegate respondsToSelector:@selector(beaconTag:didWriteConfiguration:)]) {
            [self.delegate beaconTag:self didWriteConfiguration:configuration];
        }
    }
}

@end

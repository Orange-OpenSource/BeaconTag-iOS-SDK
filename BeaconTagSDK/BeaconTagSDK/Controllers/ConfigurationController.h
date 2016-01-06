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


@class CLBeaconRegion;
@class ConfigurationController;
@class BeaconTagConfiguration;


@protocol ConfigurationControllerDataSource <NSObject>
- (NSArray *)configurationsForController:(ConfigurationController *)configurationController;
@end


@protocol ConfigurationControllerDelegate <NSObject>
- (void)configurationController:(ConfigurationController *)configurationController
    finishedConfiguration:(BeaconTagConfiguration *)configuration
    successfully:(BOOL)configuredSuccessfully;
@end


@interface ConfigurationController : NSObject
@property (nonatomic, weak) id<ConfigurationControllerDataSource> dataSource;
@property (nonatomic, weak) id<ConfigurationControllerDelegate> delegate;
@property (nonatomic, readonly) BOOL btPoweredOn;
- (void)start;
- (void)stop;
@end

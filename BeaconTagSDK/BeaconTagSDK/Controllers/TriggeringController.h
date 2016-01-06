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
#import "BeaconTagConfigurationValues.h"


@class CLBeaconRegion;
@class TriggeringController;
@class BeaconTagConfiguration;


@protocol TriggeringControllerDelegate <NSObject>
- (void)triggeringController:(TriggeringController *)triggeringController
    changedAuthenticationStatus:(BOOL)authenticated;
- (void)triggeringController:(TriggeringController *)triggeringController
    triggeredOnConfiguration:(BeaconTagConfiguration *)configuration bIsInside:(BOOL) bIsInside;
@end


@interface TriggeringController : NSObject
@property (nonatomic, weak) id<TriggeringControllerDelegate> delegate;
@property (nonatomic, copy) NSArray *configurations;
- (void)start;
- (void)stop;
@end

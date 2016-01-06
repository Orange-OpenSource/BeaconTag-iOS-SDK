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

#import "ViewController.h"
#import <BeaconTagSDK/BeaconTagSDK.h>

@interface ViewController () <BeaconTagDelegate>
@property (nonatomic) IBOutlet UILabel *versionNumberLabel;
@property (nonatomic) BeaconTagSDK *beaconTag;
@end


@implementation ViewController

#pragma mark - VC lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupBeaconTag];

    self.versionNumberLabel.text = [NSString stringWithFormat:@"SDK version: %@",
        BEACON_TAG_SDK_VERSION];
}

#pragma mark - Private methods

- (void)setupBeaconTag
{
    self.beaconTag						= [BeaconTagSDK sharedInstance];
    self.beaconTag.delegate				= self;

    BeaconTagConfiguration *beacon_6	= [[BeaconTagConfiguration alloc] init];
    beacon_6.beaconTagUUID				= [[NSUUID alloc] initWithUUIDString:@"3D4F13B4-D1FD-4049-80E5-D3EDCC840B66"];
    beacon_6.beaconTagMajor				= @(0xF8B8);
    beacon_6.beaconTagMinor				= @(0xCDC0);
    beacon_6.txPower					= beaconTagTxPower_minus_12;
    beacon_6.workflowConditionType		= workflowConditionTypeEnterRegion;
    beacon_6.configurationModeEnabled	= YES;
    
    BeaconTagConfiguration *beacon_A	= [[BeaconTagConfiguration alloc] init];
    beacon_A.beaconTagUUID				= [[NSUUID alloc] initWithUUIDString:@"3D4F13B4-D1FD-4049-80E5-D3EDCC840B6A"];
    beacon_A.beaconTagMajor				= @(0x9F83);
    beacon_A.beaconTagMinor				= @(0x7DEF);
    beacon_A.txPower					= beaconTagTxPower_minus_12;
    beacon_A.workflowConditionType		= workflowConditionTypeEnterRegion;
    beacon_A.configurationModeEnabled	= YES;
	
	BeaconTagConfiguration *beacon_E	= [[BeaconTagConfiguration alloc] init];
	beacon_E.beaconTagUUID				= [[NSUUID alloc] initWithUUIDString:@"3D4F13B4-D1FD-4049-80E5-D3EDCC840B6E"];
	beacon_E.beaconTagMajor				= @(0x30C2);
	beacon_E.beaconTagMinor				= @(0x2EF1);
	beacon_E.txPower					= beaconTagTxPower_minus_12;
	beacon_E.workflowConditionType		= workflowConditionTypeEnterRegion;
	beacon_E.configurationModeEnabled	= YES;
	
	BeaconTagConfiguration *beacon_7	= [[BeaconTagConfiguration alloc] init];
	beacon_7.beaconTagUUID				= [[NSUUID alloc] initWithUUIDString:@"3D4F13B4-D1FD-4049-80E5-D3EDCC840B67"];
	beacon_7.beaconTagMajor				= @(0x8450);
	beacon_7.beaconTagMinor				= @(0x5BEF);
	beacon_7.txPower					= beaconTagTxPower_minus_62;
	beacon_7.workflowConditionType		= workflowConditionTypeEnterRegion;
	beacon_7.configurationModeEnabled	= YES;
	
	BeaconTagConfiguration *beacon_JL2	= [[BeaconTagConfiguration alloc] init];
	beacon_JL2.beaconTagUUID			= [[NSUUID alloc] initWithUUIDString:@"3D4F13B4-D1FD-4049-80E5-D3EDCC840B66"];
	beacon_JL2.beaconTagMajor			= @(0x63A2);
	beacon_JL2.beaconTagMinor			= @(0x30B4);
	beacon_JL2.txPower					= beaconTagTxPower_minus_62;
	beacon_JL2.workflowConditionType	= workflowConditionTypeEnterRegion;
	beacon_JL2.configurationModeEnabled	= YES;
	
	BeaconTagConfiguration *beacon_JL	= [[BeaconTagConfiguration alloc] init];
	beacon_JL.beaconTagUUID				= [[NSUUID alloc] initWithUUIDString:@"3D4F13B4-D1FD-4049-80E5-D3EDCC840B6F"];
	beacon_JL.beaconTagMajor			= @(0x8630);
	beacon_JL.beaconTagMinor			= @(0xD8E8);
	beacon_JL.txPower					= beaconTagTxPower_minus_62;
	beacon_JL.advertisingInterval		= 160 * 2;									//	--> 200ms
//	beacon_JL.workflowConditionType		= workflowConditionTypeEnterRegion;			//	--> OK
//	beacon_JL.workflowConditionType		= workflowConditionTypeLeaveRegion;			//	--> OK
	beacon_JL.workflowConditionType		= workflowConditionTypeEnterAndLeaveRegion;	//	--> OK
//	beacon_JL.workflowConditionType		= workflowConditionTypeMovement;			//	--> OK
//	beacon_JL.sleepDelay				= 2;
	
/*	Pb lors de config :
 2015-08-25 15:47:10.691 BeaconTagSDK_DemoApp[2230:960631] Error while reading value for characteristic '59EC0A01-0B1E-4063-8B16-B00B50AA3A7E' on service '59EC0800-0B1E-4063-8B16-B00B50AA3A7E': Error Domain=CBATTErrorDomain Code=1 "The handle is invalid." UserInfo=0x17dc2270 {NSLocalizedDescription=The handle is invalid.}
 puis reste allumé en bleu fixe 1 minute
 
 Apres probleme pour changer la config : 1 appui sur le bouton --> 2 mn allumé en vert fixe --> pas de passage en config.
 Pour passer en mode config, appuyer sur le bouton lorsque l'on remet la pile (clignotement vert) !
*/
	
//	beacon_JL.workflowConditionType		= workflowConditionTypeTemperature;
	beacon_JL.configurationModeEnabled	= YES;
	
    self.beaconTag.configurations		= @[
											//beacon_6,
											//beacon_A
											//beacon_E,
											beacon_7,
											beacon_JL2
											];
	
    [self.beaconTag start];
}

#pragma mark - BeaconME callbacks

- (void)beaconTag:(BeaconTagSDK *)beaconTag
    triggeredActionForConfiguration:(BeaconTagConfiguration *)configuration bIsInside:(BOOL) bIsInside
{
	NSString *text = [NSString stringWithFormat:@"Triggered %@ inside : %@", configuration.beaconTagUUID.UUIDString, (bIsInside ? @"YES" : @"NO")];
    NSLog(@"%@", text);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:text
        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)beaconTag:(BeaconTagSDK *)beaconTag
    didWriteConfiguration:(BeaconTagConfiguration *)configuration
{
    NSString *text = [NSString stringWithFormat:@"Configured %@", configuration.beaconTagUUID.UUIDString];
    NSLog(@"%@", text);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:text
        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end

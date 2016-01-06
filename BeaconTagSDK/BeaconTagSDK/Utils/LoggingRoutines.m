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

//// Utils and constants
//#import "UIColor+HexString.h"
//
//// Libraries
//#import <CocoaLumberjack/DDASLLogger.h>
//#import <CocoaLumberjack/DDTTYLogger.h>
//#import <CocoaLumberjack/DDMultiFormatter.h>
//#import <CocoaLumberjack/DDDispatchQueueLogFormatter.h>
//
//
//void setupApplicationLogging()
//{
//    DDASLLogger *aslLogger = [DDASLLogger sharedInstance];
//    if (![[DDLog allLoggers] containsObject:aslLogger]) {
//        [DDLog addLogger:aslLogger];
//    }
//
//    setenv("XcodeColors", "YES", 1);
//    DDTTYLogger *ttyLogger = [DDTTYLogger sharedInstance];
//    ttyLogger.colorsEnabled = YES;
//    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithHexValue:0x4B2B10]
//        backgroundColor:nil forFlag:LOG_FLAG_DEBUG];
//    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithHexValue:0x666666]
//        backgroundColor:nil forFlag:LOG_FLAG_VERBOSE];
//
//    if (![[DDLog allLoggers] containsObject:ttyLogger]) {
//        [DDLog addLogger:ttyLogger];
//    }
//    
//}

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

// Libraries
//#import <CocoaLumberjack/DDLog.h>
//
//
//#ifdef DEBUG
//    #define ddLogLevel LOG_LEVEL_VERBOSE
//#else
//    #define ddLogLevel LOG_LEVEL_WARN
//#endif
//
//
//void setupApplicationLogging();

#ifdef DEBUG
    #define DDLogVerbose(...) NSLog(__VA_ARGS__)
    #define DDLogDebug(...) NSLog(__VA_ARGS__)
    #define DDLogInfo(...) NSLog(__VA_ARGS__)
    #define DDLogWarn(...) NSLog(__VA_ARGS__)
    #define DDLogError(...) NSLog(__VA_ARGS__)
#else
    #define DDLogVerbose(...) while(NO){}
    #define DDLogDebug(...) while(NO){}
    #define DDLogInfo(...) while(NO){}
    #define DDLogWarn(...) NSLog(__VA_ARGS__)
    #define DDLogError(...) NSLog(__VA_ARGS__)
#endif

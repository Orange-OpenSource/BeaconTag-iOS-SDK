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

#import "CBUUID+String.h"

@implementation CBUUID (String)

- (NSString *)stringValue
{
    // Available in iOS 7.1 and later.
    if ([self respondsToSelector:@selector(UUIDString)]) {
        return self.UUIDString;
    }
    // Convert manualy in iOS 7.0.
    else {
        NSData* data = self.data;
        if ([data length] == 2) {
            const unsigned char *tokenBytes = [data bytes];
            return [NSString stringWithFormat:@"%02X%02X", tokenBytes[0], tokenBytes[1]];
        }
        else if ([data length] == 16)
        {
            NSUUID* nsuuid = [[NSUUID alloc] initWithUUIDBytes:[data bytes]];
            return [nsuuid UUIDString];
        }

        // We should not be here!
        return [self description];
    }
}

@end

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

#import "KVCUtils.h"

// Libraries
#import <objc/runtime.h>


NSString *po(id object)
{
    Class objectClass = [object class];
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"Object %@ [%@]:",
        [NSValue valueWithPointer:(void *)object], NSStringFromClass(objectClass)];

    unsigned int numberOfProperties = 0;
    objc_property_t *properties = class_copyPropertyList(objectClass, &numberOfProperties);
    for (NSUInteger i = 0; i < numberOfProperties; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [description appendFormat:@"\n%@: %@", name, [object valueForKey:name]];
    }
    free(properties);

    return description;
}
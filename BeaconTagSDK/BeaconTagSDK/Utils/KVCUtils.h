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

#ifndef STR_PROP
    #define STR_PROP( prop ) NSStringFromSelector(@selector(prop))
#endif

#pragma mark - NSCoding helpers


#ifndef STR_PROP
    #define STR_PROP( prop ) NSStringFromSelector(@selector(prop))
#endif


#ifndef PROPERTY_CODECS
    #define PROPERTY_CODECS

    #define ENCODE_BOOL_PROPERTY( coder , prop )\
        [coder encodeBool:self.prop forKey:@#prop]
    #define ENCODE_INTEGER_PROPERTY( coder , prop )\
        [coder encodeInteger:self.prop forKey:@#prop]
    #define ENCODE_DOUBLE_PROPERTY( coder , prop )\
        [coder encodeDouble:self.prop forKey:@#prop]
    #define ENCODE_FLOAT_PROPERTY( coder , prop )\
        [coder encodeFloat:self.prop forKey:@#prop]
    #define ENCODE_OBJECT_PROPERTY( coder , prop )\
        [coder encodeObject:self.prop forKey:@#prop]

    #define DECODE_BOOL_PROPERTY( decoder , prop )\
        self.prop = [decoder decodeBoolForKey:@#prop]
    #define DECODE_INTEGER_PROPERTY( decoder , prop )\
        self.prop = [decoder decodeIntegerForKey:@#prop]
    #define DECODE_DOUBLE_PROPERTY( decoder , prop )\
        self.prop = [decoder decodeDoubleForKey:@#prop]
    #define DECODE_FLOAT_PROPERTY( decoder , prop )\
        self.prop = [decoder decodeFloatForKey:@#prop]
    #define DECODE_OBJECT_PROPERTY( decoder , prop )\
        self.prop = [decoder decodeObjectForKey:@#prop]
#endif


// Debug info: values for all properties of an object.
NSString *po(id object);

//
// Copyright (c) 2010, Michael Ash
// Copyright (c) 2012, Lolay, Inc.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// Neither the name of Michael Ash nor the names of its contributors may be
// used to endorse or promote products derived from this software without
// specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//

#import "RTProperty.h"


@interface _RTObjCProperty : RTProperty
{
    objc_property_t _property;
    NSArray *_attributes;
}
@end

@implementation _RTObjCProperty

- (id)initWithObjCProperty: (objc_property_t)property
{
    if((self = [self init]))
    {
        _property = property;
        _attributes = [[[NSString stringWithUTF8String: property_getAttributes(property)] componentsSeparatedByString: @","] copy];
    }
    return self;
}

- (NSString *)name
{
    return [NSString stringWithUTF8String: property_getName(_property)];
}

- (NSString *)attributeEncodings
{
    NSPredicate *filter = [NSPredicate predicateWithFormat: @"NOT (self BEGINSWITH 'T') AND NOT (self BEGINSWITH 'V')"];
    return [[_attributes filteredArrayUsingPredicate: filter] componentsJoinedByString: @","];
}

- (BOOL)hasAttribute: (NSString *)code
{
    for(NSString *encoded in _attributes)
        if([encoded hasPrefix: code]) return YES;
    return NO;
}

- (BOOL)isReadOnly
{
    return [self hasAttribute: @"R"];
}

- (RTPropertySetterSemantics)setterSemantics
{
    if([self hasAttribute: @"C"]) return RTPropertySetterSemanticsCopy;
    if([self hasAttribute: @"&"]) return RTPropertySetterSemanticsRetain;
    return RTPropertySetterSemanticsAssign;
}

- (BOOL)isNonAtomic
{
    return [self hasAttribute: @"N"];
}

- (BOOL)isDynamic
{
    return [self hasAttribute: @"D"];
}

- (BOOL)isWeakReference
{
    return [self hasAttribute: @"W"];
}

- (BOOL)isEligibleForGarbageCollection
{
    return [self hasAttribute: @"P"];
}

- (NSString *)contentOfAttribute: (NSString *)code
{
    for(NSString *encoded in _attributes)
        if([encoded hasPrefix: code]) return [encoded substringFromIndex: 1];
    return nil;
}

- (SEL)customGetter
{
    return NSSelectorFromString([self contentOfAttribute: @"G"]);
}

- (SEL)customSetter
{
    return NSSelectorFromString([self contentOfAttribute: @"G"]);
}

- (NSString *)typeEncoding
{
    return [self contentOfAttribute: @"T"];
}

- (NSString *)oldTypeEncoding
{
    return [self contentOfAttribute: @"t"];
}

- (NSString *)ivarName
{
    return [self contentOfAttribute: @"V"];
}

@end

@implementation RTProperty

+ (id)propertyWithObjCProperty: (objc_property_t)property
{
    return [[self alloc] initWithObjCProperty: property];
}

- (id)initWithObjCProperty: (objc_property_t)property
{
    return [[_RTObjCProperty alloc] initWithObjCProperty: property];
}

- (NSString *)description
{
    return [NSString stringWithFormat: @"<%@ %p: %@ %@ %@ %@>", [self class], self, [self name], [self attributeEncodings], [self typeEncoding], [self ivarName]];
}

- (BOOL)isEqual: (id)other
{
    return [other isKindOfClass: [RTProperty class]] &&
           [[self name] isEqual: [other name]] &&
           ([self attributeEncodings] ? [[self attributeEncodings] isEqual: [other attributeEncodings]] : ![other attributeEncodings]) &&
           [[self typeEncoding] isEqual: [other typeEncoding]] &&
           ([self ivarName] ? [[self ivarName] isEqual: [other ivarName]] : ![other ivarName]);
}

- (NSUInteger)hash
{
    return [[self name] hash] ^ [[self typeEncoding] hash];
}

- (NSString *)name
{
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (NSString *)attributeEncodings
{
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (BOOL)isReadOnly
{
    [self doesNotRecognizeSelector: _cmd];
    return NO;
}
- (RTPropertySetterSemantics)setterSemantics
{
    [self doesNotRecognizeSelector: _cmd];
    return RTPropertySetterSemanticsAssign;
}

- (BOOL)isNonAtomic
{
    [self doesNotRecognizeSelector: _cmd];
    return NO;
}

- (BOOL)isDynamic
{
    [self doesNotRecognizeSelector: _cmd];
    return NO;
}

- (BOOL)isWeakReference
{
    [self doesNotRecognizeSelector: _cmd];
    return NO;
}

- (BOOL)isEligibleForGarbageCollection
{
    [self doesNotRecognizeSelector: _cmd];
    return NO;
}

- (SEL)customGetter
{
    [self doesNotRecognizeSelector: _cmd];
    return (SEL)0;
}

- (SEL)customSetter
{
    [self doesNotRecognizeSelector: _cmd];
    return (SEL)0;
}

- (NSString *)typeEncoding
{
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (NSString *)oldTypeEncoding
{
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (NSString *)ivarName
{
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

@end

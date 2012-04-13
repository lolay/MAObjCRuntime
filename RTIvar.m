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

#import "RTIvar.h"


@interface _RTObjCIvar : RTIvar
{
    Ivar _ivar;
}
@end

@implementation _RTObjCIvar

- (id)initWithObjCIvar: (Ivar)ivar
{
    if((self = [self init]))
    {
        _ivar = ivar;
    }
    return self;
}
- (NSString *)name
{
    return [NSString stringWithUTF8String: ivar_getName(_ivar)];
}

- (NSString *)typeEncoding
{
    return [NSString stringWithUTF8String: ivar_getTypeEncoding(_ivar)];
}

- (ptrdiff_t)offset
{
    return ivar_getOffset(_ivar);
}

@end

@interface _RTComponentsIvar : RTIvar
{
    NSString *_name;
    NSString *_typeEncoding;
}
@end

@implementation _RTComponentsIvar

- (id)initWithName: (NSString *)name typeEncoding: (NSString *)typeEncoding
{
    if((self = [self init]))
    {
        _name = [name copy];
        _typeEncoding = [typeEncoding copy];
    }
    return self;
}

- (NSString *)name
{
    return _name;
}

- (NSString *)typeEncoding
{
    return _typeEncoding;
}

- (ptrdiff_t)offset
{
    return -1;
}

@end

@implementation RTIvar

+ (id)ivarWithObjCIvar: (Ivar)ivar
{
    return [[self alloc] initWithObjCIvar: ivar];
}

+ (id)ivarWithName: (NSString *)name typeEncoding: (NSString *)typeEncoding
{
    return [[self alloc] initWithName: name typeEncoding: typeEncoding];
}

+ (id)ivarWithName: (NSString *)name encode: (const char *)encodeStr
{
    return [self ivarWithName: name typeEncoding: [NSString stringWithUTF8String: encodeStr]];
}

- (id)initWithObjCIvar: (Ivar)ivar
{
    return [[_RTObjCIvar alloc] initWithObjCIvar: ivar];
}

- (id)initWithName: (NSString *)name typeEncoding: (NSString *)typeEncoding
{
    return [[_RTComponentsIvar alloc] initWithName: name typeEncoding: typeEncoding];
}

- (NSString *)description
{
    return [NSString stringWithFormat: @"<%@ %p: %@ %@ %ld>", [self class], self, [self name], [self typeEncoding], (long)[self offset]];
}

- (BOOL)isEqual: (id)other
{
    return [other isKindOfClass: [RTIvar class]] &&
           [[self name] isEqual: [other name]] &&
           [[self typeEncoding] isEqual: [other typeEncoding]];
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

- (NSString *)typeEncoding
{
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (ptrdiff_t)offset
{
    [self doesNotRecognizeSelector: _cmd];
    return 0;
}

@end

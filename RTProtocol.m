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

#import "RTProtocol.h"
#import "RTMethod.h"


@interface _RTObjCProtocol : RTProtocol
{
    Protocol *_protocol;
}
@end

@implementation _RTObjCProtocol

- (id)initWithObjCProtocol: (Protocol *)protocol
{
    if((self = [self init]))
    {
        _protocol = protocol;
    }
    return self;
}

- (Protocol *)objCProtocol
{
    return _protocol;
}

@end

@implementation RTProtocol

+ (NSArray *)allProtocols
{
    unsigned int count;
    Protocol **protocols = objc_copyProtocolList(&count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject: [[[self alloc] initWithObjCProtocol: protocols[i]] autorelease]];
    
    free(protocols);
    return array;
}

+ (id)protocolWithObjCProtocol: (Protocol *)protocol
{
    return [[[self alloc] initWithObjCProtocol: protocol] autorelease];
}

+ (id)protocolWithName: (NSString *)name
{
    return [[[self alloc] initWithName: name] autorelease];
}

- (id)initWithObjCProtocol: (Protocol *)protocol
{
    [self release];
    return [[_RTObjCProtocol alloc] initWithObjCProtocol: protocol];
}

- (id)initWithName: (NSString *)name
{
    return [self initWithObjCProtocol:objc_getProtocol([name cStringUsingEncoding:[NSString defaultCStringEncoding]])];
}

- (NSString *)description
{
    return [NSString stringWithFormat: @"<%@ %p: %@>", [self class], self, [self name]];
}

- (BOOL)isEqual: (id)other
{
    return [other isKindOfClass: [RTProtocol class]] &&
           [[self objCProtocol] isEqual: [other objCProtocol]];
}

- (NSUInteger)hash
{
    return [[self objCProtocol] hash];
}

- (Protocol *)objCProtocol
{
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (NSString *)name
{
    return [NSString stringWithUTF8String: protocol_getName([self objCProtocol])];
}

- (NSArray *)incorporatedProtocols
{
    unsigned int count;
    Protocol **protocols = protocol_copyProtocolList([self objCProtocol], &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject: [RTProtocol protocolWithObjCProtocol: protocols[i]]];
    
    free(protocols);
    return array;
}

- (NSArray *)methodsRequired: (BOOL)isRequiredMethod instance: (BOOL)isInstanceMethod
{
    unsigned int count;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList([self objCProtocol], isRequiredMethod, isInstanceMethod, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
    {
        NSString *signature = [NSString stringWithCString: methods[i].types encoding: [NSString defaultCStringEncoding]];
        [array addObject: [RTMethod methodWithSelector: methods[i].name implementation: NULL signature: signature]];
    }
    
    free(methods);
    return array;
}

@end

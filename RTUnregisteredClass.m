
#import "RTUnregisteredClass.h"

#import "RTProtocol.h"
#import "RTIvar.h"
#import "RTMethod.h"


@implementation RTUnregisteredClass

+ (id)unregisteredClassWithName: (NSString *)name withSuperclass: (Class)superclass
{
    return [[self alloc] initWithName: name withSuperclass: superclass];
}
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

+ (id)unregisteredClassWithName: (NSString *)name
{
    return [self unregisteredClassWithName: name withSuperclass: Nil];
}

- (id)initWithName: (NSString *)name withSuperclass: (Class)superclass
{
    if((self = [self init]))
    {
        _class = objc_allocateClassPair(superclass, [name UTF8String], 0);
        if(_class == Nil)
        {
            return nil;
        }
    }
    return self;
}

- (id)initWithName: (NSString *)name
{
    return [self initWithName: name withSuperclass: Nil];
}

- (void)addProtocol: (RTProtocol *)protocol
{
    class_addProtocol(_class, [protocol objCProtocol]);
}

- (void)addIvar: (RTIvar *)ivar
{
    const char *typeStr = [[ivar typeEncoding] UTF8String];
    NSUInteger size, alignment;
    NSGetSizeAndAlignment(typeStr, &size, &alignment);
    class_addIvar(_class, [[ivar name] UTF8String], size, log2(alignment), typeStr);
}

- (void)addMethod: (RTMethod *)method
{
    class_addMethod(_class, [method selector], [method implementation], [[method signature] UTF8String]);
}

- (Class)registerClass
{
    objc_registerClassPair(_class);
    return _class;
}

@end

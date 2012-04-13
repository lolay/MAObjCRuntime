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

#import <Foundation/Foundation.h>


@class RTProtocol;
@class RTIvar;
@class RTProperty;
@class RTMethod;
@class RTUnregisteredClass;

@interface NSObject (MARuntime)

// includes the receiver
+ (NSArray *)rt_subclasses;

+ (RTUnregisteredClass *)rt_createUnregisteredSubclassNamed: (NSString *)name;
+ (Class)rt_createSubclassNamed: (NSString *)name;
+ (void)rt_destroyClass;

+ (BOOL)rt_isMetaClass;
+ (Class)rt_setSuperclass: (Class)newSuperclass;
+ (size_t)rt_instanceSize;

+ (NSArray *)rt_protocols;

+ (NSArray *)rt_methods;
+ (RTMethod *)rt_methodForSelector: (SEL)sel;

+ (void)rt_addMethod: (RTMethod *)method;

+ (NSArray *)rt_ivars;
+ (RTIvar *)rt_ivarForName: (NSString *)name;

+ (NSArray *)rt_properties;
+ (RTProperty *)rt_propertyForName: (NSString *)name;

// Apple likes to fiddle with -class to hide their dynamic subclasses
// e.g. KVO subclasses, so [obj class] can lie to you
// rt_class is a direct call to object_getClass (which in turn
// directly hits up the isa) so it will always tell the truth
- (Class)rt_class;
- (Class)rt_setClass: (Class)newClass;

@end

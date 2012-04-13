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

#import "MARTNSObject.h"

#import <objc/runtime.h>

#import "RTProtocol.h"
#import "RTIvar.h"
#import "RTProperty.h"
#import "RTMethod.h"
#import "RTUnregisteredClass.h"


@implementation NSObject (MARuntime)

+ (NSArray *)rt_subclasses
{
    Class *buffer = NULL;
    
    int count, size;
    do
    {
        count = objc_getClassList(NULL, 0);
        buffer = (Class *)realloc(buffer, count * sizeof(*buffer));
        size = objc_getClassList(buffer, count);
    } while(size != count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(int i = 0; i < count; i++)
    {
        Class candidate = buffer[i];
        Class superclass = candidate;
        while(superclass)
        {
            if(superclass == self)
            {
                [array addObject: candidate];
                break;
            }
            superclass = class_getSuperclass(superclass);
        }
    }
    free(buffer);
    return array;
}

+ (RTUnregisteredClass *)rt_createUnregisteredSubclassNamed: (NSString *)name
{
    return [RTUnregisteredClass unregisteredClassWithName: name withSuperclass: self];
}

+ (Class)rt_createSubclassNamed: (NSString *)name
{
    return [[self rt_createUnregisteredSubclassNamed: name] registerClass];
}

+ (void)rt_destroyClass
{
    objc_disposeClassPair(self);
}

+ (BOOL)rt_isMetaClass
{
    return class_isMetaClass(self);
}

#ifdef __clang__
#pragma clang diagnostic push
#endif
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (Class)rt_setSuperclass: (Class)newSuperclass
{
    return class_setSuperclass(self, newSuperclass);
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif

+ (size_t)rt_instanceSize
{
    return class_getInstanceSize(self);
}

+ (NSArray *)rt_protocols
{
    unsigned int count;
    __unsafe_unretained Protocol **protocols = class_copyProtocolList(self, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject: [RTProtocol protocolWithObjCProtocol: protocols[i]]];
    
    free(protocols);
    return array;
}

+ (NSArray *)rt_methods
{
    unsigned int count;
    Method *methods = class_copyMethodList(self, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject: [RTMethod methodWithObjCMethod: methods[i]]];
    
    free(methods);
    return array;
}

+ (RTMethod *)rt_methodForSelector: (SEL)sel
{
    Method m = class_getInstanceMethod(self, sel);
    if(!m) return nil;
    
    return [RTMethod methodWithObjCMethod: m];
}

+ (void)rt_addMethod: (RTMethod *)method
{
    class_addMethod(self, [method selector], [method implementation], [[method signature] UTF8String]);
}

+ (NSArray *)rt_ivars
{
    unsigned int count;
    Ivar *list = class_copyIvarList(self, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject: [RTIvar ivarWithObjCIvar: list[i]]];
    
    free(list);
    return array;
}

+ (RTIvar *)rt_ivarForName: (NSString *)name
{
    Ivar ivar = class_getInstanceVariable(self, [name UTF8String]);
    if(!ivar) return nil;
    return [RTIvar ivarWithObjCIvar: ivar];
}

+ (NSArray *)rt_properties
{
    unsigned int count;
    objc_property_t *list = class_copyPropertyList(self, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject: [RTProperty propertyWithObjCProperty: list[i]]];
    
    free(list);
    return array;
}

+ (RTProperty *)rt_propertyForName: (NSString *)name
{
    objc_property_t property = class_getProperty(self, [name UTF8String]);
    if(!property) return nil;
    return [RTProperty propertyWithObjCProperty: property];
}

- (Class)rt_class
{
    return object_getClass(self);
}

- (Class)rt_setClass: (Class)newClass
{
    return object_setClass(self, newClass);
}

@end


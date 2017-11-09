//
//  ORObjectRelation+ORObjectRelationObserver.m
//  ORObjectRelation
//
//  Created by xulinfeng on 2017/11/1.
//  Copyright © 2017年 xulinfeng. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+ORObjectRelationObserver.h"

NSString * ORObjectRelationObserverName(id observer){
    return [NSString stringWithFormat:@"%@%d", NSStringFromClass([observer class]), (int)observer];
}

@interface ORObjectRelationObserverSetter : NSObject

@property (nonatomic, copy) NSString *observerName;

@property (nonatomic, strong) NSMutableArray<ORObjectRelation *> *observedObjectRelations;

@end

@implementation ORObjectRelationObserverSetter

- (NSMutableArray<ORObjectRelation *> *)observedObjectRelations{
    if (!_observedObjectRelations) {
        _observedObjectRelations = [NSMutableArray array];
    }
    return _observedObjectRelations;
}

- (void)dealloc{
    [self clear];
}

- (void)clear{
    for (ORObjectRelation *relation in [self observedObjectRelations]) {
        [relation removeObserverNamed:[self observerName]];
    }
}

@end

@interface NSObject (ORObjectRelationObserverSetter)

@property (nonatomic, strong, readonly) ORObjectRelationObserverSetter *objectRelationObserverSetter;

@end

@implementation NSObject (ORObjectRelationObserverSetter)

- (ORObjectRelationObserverSetter *)objectRelationObserverSetter{
    ORObjectRelationObserverSetter *setter = objc_getAssociatedObject(self, @selector(objectRelationObserverSetter));
    if (!setter) {
        setter = [ORObjectRelationObserverSetter new];
        objc_setAssociatedObject(self, @selector(objectRelationObserverSetter), setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return setter;
}

@end

@implementation NSObject (ORObjectRelationObserver)

- (BOOL)observeRelation:(ORObjectRelation *)relation picker:(void (^)(id relation, id value))picker error:(NSError **)error;{
    return [self observeRelation:relation queue:dispatch_get_main_queue() picker:picker error:error];
}

- (BOOL)observeRelation:(ORObjectRelation *)relation queue:(dispatch_queue_t)queue picker:(void (^)(id relation, id value))picker error:(NSError **)error;{
    NSString *observerName = ORObjectRelationObserverName(self);
    BOOL success = [relation registerObserverNamed:observerName queue:queue picker:picker error:error];
    if (success) {
        self.objectRelationObserverSetter.observerName = ORObjectRelationObserverName(self);
        [[[self objectRelationObserverSetter] observedObjectRelations] addObject:relation];
    }
    return success;
}

- (void)removeAllObservers;{
    [[self objectRelationObserverSetter] clear];
}

@end

@implementation NSObject (ORCountObjectRelation)

- (BOOL)observeRelation:(ORCountObjectRelation *)relation countPicker:(void (^)(id relation, NSUInteger count))countPicker error:(NSError **)error;{
    return [self observeRelation:relation queue:dispatch_get_main_queue() countPicker:countPicker error:error];
}

- (BOOL)observeRelation:(ORObjectRelation *)relation queue:(dispatch_queue_t)queue countPicker:(void (^)(id relation, NSUInteger count))countPicker error:(NSError **)error; {
    return [self observeRelation:relation queue:queue picker:^(id relation, id value) {
        countPicker(relation, [value integerValue]);
    } error:error];
}

@end

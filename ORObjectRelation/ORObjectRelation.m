//
//  ORObjectRelation.m
//  ORObjectRelation
//
//  Created by xulinfeng on 2017/11/1.
//  Copyright © 2017年 xulinfeng. All rights reserved.
//

#import "ORObjectRelation.h"
#import "ORObjectRelation+Private.h"

NSString * const ORObjectRelationErrorDomain = @"com.objectRelation.domain";
NSString * const ORObjectRelationObserverNamePrefix = @"com.objectRelation.observer.name#";

@interface ORObjectRelationObserver ()

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) void (^picker)(id relation, id value);

@end

@implementation ORObjectRelationObserver

- (instancetype)initWithName:(NSString *)name picker:(void (^)(id relation, id value))picker;{
    return [self initWithName:name queue:dispatch_get_main_queue() picker:picker];
}

- (instancetype)initWithName:(NSString *)name queue:(dispatch_queue_t)queue picker:(void (^)(id relation, id value))picker;{
    if (self = [super init]) {
        self.name = name;
        self.picker = picker;
        self.queue = queue ?: dispatch_get_main_queue();
    }
    return self;
}

@end

@interface ORObjectRelation (){
    id _value;
    id _object;
    BOOL _enable;
    BOOL _allowSync;
}

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, assign) void *queueTag;

@property (nonatomic, strong) NSMutableArray<ORObjectRelation *> *mutableSubRelations;

@property (nonatomic, strong) NSMutableArray<ORObjectRelationObserver *> *mutableObservers;

@property (nonatomic, copy) id (^valueTransformer)(NSArray *subValues);

@property (nonatomic, weak) ORObjectRelation *parentObjectRelation;

@end

@implementation ORObjectRelation

+ (instancetype)relationWithName:(NSString *)name queue:(dispatch_queue_t)queue defaultValue:(id)defaultValue valueTransformer:(id (^)(NSArray *subValues))valueTransformer;{
    return [[self alloc] initWithName:name queue:queue defaultValue:defaultValue valueTransformer:valueTransformer];
}

- (instancetype)initWithName:(NSString *)name queue:(dispatch_queue_t)queue defaultValue:(id)defaultValue valueTransformer:(id (^)(NSArray *subValues))valueTransformer;{
    if (self = [self initWithName:name queue:queue]) {
        _value = defaultValue;
        _valueTransformer = [valueTransformer copy];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name queue:(dispatch_queue_t)queue{
    if (self = [super init]) {
        _queueTag = &_queueTag;
        _name = [name copy];
        _queue = queue ?: dispatch_get_main_queue();
        _enable = YES;
        _allowSync = YES;
        
        self.equalValue = ^BOOL(id objectRelation, id value, id replacement) {
            return [value isEqual:replacement];
        };
        dispatch_queue_set_specific(queue, _queueTag, _queueTag, NULL);
    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@""];
}

- (void)dealloc{
    self.queue = nil;
    self.parentObjectRelation = nil;
    
    for (ORObjectRelation *relation in [[self mutableSubRelations] copy]) {
        relation.parentObjectRelation = nil;
    }
    [[self mutableSubRelations] removeAllObjects];
    
    [[self mutableObservers] removeAllObjects];
}

#pragma mark - accessor

- (NSMutableArray<ORObjectRelation *> *)mutableSubRelations{
    if (!_mutableSubRelations) {
        _mutableSubRelations = [NSMutableArray array];
    }
    return _mutableSubRelations;
}

- (NSMutableArray<ORObjectRelationObserver *> *)mutableObservers{
    if (!_mutableObservers) {
        _mutableObservers = [NSMutableArray array];
    }
    return _mutableObservers;
}

- (id)subRelationNamed:(NSString *)name;{
    __block ORObjectRelation *relation = nil;
    [self _sync:^{
        for (ORObjectRelation *subRelation in [self mutableSubRelations]) {
            relation = [[subRelation name] isEqualToString:name] ? subRelation : nil;
            
            if (relation) break;
            else if ((relation = [subRelation subRelationNamed:name])) break;
        }
    }];
    return relation;
}

- (id)observerNamed:(NSString *)name{
    __block ORObjectRelationObserver *observer = nil;
    [self _sync:^{
        observer = [[[self mutableObservers] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]] firstObject];
    }];
    return observer;
}

- (NSArray<ORObjectRelation *> *)subRelations{
    __block NSArray<ORObjectRelation *> *subRelations = nil;
    [self _sync:^{
        subRelations = [[self mutableSubRelations] copy];
    }];
    return subRelations;
}

- (NSArray<ORObjectRelationObserver *> *)observers{
    __block NSArray<ORObjectRelationObserver *> *observers = nil;
    [self _sync:^{
        observers = [[self mutableObservers] copy];
    }];
    return observers;
}

- (NSString *)name{
    __block id name = nil;
    
    [self _sync:^{
        name = _name;
    }];
    
    return name;
}

- (id)value{
    __block id value = nil;
    
    [self _sync:^{
        value = _value;
    }];
    
    return value;
}

- (void)setValue:(id)value{
    [self _async:^{
        BOOL isEqual = self.equalValue && self.equalValue(self, _value, value);
        if (!isEqual) {
            _value = value;
            
            [self _performObserver];
        } else {
            [self _performInnerObserver];
        }
    }];
}

- (id)object{
    __block id object = nil;
    
    [self _sync:^{
        object = _object;
    }];
    
    return object;
}

- (void)setObject:(id)object{
    [self _async:^{
        _object = object;
    }];
}

- (BOOL)isEnable{
    __block BOOL isEnable = NO;
    
    [self _sync:^{
        isEnable = _enable;
    }];
    
    return isEnable;
}

- (void)setEnable:(BOOL)enable{
    [self _async:^{
        _enable = enable;
    }];
}

- (BOOL)isAllowSync{
    __block BOOL isAllowSync = NO;
    
    [self _sync:^{
        isAllowSync = _allowSync;
    }];
    
    return isAllowSync;
}

- (void)setAllowSync:(BOOL)allowSync{
    [self _async:^{
        if (_allowSync != allowSync) {
            _allowSync = allowSync;
            
            [self _performObserver];
        }
    }];
}

#pragma mark - private

- (void)_async:(dispatch_block_t)block;{
    if (dispatch_get_specific(_queueTag)) {
        block();
    } else {
        dispatch_async([self queue], block);
    }
}

- (void)_sync:(dispatch_block_t)block;{
    if (dispatch_get_specific(_queueTag)) {
        block();
    } else {
        dispatch_sync([self queue], block);
    }
}

- (ORObjectRelationObserver *)_appendObserverNamed:(NSString *)name queue:(dispatch_queue_t)queue picker:(void (^)(id relation, id value))picker error:(NSError **)error;{
    ORObjectRelationObserver *observer = [self observerNamed:name];
    if (!observer) {
        observer = [self _appendObserverNamed:name queue:queue picker:picker];
    } else if (error){
        *error = [NSError errorWithDomain:ORObjectRelationErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Exist observer named: %@.", name]}];
    }
    return observer;
}

- (ORObjectRelationObserver *)_appendObserverNamed:(NSString *)name queue:(dispatch_queue_t)queue picker:(void (^)(id relation, id value))picker {
    ORObjectRelationObserver *observer = [[ORObjectRelationObserver alloc] initWithName:name queue:queue picker:picker];
    
    [self _appendObserver:observer];
    
    return observer;
}

- (void)_appendObserver:(ORObjectRelationObserver *)observer {
    [[self mutableObservers] addObject:observer];
}

- (void)_removeObserver:(ORObjectRelationObserver *)observer {
    [[self mutableObservers] removeObject:observer];
}

- (BOOL)_appendSubRelation:(ORObjectRelation *)subRelation error:(NSError **)error; {
    [self _appendSubRelation:subRelation];
    __block __weak typeof(self) weak_self = self;
    return [subRelation _appendObserverNamed:[ORObjectRelationObserverNamePrefix stringByAppendingString:[subRelation name]] queue:[subRelation queue] picker:^(id relation, id value) {
        __strong typeof(weak_self) self = weak_self;
        [self _updateValue];
    } error:error] != nil;
}

- (void)_appendSubRelation:(ORObjectRelation *)subRelation{
    subRelation.parentObjectRelation = self;
    
    [[self mutableSubRelations] addObject:subRelation];
}

- (void)_removeSubRelation:(ORObjectRelation *)subRelation{
    subRelation.parentObjectRelation = nil;
    
    [[self mutableSubRelations] removeObject:subRelation];
    
    [self _updateValue];
}

- (void)_removeSubRelations:(NSArray<ORObjectRelation *> *)subRelations{
    for (ORObjectRelation *subRelation in subRelations) {
        subRelation.parentObjectRelation = nil;
    }
    [[self mutableSubRelations] removeObjectsInArray:subRelations];
    
    [self _updateValue];
}

- (void)_removeAllSubRelations{
    [[self mutableSubRelations] removeAllObjects];

    self.value = nil;
}

- (void)_updateValue{
    NSMutableArray *subValues = [NSMutableArray new];
    for (ORObjectRelation *relation in [self mutableSubRelations]) {
        if (![relation isAllowSync] || ![relation value]) continue;
        
        [subValues addObject:[relation value]];
    }
    
    id value = self.valueTransformer(subValues);
    if (![self allowUpdate] || self.allowUpdate(self, value)) {
        self.value = value;
    }
}

- (void)_performObserver {
    [self _performObserverWithValue:_value];
}

- (void)_performInnerObserver {
    [self _performObserverWithValue:_value innerEnable:YES outerEnable:NO];
}

- (void)_performObserverWithValue:(id)value{
    [self _performObserverWithValue:value innerEnable:YES outerEnable:YES];
}

- (void)_performObserverWithValue:(id)value innerEnable:(BOOL)innerEnable outerEnable:(BOOL)outerEnable {
    for (ORObjectRelationObserver *observer in [self mutableObservers]) {
        if ([[observer name] hasPrefix:ORObjectRelationObserverNamePrefix] && !innerEnable) continue;
        else if (![[observer name] hasPrefix:ORObjectRelationObserverNamePrefix] && !outerEnable) continue;
        
        [self _performObserver:observer value:value];
    }
}

- (void)_performObserver:(ORObjectRelationObserver *)observer value:(id)value {
    dispatch_async([observer queue], ^{
        if ([observer picker]) observer.picker(self, value);
    });
}

#pragma mark - public

- (BOOL)registerObserverNamed:(NSString *)name queue:(dispatch_queue_t)queue picker:(void (^)(id relation, id value))picker error:(NSError **)error;{
    __block ORObjectRelationObserver *observer = nil;
    __block NSError *innerError = nil;
    [self _sync:^{
        observer = [self _appendObserverNamed:name queue:queue picker:picker error:&innerError];
        if (!innerError) {
            [self _performObserver:observer value:[self value]];
        }
    }];
    if (error) *error = innerError;
    
    return !innerError;
}

- (void)removeObserverNamed:(NSString *)name; {
    [self _sync:^{
        ORObjectRelationObserver *existObserver = [self observerNamed:name];
        if (existObserver) {
            [self _removeObserver:existObserver];
        }
    }];
}

- (BOOL)addSubRelation:(ORObjectRelation *)subRelation error:(NSError **)error; {
    __block BOOL success = NO;
    __block NSError *innerError = nil;
    
    [self _sync:^{
        if (![[self mutableSubRelations] containsObject:subRelation]) {
            success = [self _appendSubRelation:subRelation error:&innerError];
        } else {
            innerError = [NSError errorWithDomain:ORObjectRelationErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Exist relation named: %@.", [subRelation name]]}];
        }
    }];
    if (error) {
        *error = innerError;
    }
    return success;
}

- (void)removeSubRelation:(ORObjectRelation *)subRelation; {
    [self _sync:^{
        [self _removeSubRelation:subRelation];
    }];
}

- (void)removeSubRelations:(NSArray<ORObjectRelation *> *)subRelations;{
    [self _sync:^{
        [self _removeSubRelations:subRelations];
    }];
}

- (void)removeSubRelationNamed:(NSString *)subRelationName;{
    [self _sync:^{
        [self _removeSubRelation:[self subRelationNamed:subRelationName]];
    }];
}

- (void)removeAllSubRelations;{
    [self _sync:^{
        [self _removeAllSubRelations];
    }];
}

- (void)clean;{
    [self _sync:^{
        self.object = nil;
        
        for (ORObjectRelation *relation in [self mutableSubRelations]) {
            [relation clean];
        }
        self.value = nil;
        
        if ([self cleanCompletion]) {
            self.cleanCompletion(self);
        }
    }];
}

- (void)removeFromParentObjectRelation;{
    [self _sync:^{
        [self removeObserverNamed:[ORObjectRelationObserverNamePrefix stringByAppendingString:[self name]]];
        
        [[self parentObjectRelation] removeSubRelation:self];
    }];
}

- (void)cleanAndRemoveFromParentObjectRelation;{
    [self clean];
    [self removeFromParentObjectRelation];
}

@end

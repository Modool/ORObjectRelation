//
//  ORObjectRelation.h
//  ORObjectRelation
//
//  Created by xulinfeng on 2017/11/1.
//  Copyright © 2017年 xulinfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ORObjectRelationErrorDomain;

@interface ORObjectRelationObserver : NSObject

@property (nonatomic, strong, readonly) dispatch_queue_t queue;

@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, copy, readonly) void (^picker)(id relation, id value);

- (instancetype)initWithName:(NSString *)name picker:(void (^)(id relation, id value))picker;
- (instancetype)initWithName:(NSString *)name queue:(dispatch_queue_t)queue picker:(void (^)(id relation, id value))picker;

@end

@interface ORObjectRelation : NSObject

@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, strong, readonly) dispatch_queue_t queue;

@property (nonatomic, copy, readonly) NSArray<ORObjectRelation *> *subRelations;

@property (nonatomic, copy, readonly) NSArray<ORObjectRelationObserver *> *observers;

@property (nonatomic, weak, readonly) ORObjectRelation *parentObjectRelation;

@property (nonatomic, copy, readonly) id (^valueTransformer)(NSArray *subValues);

@property (nonatomic, copy) BOOL (^equalValue)(id objectRelation, id value, id replacement);
@property (nonatomic, copy) BOOL (^allowUpdate)(id objectRelation, id value);
@property (nonatomic, copy) void (^cleanCompletion)(id objectRelation);

@property (nonatomic, strong) id value;

@property (nonatomic, strong) id object;

// Synchronization will be forbidden if NO, default is YES. 
@property (nonatomic, assign, getter=isEnable) BOOL enable;

@property (nonatomic, assign, getter=isAllowSync) BOOL allowSync;

- (id)subRelationNamed:(NSString *)name;
- (id)observerNamed:(NSString *)name;

+ (instancetype)relationWithName:(NSString *)name queue:(dispatch_queue_t)queue defaultValue:(id)defaultValue valueTransformer:(id (^)(NSArray *subValues))valueTransformer;
- (instancetype)initWithName:(NSString *)name queue:(dispatch_queue_t)queue defaultValue:(id)defaultValue valueTransformer:(id (^)(NSArray *subValues))valueTransformer;

- (BOOL)registerObserverNamed:(NSString *)name queue:(dispatch_queue_t)queue picker:(void (^)(id relation, id value))picker error:(NSError **)error;
- (void)removeObserverNamed:(NSString *)name;

- (BOOL)addSubRelation:(ORObjectRelation *)subRelation error:(NSError **)error;
- (void)removeSubRelation:(ORObjectRelation *)subRelation;
- (void)removeSubRelations:(NSArray<ORObjectRelation *> *)subRelations;
- (void)removeSubRelationNamed:(NSString *)subRelationName;
- (void)removeAllSubRelations;

- (void)clean;
- (void)removeFromParentObjectRelation;
- (void)cleanAndRemoveFromParentObjectRelation;

@end

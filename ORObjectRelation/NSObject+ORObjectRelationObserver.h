//
//  ORObjectRelation+ORObjectRelationObserver.h
//  ORObjectRelation
//
//  Created by xulinfeng on 2017/11/1.
//  Copyright © 2017年 xulinfeng. All rights reserved.
//

#import "ORObjectRelation.h"
#import "ORCountObjectRelation.h"
#import "ORMajorKeyCountObjectRelation.h"

@interface NSObject (ORObjectRelationObserver)

- (BOOL)observeRelation:(ORObjectRelation *)relation picker:(void (^)(id relation, id value))picker error:(NSError **)error;
- (BOOL)observeRelation:(ORObjectRelation *)relation queue:(dispatch_queue_t)queue picker:(void (^)(id relation, id value))picker error:(NSError **)error;

- (void)removeAllObservers;

@end

@interface NSObject (ORCountObjectRelation)

- (BOOL)observeRelation:(ORCountObjectRelation *)relation countPicker:(void (^)(id relation, NSUInteger count))countPicker error:(NSError **)error;
- (BOOL)observeRelation:(ORObjectRelation *)relation queue:(dispatch_queue_t)queue countPicker:(void (^)(id relation, NSUInteger count))countPicker error:(NSError **)error;

@end

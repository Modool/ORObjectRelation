//
//  ORCountObjectRelation.h
//  ORObjectRelation
//
//  Created by xulinfeng on 2017/11/1.
//  Copyright © 2017年 xulinfeng. All rights reserved.
//

#import "ORObjectRelation.h"

#define ORObjectRelationDefaultValueTransformer     ^(NSArray *subValues){                        \
                                                        return [subValues valueForKeyPath:@"@sum.floatValue"]; \
                                                    }

@interface ORCountObjectRelation : ORObjectRelation

@property (nonatomic, assign) NSInteger count;

+ (instancetype)relationWithName:(NSString *)name queue:(dispatch_queue_t)queue defaultCount:(NSInteger)defaultCount;
- (instancetype)initWithName:(NSString *)name queue:(dispatch_queue_t)queue defaultCount:(NSInteger)defaultCount;

- (BOOL)registerObserverNamed:(NSString *)name queue:(dispatch_queue_t)queue countPicker:(void (^)(id relation, NSInteger count))countPicker error:(NSError **)error;

@end

@interface ORCountObjectRelation (AbsoluteCount)

@property (nonatomic, assign, readonly) NSUInteger absoluteCount;

@end

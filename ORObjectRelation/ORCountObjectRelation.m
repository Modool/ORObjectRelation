//
//  ORCountObjectRelation.m
//  ORObjectRelation
//
//  Created by xulinfeng on 2017/11/1.
//  Copyright © 2017年 xulinfeng. All rights reserved.
//

#import "ORCountObjectRelation.h"
#import "ORObjectRelation+Private.h"

@implementation ORCountObjectRelation

+ (instancetype)relationWithName:(NSString *)name queue:(dispatch_queue_t)queue defaultCount:(NSInteger)defaultCount;{
    return [[self alloc] initWithName:name queue:queue defaultCount:defaultCount];
}

- (instancetype)initWithName:(NSString *)name queue:(dispatch_queue_t)queue defaultCount:(NSInteger)defaultCount;{
    if (self = [self initWithName:name queue:queue defaultValue:@(defaultCount) valueTransformer:ORObjectRelationDefaultValueTransformer]) {
        self.equalValue = ^BOOL(id objectRelation, id value, id replacement) {
            return [value integerValue] == [replacement integerValue];
        };
    }
    return self;
}

- (BOOL)registerObserverNamed:(NSString *)name queue:(dispatch_queue_t)queue countPicker:(void (^)(id relation, NSInteger count))countPicker error:(NSError **)error;{
    return [super registerObserverNamed:name queue:queue picker:^(id relation, id value) {
        if (countPicker) {
            countPicker(relation, [value integerValue]);
        }
    } error:error];
}

- (void)setCount:(NSInteger)count{
    [self setValue:@(count)];
}

- (NSInteger)count {
    return [[self value] integerValue];
}

@end

@implementation ORCountObjectRelation (AbsoluteCount)

- (NSUInteger)absoluteCount{
    __block id value = nil;
    [self _sync:^{
        NSMutableArray *absoluteValues = [NSMutableArray new];
        
        for (ORCountObjectRelation *relation in [[self subRelations] copy]) {
            if (![relation isKindOfClass:[ORCountObjectRelation class]]) continue;
            if ([[relation subRelations] count]) {
                [absoluteValues addObject:@([relation absoluteCount])];
            } else {
                [absoluteValues addObject:@([relation count])];
            }
        }
        value = [absoluteValues count] ? self.valueTransformer(absoluteValues) : [self value];
    }];
    
    return [value unsignedIntegerValue];
}

@end

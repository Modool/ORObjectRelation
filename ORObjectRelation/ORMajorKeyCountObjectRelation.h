//
//  ORMajorKeyCountObjectRelation.h
//  ORObjectRelation
//
//  Created by xulinfeng on 2017/11/1.
//  Copyright © 2017年 xulinfeng. All rights reserved.
//

#import "ORCountObjectRelation.h"

@interface ORMajorKeyCountObjectRelation : ORCountObjectRelation

@property (nonatomic, copy, readonly) NSString *objectID;

+ (instancetype)relationWithObjectID:(NSString *)objectID domain:(NSString *)domain queue:(dispatch_queue_t)queue defaultCount:(NSInteger)defaultCount;
- (instancetype)initWithObjectID:(NSString *)objectID domain:(NSString *)domain queue:(dispatch_queue_t)queue defaultCount:(NSInteger)defaultCount;

+ (NSString *)nameWithObjectID:(NSString *)objectID domain:(NSString *)domain;

@end

@interface ORMajorKeyCountObjectRelation (Remove)

- (void)removeSubRelationWithObjectID:(NSString *)objectID;
- (void)removeSubRelationWithObjectID:(NSString *)objectID domain:(NSString *)domain;

@end

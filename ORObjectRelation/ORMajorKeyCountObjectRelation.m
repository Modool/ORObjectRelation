//
//  ORMajorKeyCountObjectRelation.m
//  ORObjectRelation
//
//  Created by xulinfeng on 2017/11/1.
//  Copyright © 2017年 xulinfeng. All rights reserved.
//

#import "ORMajorKeyCountObjectRelation.h"

@interface ORMajorKeyCountObjectRelation ()

@property (nonatomic, copy) NSString *objectID;

@end

@implementation ORMajorKeyCountObjectRelation

+ (instancetype)relationWithObjectID:(NSString *)objectID domain:(NSString *)domain queue:(dispatch_queue_t)queue defaultCount:(NSInteger)defaultCount;{
    return [[self alloc] initWithObjectID:objectID domain:domain queue:queue defaultCount:defaultCount];
}

- (instancetype)initWithObjectID:(NSString *)objectID domain:(NSString *)domain queue:(dispatch_queue_t)queue defaultCount:(NSInteger)defaultCount;{
    NSString *name = [[self class] nameWithObjectID:objectID domain:domain];
    if (self = [self initWithName:name queue:queue defaultCount:defaultCount]) {
        self.objectID = objectID;
    }
    return self;
}

+ (NSString *)nameWithObjectID:(NSString *)objectID domain:(NSString *)domain;{
    return [[domain stringByAppendingString:@"#"] stringByAppendingString:objectID];
}

@end

@implementation ORMajorKeyCountObjectRelation (Remove)

- (void)removeSubRelationWithObjectID:(NSString *)objectID{
    ORObjectRelation *relation = [[[self subRelations] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"objectID == %@", objectID]] firstObject];
    
    [self removeSubRelation:relation];
}

- (void)removeSubRelationWithObjectID:(NSString *)objectID domain:(NSString *)domain;{
    [self removeSubRelationNamed:[ORMajorKeyCountObjectRelation nameWithObjectID:objectID domain:domain]];
}

@end

//
//  ORBadgeValueManager.m
//  ORObjectRelation
//
//  Created by xulinfeng on 2017/1/11.
//  Copyright © 2017年 xulinfeng. All rights reserved.
//

#import "ORBadgeValueManager.h"

NSString * const ORObjectRelationRootName = @"com.ObjectRelation.object.relation.root";
NSString * const ORObjectRelationNormalMessageDomainName = @"root.message.normal.messages";
NSString * const ORObjectRelationNormalQueueDomain = @"root.message.normal.messages.queue";

@interface ORBadgeValueManager ()

@property (nonatomic, strong) ORCountObjectRelation *rootObjectRelation;

/**
 *  root.home
 */
@property (nonatomic, strong) ORCountObjectRelation *homeObjectRelation;

/**
 *  root.message
 */
@property (nonatomic, strong) ORCountObjectRelation *messageObjectRelation;

/**
 *  root.other
 */
@property (nonatomic, strong) ORCountObjectRelation *otherObjectRelation;

@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation ORBadgeValueManager

+ (void)load{
    [super load];
    
    [[self sharedManager] initialize];
}

+ (instancetype)sharedManager; {
    static ORBadgeValueManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [self new];
    });
    return sharedManager;
}

- (void)initialize{
    self.queue = dispatch_queue_create([ORObjectRelationNormalQueueDomain UTF8String], NULL);
}

#pragma mark - accessor

- (ORCountObjectRelation *)rootObjectRelation{
    if (!_rootObjectRelation) {
        _rootObjectRelation = [ORCountObjectRelation relationWithName:ORObjectRelationRootName queue:[self queue] defaultCount:0];
    }
    return _rootObjectRelation;
}

- (ORCountObjectRelation *)homeObjectRelation{
    if (!_homeObjectRelation) {
        _homeObjectRelation = [ORCountObjectRelation relationWithName:@"root.home" queue:[self queue] defaultCount:0];
        
        [[self rootObjectRelation] addSubRelation:_homeObjectRelation error:nil];
    }
    return _homeObjectRelation;
}

- (ORCountObjectRelation *)messageObjectRelation{
    if (!_messageObjectRelation) {
        _messageObjectRelation = [ORCountObjectRelation relationWithName:@"root.message" queue:[self queue] defaultCount:0];
        [[self rootObjectRelation] addSubRelation:_messageObjectRelation error:nil];
    }
    return _messageObjectRelation;
}

- (ORCountObjectRelation *)otherObjectRelation{
    if (!_otherObjectRelation) {
        _otherObjectRelation = [ORCountObjectRelation relationWithName:@"root.other" queue:[self queue] defaultCount:0];
        [[self rootObjectRelation] addSubRelation:_otherObjectRelation error:nil];
    }
    return _otherObjectRelation;
}

- (ORMajorKeyCountObjectRelation *)normalMessageObjectRelationWithChatID:(NSString *)chatID;{
    NSParameterAssert(chatID);
    NSString *name = [ORMajorKeyCountObjectRelation nameWithObjectID:chatID domain:ORObjectRelationNormalMessageDomainName];
    ORMajorKeyCountObjectRelation *relation = [[self messageObjectRelation] subRelationNamed:name];
    if (!relation) {
        relation = [ORMajorKeyCountObjectRelation relationWithObjectID:chatID domain:ORObjectRelationNormalMessageDomainName queue:[self queue] defaultCount:0];
        NSError *error = nil;
        [[self messageObjectRelation] addSubRelation:relation error:&error];
    }
    return relation;
}

@end

@implementation NSObject (BadgeValueObjectRelation)

- (ORCountObjectRelation *)badgeValueObjectRelation{
    return nil;
}

@end

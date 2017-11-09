//
//  RootViewController.m
//  ORObjectRelationDemo
//
//  Created by Jave on 2017/7/24.
//  Copyright © 2017年 xulinfeng. All rights reserved.
//

#import "RootViewController.h"
#import "ORBadgeValueManager.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    ORBadgeValueManager *manager = [ORBadgeValueManager sharedManager];
    
    NSError *error = nil;
    [self observeRelation:[manager messageObjectRelation] countPicker:^(id relation, NSUInteger count) {
        self.tabBar.items[0].badgeValue = @(count).stringValue;
    } error:&error];
    
    [self observeRelation:[manager homeObjectRelation] countPicker:^(id relation, NSUInteger count) {
        self.tabBar.items[1].badgeValue = @(count).stringValue;
    } error:&error];
}

@end

//
//  ViewController.m
//  ORObjectRelationDemo
//
//  Created by xulinfeng on 2017/1/17.
//  Copyright © 2017年 xulinfeng. All rights reserved.
//

#import "ViewController.h"
#import "ORBadgeValueManager.h"

@interface ViewController ()

@property (nonatomic, strong) UIBarButtonItem *rootBarButtonItem;

@property (nonatomic, strong) UIBarButtonItem *randomBarButtonItem;

@end

@implementation ViewController

- (void)loadView{
    [super loadView];
    
    self.navigationItem.leftBarButtonItems = @[[self rootBarButtonItem]];
    self.navigationItem.rightBarButtonItem = [self randomBarButtonItem];
    
    self.tableView.rowHeight = 44;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    ORBadgeValueManager *manager = [ORBadgeValueManager sharedManager];
    NSError *error = nil;
    [self observeRelation:[manager rootObjectRelation] countPicker:^(id relation, NSUInteger count) {
        self.rootBarButtonItem.title = [NSString stringWithFormat:@"总共: %@", @(count).stringValue];
    } error:&error];
}

- (UIBarButtonItem *)rootBarButtonItem{
    if (!_rootBarButtonItem) {
        _rootBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"总共: 0" style:UIBarButtonItemStyleDone target:self action:@selector(didClickRoot:)];
    }
    return _rootBarButtonItem;
}

- (UIBarButtonItem *)randomBarButtonItem{
    if (!_randomBarButtonItem) {
        _randomBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"random" style:UIBarButtonItemStyleDone target:self action:@selector(didClickRandom:)];
    }
    return _randomBarButtonItem;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    } else {
        [cell removeAllObservers];
    }
    NSString *key = @(indexPath.row).stringValue;
    
    cell.textLabel.text = key;
    
    ORCountObjectRelation *relation = [[ORBadgeValueManager sharedManager] normalMessageObjectRelationWithChatID:key];
    NSError *error = nil;
    [cell observeRelation:relation countPicker:^(id relation, NSUInteger count) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  点击清楚", @(count).stringValue];
    } error:&error];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *key = @(indexPath.row).stringValue;
    ORCountObjectRelation *relation = [[ORBadgeValueManager sharedManager] normalMessageObjectRelationWithChatID:key];
    [relation clean];
}

#pragma mark - actions

- (IBAction)didClickRoot:(id)sender{
    
    ORBadgeValueManager *manager = [ORBadgeValueManager sharedManager];
    
    [[manager rootObjectRelation] clean];
}

- (IBAction)didClickHome:(id)sender{
    
    ORBadgeValueManager *manager = [ORBadgeValueManager sharedManager];
    
    [[manager homeObjectRelation] clean];
}

- (IBAction)didClickMessages:(id)sender{
    
    ORBadgeValueManager *manager = [ORBadgeValueManager sharedManager];
    
    [[manager messageObjectRelation] clean];
}

- (IBAction)didClickRandom:(id)sender{
    
    ORBadgeValueManager *manager = [ORBadgeValueManager sharedManager];
    
    NSString *key = @(arc4random() % 10).stringValue;
    
    ORCountObjectRelation *relation = [manager normalMessageObjectRelationWithChatID:key];
    
    relation.count++;
    
    ORCountObjectRelation *homeRelation = [manager homeObjectRelation];
    
    homeRelation.count += (arc4random() % 5);
}

@end

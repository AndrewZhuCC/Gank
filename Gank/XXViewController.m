//
//  XXViewController.m
//  Gank
//
//  Created by 朱安智 on 16/6/27.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "XXViewController.h"
#import "XXTableViewCell.h"
#import "GankResult.h"

#import <Masonry/Masonry.h>

@interface XXViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<GankResult *> *entitys;
@end

@implementation XXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *tableview = [[UITableView alloc]init];
    self.tableView = tableview;
    [self.tableView registerClass:XXTableViewCell.class forCellReuseIdentifier:NSStringFromClass(XXTableViewCell.class)];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.entitys = NSMutableArray.new;
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.entitys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XXTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(XXTableViewCell.class)];
    [cell configureCellWithEntity:self.entitys[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    return [cell heightOfCell];
}

@end

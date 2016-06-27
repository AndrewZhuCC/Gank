//
//  XXViewController.m
//  Gank
//
//  Created by 朱安智 on 16/6/27.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "XXViewController.h"
#import <Masonry/Masonry.h>

@interface XXViewController ()
@property (weak, nonatomic) UITableView *tableView;
@end

@implementation XXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *tableview = [[UITableView alloc]init];
    self.tableView = tableview;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

@end

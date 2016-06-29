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
#import "GankResponse.h"

#import <Masonry/Masonry.h>
#import <AFNetworking/AFNetworking.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import <MJRefresh/MJRefresh.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface XXViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<GankResult *> *entitys;
@property (assign, nonatomic) NSInteger page;
@property (strong, nonatomic) NSURLSessionDataTask *task;
@end

@implementation XXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.entitys = NSMutableArray.new;
    self.page = 1;
//    [self getEntitysFromNet];
    [self configureTableView];
}

- (void)getEntitysFromNet {
    if (self.entitys.count == 0) {
        [SVProgressHUD show];
    }
    NSURLComponents *urlComponets = NSURLComponents.new;
    urlComponets.scheme = @"http";
    urlComponets.host = @"gank.io";
    urlComponets.path = [NSString stringWithFormat:@"/api/data/福利/10/%@", @(self.page)];
    NSLog(@"Start get entity with page:%@", @(self.page));
    [AFHTTPSessionManager.manager GET:urlComponets.string
                           parameters:nil
                             progress:^(NSProgress * _Nonnull downloadProgress) {
                                 NSLog(@"download description:%@", downloadProgress.localizedDescription);
                                 NSLog(@"download additional description:%@", downloadProgress.localizedAdditionalDescription);
                             }
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  [self.tableView.mj_footer endRefreshing];
                                  [SVProgressHUD dismiss];
                                  GankResponse *response = [[GankResponse alloc] initWithResponse:responseObject];
                                  NSArray *entitys = [response resultFromResponse];
                                  if (entitys) {
                                      [_entitys addObjectsFromArray:entitys];
                                      _page ++;
                                      [self.tableView reloadData];
                                  } else {
                                      NSLog(@"empty entitys: %@", responseObject);
                                  }
                              }
                              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                  [self.tableView.mj_footer endRefreshing];
                                  [SVProgressHUD dismiss];
                                  NSLog(@"get error:%@", error);
                                  if (error.code != -999) {
                                      [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                          [SVProgressHUD dismiss];
                                      });
                                  }
                              }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.entitys.count == 0) {
        [self.tableView.mj_footer beginRefreshing];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.task.state == NSURLSessionTaskStateRunning) {
        [self.task cancel];
        self.task = nil;
        [self.tableView.mj_footer endRefreshing];
    }
    
    [SVProgressHUD dismiss];
}

#pragma mark - TableView

- (void)configureTableView {
    UITableView *tableview = [[UITableView alloc]init];
    self.tableView = tableview;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:XXTableViewCell.class forCellReuseIdentifier:NSStringFromClass(XXTableViewCell.class)];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getEntitysFromNet)];
    [self.tableView.mj_footer beginRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.entitys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XXTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(XXTableViewCell.class) forIndexPath:indexPath];
    [cell configureCellWithEntity:self.entitys[indexPath.row] completionBlock:^{
        NSArray *visible = [tableView visibleCells];
        if ([visible containsObject:cell]) {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GankResult *entity = self.entitys[indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:NSStringFromClass(XXTableViewCell.class) configuration:^(id cell) {
        XXTableViewCell *mycell = (XXTableViewCell *)cell;
        [mycell configureTemplateWithEntity:entity];
    }];
}

@end

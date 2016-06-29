//
//  DailyViewController.m
//  Gank
//
//  Created by 朱安智 on 16/6/29.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "DailyViewController.h"
#import "GankResponse.h"
#import "ResourcesTableViewCell.h"
#import "WebViewController.h"

#import <Masonry/Masonry.h>
#import <AFNetworking/AFNetworking.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import <MJRefresh/MJRefresh.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface DailyViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<GankDaily *> *entitys;
@property (assign, nonatomic) NSInteger page;
@property (strong, nonatomic) NSURLSessionDataTask *task;
@end

@implementation DailyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.entitys = NSMutableArray.new;
    self.page = 1;
    
    [self configureTableView];
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

- (void)getEntitysFromNet {
    if (self.entitys.count == 0) {
        [SVProgressHUD show];
    }
    NSURLComponents *urlComponets = NSURLComponents.new;
    urlComponets.scheme = @"http";
    urlComponets.host = @"gank.io";
    urlComponets.path = [NSString stringWithFormat:@"/api/history/content/10/%@", @(self.page)];
    NSLog(@"Start get daily entity with page:%@", @(self.page));
    [AFHTTPSessionManager.manager GET:urlComponets.string
                           parameters:nil
                             progress:^(NSProgress * _Nonnull downloadProgress) {
                                 NSLog(@"download additional description:%@", downloadProgress.localizedAdditionalDescription);
                             }
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  [self.tableView.mj_footer endRefreshing];
                                  [SVProgressHUD dismiss];
                                  GankResponse *response = [[GankResponse alloc] initWithResponse:responseObject];
                                  NSArray *entitys = [response resultOfDaily];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView

- (void)configureTableView {
    UITableView *tableview = [[UITableView alloc]init];
    self.tableView = tableview;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:ResourcesTableViewCell.class forCellReuseIdentifier:NSStringFromClass(ResourcesTableViewCell.class)];
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
    ResourcesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ResourcesTableViewCell.class) forIndexPath:indexPath];
    GankDaily *entity = self.entitys[indexPath.row];
    [cell configureCellWIthDailyEntity:entity];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GankDaily *entity = self.entitys[indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:NSStringFromClass(ResourcesTableViewCell.class) configuration:^(id cell) {
        ResourcesTableViewCell *mycell = (ResourcesTableViewCell *)cell;
        [mycell configureCellWIthDailyEntity:entity];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GankDaily *entity = self.entitys[indexPath.row];
    if (entity.content.length > 0) {
        WebViewController *webVC = WebViewController.new;
        webVC.htmlToLoad = entity.content;
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

@end

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
#import "XXTableViewCell.h"
#import "WebViewController.h"
#import "NetwokManager.h"
#import "FullScreenImageViewer.h"

#import <Masonry/Masonry.h>
#import <AFNetworking/AFNetworking.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import <MJRefresh/MJRefresh.h>
#import "MBProgressHUD.h"

@interface DailyViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MBProgressHUD *hud;

@property (strong, nonatomic) GankDaily *entity;
@property (strong, nonatomic) NSURLSessionDataTask *task;
@property (strong, nonatomic) NSArray *days;

@property (assign, nonatomic) BOOL canUpdate;
@property (assign, nonatomic) NSInteger page;

@end

@implementation DailyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.page = 0;
    
    [self configureTableView];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.8 alpha:0.7]];
    [self.view setBackgroundColor:UIColorFromRGB_A(0x00f5ff, 1)];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [self.hud setRemoveFromSuperViewOnHide:NO];
    [self.hud hide:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.entity) {
        [self.tableView.mj_footer beginRefreshing];
    }
    
    if (!self.days) {
        self.hud.mode = MBProgressHUDModeIndeterminate;
        self.hud.labelText = nil;
        self.hud.detailsLabelText = nil;
        [self.hud show:YES];
        [NetwokManager daysOfHistoryWithBlock:^(NSArray *result, NSError *error) {
            if (error) {
                self.hud.mode = MBProgressHUDModeText;
                self.hud.labelText = error.domain;
                self.hud.detailsLabelText = error.localizedDescription;
                [self.hud show:YES];
                [self.hud hide:YES afterDelay:3];
            } else {
                self.days = result;
                self.canUpdate = YES;
                [self.tableView.mj_footer beginRefreshing];
            }
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.task.state == NSURLSessionTaskStateRunning) {
        [self.task cancel];
        self.task = nil;
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
    }
    
    [self.hud hide:NO];
}

- (void)commonNetworks {
    if (!self.entity) {
        self.hud.mode = MBProgressHUDModeDeterminate;
        self.hud.progress = 0;
        self.hud.labelText = nil;
        self.hud.detailsLabelText = nil;
        [self.hud show:YES];
    }
    NSString *urlss = [NSString stringWithFormat:@"http://gank.io/api/day/%@", self.days[self.page]];
    NSLog(@"Start get daily entity with page:%@", @(self.page));
    [AFHTTPSessionManager.manager GET:urlss
                           parameters:nil
                             progress:^(NSProgress * _Nonnull downloadProgress) {
                                 NSLog(@"daily progress:%@", downloadProgress.localizedAdditionalDescription);
                                 if (!self.entity) {
                                     self.hud.progress = (downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                                 }
                             }
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  [self.tableView.mj_footer endRefreshing];
                                  [self.tableView.mj_header endRefreshing];
                                  [self.hud hide:YES];
                                  GankResponse *response = [[GankResponse alloc] initWithResponse:responseObject];
                                  self.entity = [response resultOfDaily];
                                  self.navigationItem.title = self.days[self.page];
                                  self.page ++;
                                  [self.tableView reloadData];
                                  [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                              }
                              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                  [self.tableView.mj_footer endRefreshing];
                                  [self.tableView.mj_header endRefreshing];
                                  [self.hud hide:YES];
                                  NSLog(@"get error:%@", error);
                                  if (error.code != -999) {
                                      self.hud.mode = MBProgressHUDModeText;
                                      self.hud.labelText = error.domain;
                                      self.hud.detailsLabelText = error.localizedDescription;
                                      [self.hud show:YES];
                                      [self.hud hide:YES afterDelay:3];
                                  }
                              }];
}

- (void)getEntitysFromNet {
    
    if (!self.canUpdate) {
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    
    if (self.page > self.days.count - 1) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        return;
    }
    
    [self commonNetworks];
}

- (void)getFormerEntity {
    if (!self.canUpdate) {
        [self.tableView.mj_header endRefreshing];
        return;
    }
    
    if (self.page == 1) {
        [self.tableView.mj_header endRefreshing];
        return;
    }
    
    self.page --;
    self.page --;
    
    [self commonNetworks];
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
    [self.tableView registerClass:XXTableViewCell.class forCellReuseIdentifier:NSStringFromClass(XXTableViewCell.class)];
    [self.tableView registerClass:ResourcesTableViewCell.class forCellReuseIdentifier:NSStringFromClass(ResourcesTableViewCell.class)];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.sectionHeaderHeight = 30;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getEntitysFromNet)];
    [self.tableView.mj_footer beginRefreshing];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getFormerEntity)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.entity.category.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary<NSString *, NSArray*> *result = self.entity.results;
    NSArray *category = self.entity.category;
    return [result objectForKey:category[section]].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    NSString *key = self.entity.category[indexPath.section];
    GankResult *xxentity = [self.entity.results objectForKey:key][indexPath.row];
    if ([self.entity.category[indexPath.section] isEqualToString:@"福利"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(XXTableViewCell.class) forIndexPath:indexPath];
        [(XXTableViewCell *)cell configureCellWithEntity:xxentity completionBlock:^{
            NSArray *visible = [tableView visibleCells];
            if ([visible containsObject:cell]) {
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ResourcesTableViewCell.class) forIndexPath:indexPath];
        [(ResourcesTableViewCell *)cell configureCellWithEntity:xxentity];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = self.entity.category[indexPath.section];
    GankResult *xxentity = [self.entity.results objectForKey:key][indexPath.row];
    if ([self.entity.category[indexPath.section] isEqualToString:@"福利"]) {
        return [tableView fd_heightForCellWithIdentifier:NSStringFromClass(XXTableViewCell.class) configuration:^(id cell) {
            XXTableViewCell *mycell = (XXTableViewCell *)cell;
            [mycell configureTemplateWithEntity:xxentity];
        }];
    } else {
        return [tableView fd_heightForCellWithIdentifier:NSStringFromClass(ResourcesTableViewCell.class) configuration:^(id cell) {
            ResourcesTableViewCell *mycell = (ResourcesTableViewCell *)cell;
            [mycell configureCellWithEntity:xxentity];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.entity.category[indexPath.section] isEqualToString:@"福利"]) {
        XXTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        CGRect rect = [cell.imgView.superview convertRect:cell.imgView.frame toView:[UIApplication sharedApplication].keyWindow];
        [FullScreenImageViewer showImageFromRect:rect image:cell.imgView.image];
        return;
    }
    NSString *key = self.entity.category[indexPath.section];
    GankResult *entity = [self.entity.results objectForKey:key][indexPath.row];
    WebViewController *webVC = WebViewController.new;
    webVC.urlToLoad = entity.url;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    UILabel *label = [[UILabel alloc] init];
    label.text = self.entity.category[section];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentLeft;
    [header addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(header).with.offset(10);
        make.centerY.equalTo(header.mas_centerY);
    }];
    return header;
}

@end

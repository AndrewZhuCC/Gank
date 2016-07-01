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
#import "CoreDataManager.h"
#import "FullScreenImageViewer.h"

#import <Masonry/Masonry.h>
#import <AFNetworking/AFNetworking.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import <MJRefresh/MJRefresh.h>
#import "MBProgressHUD.h"

@interface XXViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MBProgressHUD *hud;

@property (strong, nonatomic) NSMutableArray<GankResult *> *entitys;
@property (strong, nonatomic) NSURLSessionDataTask *task;
@property (assign, nonatomic) NSInteger page;
@end

@implementation XXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.entitys = NSMutableArray.new;
    self.page = 1;
//    [self getEntitysFromNet];
    [self configureTableView];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithRed:1 green:0.5 blue:0 alpha:0.7]];
    self.navigationController.navigationBar.hidden = YES;
    [self.view setBackgroundColor:[UIColor colorWithRed:1 green:0.5 blue:0 alpha:0.7]];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud setRemoveFromSuperViewOnHide:NO];
    [self.hud hide:NO];
}

- (void)getEntitysFromNet {
    if (self.entitys.count == 0) {
        self.hud.mode = MBProgressHUDModeDeterminate;
        self.hud.progress = 0;
        self.hud.labelText = nil;
        self.hud.detailsLabelText = nil;
        [self.hud show:YES];
    }
    NSURLComponents *urlComponets = NSURLComponents.new;
    urlComponets.scheme = @"http";
    urlComponets.host = @"gank.io";
    urlComponets.path = [NSString stringWithFormat:@"/api/data/福利/10/%@", @(self.page)];
    NSLog(@"Start get entity with page:%@", @(self.page));
    [AFHTTPSessionManager.manager GET:urlComponets.string
                           parameters:nil
                             progress:^(NSProgress * _Nonnull downloadProgress) {
                                 if (self.entitys.count == 0) {
                                     self.hud.progress = (downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                                 }
                                 NSLog(@"ooxx progress:%@", downloadProgress.localizedAdditionalDescription);
                             }
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  [self.tableView.mj_footer endRefreshing];
                                  [self.hud hide:YES];
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
    
    [self.hud hide:NO];
}

#pragma mark - TableView

- (void)configureTableView {
    UITableView *tableview = [[UITableView alloc]init];
    self.tableView = tableview;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:XXTableViewCell.class forCellReuseIdentifier:NSStringFromClass(XXTableViewCell.class)];
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    [cell setCollectionButtonAction:^GankResult *(UIButton *button) {
        GankResult *entity = [self.entitys objectAtIndex:indexPath.row];
        GankResult *dbentity = [CoreDataManager entityByID:entity._id];
        if (dbentity) {
            [CoreDataManager removeGankResultFromDB:entity];
        } else {
            [CoreDataManager insertGankResultToDB:entity];
        }
        return entity;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XXTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    CGRect rect = [cell.imgView.superview convertRect:cell.imgView.frame toView:[UIApplication sharedApplication].keyWindow];
    [FullScreenImageViewer showImageFromRect:rect image:cell.imgView.image];
}

@end

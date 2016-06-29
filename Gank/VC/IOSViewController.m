//
//  IOSViewController.m
//  Gank
//
//  Created by 朱安智 on 16/6/28.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "IOSViewController.h"
#import "GankResponse.h"
#import "IOSTableViewCell.h"
#import "WebViewController.h"

#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>
#import <AFNetworking/AFNetworking.h>
#import <UITableView+FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <IGLDropDownMenu/IGLDropDownMenu.h>

typedef NS_ENUM(NSUInteger, Resource_Type) {
    Resource_Type_IOS = 0,
    Resource_Type_Android,
    Resource_Type_Foreground,
    Resource_Type_Vedios,
    Resource_Type_Others,
};

@interface UINavigationBar (HitTest)

@end

@implementation UINavigationBar (HitTest)

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subview in self.subviews) {
            CGPoint pt = [subview convertPoint:point fromView:self];
            UIView *hitResult = [subview hitTest:pt withEvent:event];
            if (hitResult) {
                view = hitResult;
                break;
            }
        }
    }
    return view;
}

@end

@interface IOSViewController () <UITableViewDelegate, UITableViewDataSource, IGLDropDownMenuDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) NSInteger page;
@property (strong, nonatomic) NSMutableArray<GankResult *> *entitys;
@property (strong, nonatomic) NSURLSessionDataTask *task;
@property (strong, nonatomic) NSArray *urls;
@property (strong, nonatomic) NSString *currentUrl;
@property (strong, nonatomic) IGLDropDownMenu *menu;
@end

@implementation IOSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.page = 1;
    self.entitys = NSMutableArray.new;
    self.view.backgroundColor = [UIColor whiteColor];
    self.currentUrl = self.urls[0];
    [self configureDropdownMenu];
    [self configureTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getEntityFromNet {
    if (self.entitys.count == 0) {
        [SVProgressHUD show];
    }
    self.task = [AFHTTPSessionManager.manager GET:[NSString stringWithFormat:@"%@%@", self.currentUrl, @(self.page)] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"ios progress:%@", [downloadProgress localizedAdditionalDescription]);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.tableView.mj_footer endRefreshing];
        [SVProgressHUD dismiss];
        GankResponse *response = [[GankResponse alloc] initWithResponse:responseObject];
        NSArray *results = [response resultFromResponse];
        if (results) {
            [self.entitys addObjectsFromArray:results];
            [self.tableView reloadData];
            self.page ++;
        } else {
            NSLog(@"Empty results from ios:%@", responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableView.mj_footer endRefreshing];
        [SVProgressHUD dismiss];
        NSLog(@"get result from ios error:%@", error);
        if (error.code != -999) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }
    }];
}

- (NSArray *)urls {
    if (!_urls) {
        _urls = @[@"http://gank.io/api/data/iOS/20/", @"http://gank.io/api/data/Android/20/", @"http://gank.io/api/data/%E5%89%8D%E7%AB%AF/20/", @"http://gank.io/api/data/%E4%BC%91%E6%81%AF%E8%A7%86%E9%A2%91/20/", @"http://gank.io/api/data/%E6%8B%93%E5%B1%95%E8%B5%84%E6%BA%90/20/"];
    }
    return _urls;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.entitys.count == 0) {
        [self.tableView.mj_footer beginRefreshing];
    }
    [self.menu setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.task.state == NSURLSessionTaskStateRunning) {
        [self.task cancel];
        self.task = nil;
        [self.tableView.mj_footer endRefreshing];
    }
    [SVProgressHUD dismiss];
    [self.menu setHidden:YES];
}

#pragma mark - DropDown Menu

- (void)configureDropdownMenu {
    self.menu = [[IGLDropDownMenu alloc]init];
    NSArray *names = @[@"iOS", @"Android", @"前端", @"休息视频", @"拓展资源"];
    NSMutableArray *items = NSMutableArray.new;
    for (NSString *name in names) {
        IGLDropDownItem *item = IGLDropDownItem.new;
        [item setText:name];
        [items addObject:item];
    }
    [self.menu setDropDownItems:[items copy]];
    [self.menu setFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width / 2.0 - 50, 0, 100, 40)];
    self.menu.paddingLeft = 15;
    self.menu.menuText = @"Resources";
    self.menu.type =  IGLDropDownMenuTypeSlidingInBoth;
    self.menu.gutterY = 5;
    self.menu.useSpringAnimation = NO;
    self.menu.itemAnimationDelay = 0.1;
    self.menu.rotate = IGLDropDownMenuRotateRandom;
    self.menu.delegate = self;
    [self.navigationController.navigationBar addSubview:self.menu];
    [self.menu reloadView];
    [self.menu selectItemAtIndex:0];
}

- (void)dropDownMenu:(IGLDropDownMenu *)dropDownMenu expandingChanged:(BOOL)isExpending {
    self.tableView.userInteractionEnabled = !isExpending;
}

- (void)dropDownMenu:(IGLDropDownMenu *)dropDownMenu selectedItemAtIndex:(NSInteger)index {
    if (![self.currentUrl isEqualToString:self.urls[index]]) {
        self.currentUrl = self.urls[index];
        self.page = 1;
        [self.entitys removeAllObjects];
        [self.tableView reloadData];
        [self.tableView.mj_footer beginRefreshing];
    }
}

#pragma mark - TableView

- (void)configureTableView {
    self.tableView = UITableView.new;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    Class ios = IOSTableViewCell.class;
    [self.tableView registerClass:ios forCellReuseIdentifier:NSStringFromClass(ios)];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getEntityFromNet)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.entitys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IOSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(IOSTableViewCell.class) forIndexPath:indexPath];
    GankResult *entity = self.entitys[indexPath.row];
    [cell configureCellWithEntity:entity];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    GankResult *entity = self.entitys[indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:NSStringFromClass(IOSTableViewCell.class) configuration:^(id cell) {
        IOSTableViewCell *mycell = cell;
        [mycell configureCellWithEntity:entity];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GankResult *entity = self.entitys[indexPath.row];
    if (entity.url) {
        WebViewController *webVC = WebViewController.new;
        webVC.urlToLoad = entity.url;
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

@end

//
//  MainTabBarController.m
//  Gank
//
//  Created by 朱安智 on 16/6/27.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "MainTabBarController.h"
#import "XXViewController.h"
#import "ResourcesViewController.h"
#import "WebViewController.h"
#import "DailyViewController.h"

@interface MainTabBarController () <UITabBarControllerDelegate>
@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViewControllers];
}

- (void)setupViewControllers {
    NSMutableArray *vcs = NSMutableArray.new;
    NSInteger tag = 0;
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]} forState:UIControlStateHighlighted];
    
    XXViewController *vc = XXViewController.new;
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"Gank"] tag:++tag];
    nvc.tabBarItem = item;
    [vcs addObject:nvc];
    
    ResourcesViewController *ivc = ResourcesViewController .new;
    UINavigationController *invc = [[UINavigationController alloc]initWithRootViewController:ivc];
    UITabBarItem *iitem = [[UITabBarItem alloc]initWithTitle:nil image:[UIImage imageNamed:@"iOS"] tag:++tag];
    invc.tabBarItem = iitem;
    [vcs addObject:invc];
    
    DailyViewController *dvc = DailyViewController.new;
    UINavigationController *dnvc = [[UINavigationController alloc] initWithRootViewController:dvc];
    UITabBarItem *ditem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"Daily"] tag:++tag];
    dnvc.tabBarItem = ditem;
    [vcs addObject:dnvc];
    
    self.viewControllers = vcs;
    self.delegate = self;
}

@end

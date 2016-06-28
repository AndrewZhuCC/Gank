//
//  MainTabBarController.m
//  Gank
//
//  Created by 朱安智 on 16/6/27.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "MainTabBarController.h"
#import "XXViewController.h"

@interface MainTabBarController () <UITabBarControllerDelegate>
@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViewControllers];
}

- (void)setupViewControllers {
    XXViewController *vc = [XXViewController new];
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"XX" image:nil tag:0];
    vc.tabBarItem = item;
    self.viewControllers = @[nvc];
    self.delegate = self;
    self.tabBar.tintColor = [UIColor blackColor];
}

@end

//
//  XXTableViewCell.h
//  Gank
//
//  Created by 朱安智 on 16/6/28.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GankResult;

typedef GankResult *(^ButtonCollectionAction)(UIButton *button);

@interface XXTableViewCell : UITableViewCell
@property (readonly, strong, nonatomic) UIImageView *imgView;
- (void)configureCellWithEntity:(GankResult *)entity completionBlock:(void(^)())completion;
- (void)configureTemplateWithEntity:(GankResult *)entity;
- (void)setCollectionButtonAction:(ButtonCollectionAction)action;
@end

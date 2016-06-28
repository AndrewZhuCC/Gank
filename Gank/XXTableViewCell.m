//
//  XXTableViewCell.m
//  Gank
//
//  Created by 朱安智 on 16/6/28.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "XXTableViewCell.h"
#import "GankResult.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>

@interface XXTableViewCell ()
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel *lbAuthor;
@end

@implementation XXTableViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    UIView *contentView = self.contentView;
    
    _imgView = UIImageView.new;
    [contentView addSubview:_imgView];
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView).with.insets(UIEdgeInsetsMake(5, 5, 5, 5));
    }];
    
    _lbAuthor = UILabel.new;
    [_lbAuthor setBackgroundColor:[UIColor clearColor]];
    [_lbAuthor setTextColor:[UIColor lightGrayColor]];
    [contentView addSubview:_lbAuthor];
    [_lbAuthor mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(contentView.mas_right).with.offset(-8);
        make.bottom.equalTo(contentView.mas_bottom).with.offset(-8);
    }];
}

- (void)configureCellWithEntity:(GankResult *)entity {
    [self.imgView sd_setImageWithURL:entity.url placeholderImage:nil];
}

- (CGFloat)heightOfCell {
    return self.imgView.image.size.height + 10;
}

@end

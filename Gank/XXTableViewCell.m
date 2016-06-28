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
@property (assign, nonatomic) BOOL template;

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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    UIView *contentView = self.contentView;
    
    contentView.backgroundColor = [UIColor clearColor];
    _imgView = UIImageView.new;
    [contentView addSubview:_imgView];
    
    _lbAuthor = UILabel.new;
    [_lbAuthor setBackgroundColor:[UIColor clearColor]];
    [_lbAuthor setTextColor:[UIColor lightGrayColor]];
    [contentView addSubview:_lbAuthor];
}

- (void)prepareForReuse {
    self.imgView.image = nil;
    [super prepareForReuse];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    CGFloat imgHeight = 40;
    if (self.imgView.image) {
        CGFloat scale = (UIScreen.mainScreen.bounds.size.width - 16 - 10) / self.imgView.image.size.width;
        imgHeight = round(self.imgView.image.size.height * scale);
    }
    [_imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.template) {
            make.height.equalTo(@(imgHeight));
            self.template = NO;
        }
        make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(5, 5, 5, 5));
    }];
    
    [_lbAuthor mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-8);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-8);
    }];
    
    [super updateConstraints];
}

- (void)configureCellWithEntity:(GankResult *)entity completionBlock:(void(^)())completion {
    [self.lbAuthor setText:entity.who];
    __weak typeof(self) wself = self;
    [self.imgView sd_setImageWithURL:entity.url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        typeof(wself) sself = wself;
        if (image && sself) {
            sself.imgView.image = image;
            [sself updateConstraints];
            if (completion) {
                completion();
            }
        } else {
            NSLog(@"error:%@", error);
        }
    }];
}

- (void)configureTemplateWithEntity:(GankResult *)entity {
    [self.lbAuthor setText:entity.who];
    __weak typeof(self) wself = self;
    [self.imgView sd_setImageWithURL:entity.url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        typeof(wself) sself = wself;
        if (image && sself) {
            sself.imgView.image = image;
            sself.template = YES;
            [sself updateConstraints];
        } else {
            NSLog(@"error:%@", error);
        }
    }];
}

- (CGFloat)heightOfCell {
    return self.imgView.image.size.height + 10;
}

@end

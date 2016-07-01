//
//  XXTableViewCell.m
//  Gank
//
//  Created by 朱安智 on 16/6/28.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "XXTableViewCell.h"
#import "GankResult.h"
#import "CoreDataManager.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>

@interface XXTableViewCell ()
@property (readwrite, strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel *lbAuthor;
@property (strong, nonatomic) UIButton *btnCollection;

@property (assign, nonatomic) BOOL template;
@property (copy, nonatomic) ButtonCollectionAction collectionAction;

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
    self.backgroundColor = [UIColor clearColor];
    _imgView = UIImageView.new;
    [contentView addSubview:_imgView];
    
    _lbAuthor = UILabel.new;
    [_lbAuthor setBackgroundColor:[UIColor clearColor]];
    [_lbAuthor setTextColor:[UIColor lightGrayColor]];
    [contentView addSubview:_lbAuthor];
    
    _btnCollection = UIButton.new;
    [_btnCollection setBackgroundImage:[UIImage imageNamed:@"uncollected"] forState:UIControlStateNormal];
    [_btnCollection addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:_btnCollection];
}

- (void)buttonAction:(UIButton *)sender {
    if (self.collectionAction) {
        GankResult *entity = self.collectionAction(sender);
        [self refreshButtonImgWithEntity:entity];
    }
}

#pragma mark - AutoLayout

- (void)prepareForReuse {
    self.imgView.image = nil;
    self.collectionAction = nil;
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
    
    [_btnCollection mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imgView.mas_left).with.offset(8);
        make.bottom.equalTo(_imgView.mas_bottom).with.offset(-8);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [super updateConstraints];
}

- (void)refreshButtonImgWithEntity:(GankResult *)entity {
    if (!entity) {
        return;
    }
    
    GankResult *dbentity = [CoreDataManager entityByID:entity._id];
    if (dbentity) {
        [self.btnCollection setBackgroundImage:[UIImage imageNamed:@"collected"] forState:UIControlStateNormal];
    } else {
        [self.btnCollection setBackgroundImage:[UIImage imageNamed:@"uncollected"] forState:UIControlStateNormal];
    }
}

#pragma Public Methods

- (void)configureCellWithEntity:(GankResult *)entity completionBlock:(void(^)())completion {
    [self.lbAuthor setText:entity.who];
    [self refreshButtonImgWithEntity:entity];
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

- (void)setCollectionButtonAction:(ButtonCollectionAction)action {
    if (action) {
        self.collectionAction = action;
    }
}

@end

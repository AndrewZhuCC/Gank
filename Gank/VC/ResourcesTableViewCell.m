//
//  ResourcesTableViewCell.m
//  Gank
//
//  Created by 朱安智 on 16/6/28.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "ResourcesTableViewCell.h"
#import "GankResult.h"
#import "GankDaily.h"

#import <Masonry/Masonry.h>

@interface ResourcesTableViewCell ()
@property (strong, nonatomic) UILabel *lbDesc;
@property (strong, nonatomic) UILabel *lbWho;
@end

@implementation ResourcesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _lbDesc = UILabel.new;
        _lbWho = UILabel.new;
        _lbWho.textAlignment = NSTextAlignmentRight;
        _lbWho.font = [UIFont systemFontOfSize:12];
        _lbWho.textColor = [UIColor grayColor];
        _lbDesc.numberOfLines = 0;
        _lbDesc.font = [UIFont systemFontOfSize:17];
        _lbDesc.textColor = [UIColor blackColor];
        _lbWho.backgroundColor = [UIColor clearColor];
        _lbDesc.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lbDesc];
        [self.contentView addSubview:_lbWho];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    UIView *contentView = self.contentView;
    [self.lbDesc mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView.mas_top).with.offset(8);
        make.left.equalTo(contentView.mas_left).with.offset(8);
        make.right.equalTo(contentView.mas_right).with.offset(-8);
        make.bottom.equalTo(self.lbWho.mas_top).with.offset(-8);
    }];
    [self.lbWho mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(contentView.mas_right).with.offset(-5);
        make.bottom.equalTo(contentView.mas_bottom).with.offset(-8);
    }];
    
    [super updateConstraints];
}

- (void)configureCellWithEntity:(GankResult *)entity {
    self.lbDesc.text = entity.desc;
    self.lbWho.text = [NSString stringWithFormat:@"-- %@", entity.who];
}

- (void)configureCellWIthDailyEntity:(GankDaily *)entity {
    self.lbWho.text = entity.timeStamp;
}

@end

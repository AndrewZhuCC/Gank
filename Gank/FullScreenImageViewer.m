//
//  FullScreenImageViewer.m
//  Gank
//
//  Created by 朱安智 on 16/7/1.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "FullScreenImageViewer.h"

#import <Masonry/Masonry.h>

@interface FullScreenImageViewer ()

@property (assign, nonatomic) CGRect originRect;
@property (weak, nonatomic) UIView *imageView;

@end

@implementation FullScreenImageViewer

+ (FullScreenImageViewer *)showImageFromRect:(CGRect)rect image:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    FullScreenImageViewer *view = [[FullScreenImageViewer alloc]initWithFrame:[UIScreen mainScreen].bounds];
    view.originRect = rect;
    
    [view addSubview:imageView];
    view.imageView = imageView;
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(view.mas_left);
        make.right.lessThanOrEqualTo(view.mas_right);
        make.top.greaterThanOrEqualTo(view.mas_top);
        make.bottom.lessThanOrEqualTo(view.mas_bottom);
        make.center.equalTo(view);
        make.width.equalTo(imageView.mas_height).multipliedBy(image.size.width / image.size.height);
    }];
    
    UIButton *hideButton = UIButton.new;
    [hideButton addTarget:view action:@selector(hideButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:hideButton];
    
    [hideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    view.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect currentImageRect = imageView.frame;
        imageView.frame = rect;
        view.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
            imageView.frame = currentImageRect;
        }];
    });
    
    return view;
}

- (void)hideButtonTapped:(UIButton *)button {
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        self.imageView.frame = self.originRect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end

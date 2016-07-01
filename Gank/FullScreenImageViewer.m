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
@property (assign, nonatomic) CGAffineTransform originTransform;
@property (assign, nonatomic) CGPoint originCenter;
@property (copy, nonatomic) ToRectBlock toRectBlock;

@property (weak, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGr;
@property (strong, nonatomic) UIPanGestureRecognizer *panGr;
@property (strong, nonatomic) UITapGestureRecognizer *tapGr;

@end

@implementation FullScreenImageViewer

+ (FullScreenImageViewer *)showImageFromRect:(CGRect)rect image:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    FullScreenImageViewer *view = [[FullScreenImageViewer alloc]initWithFrame:[UIScreen mainScreen].bounds];
    view.originRect = rect;
    
    UIButton *hideButton = UIButton.new;
    [hideButton addTarget:view action:@selector(hideButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:hideButton];
    
    [view addSubview:imageView];
    view.imageView = imageView;
    imageView.userInteractionEnabled = YES;
    
    view.pinchGr = [[UIPinchGestureRecognizer alloc]initWithTarget:view action:@selector(pinchRecognized:)];
    view.panGr = [[UIPanGestureRecognizer alloc] initWithTarget:view action:@selector(panRecognized:)];
    view.tapGr = [[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(tapRecognized:)];
    [imageView addGestureRecognizer:view.pinchGr];
    [imageView addGestureRecognizer:view.panGr];
    [imageView addGestureRecognizer:view.tapGr];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(view.mas_left);
        make.right.lessThanOrEqualTo(view.mas_right);
        make.top.greaterThanOrEqualTo(view.mas_top);
        make.bottom.lessThanOrEqualTo(view.mas_bottom);
        make.center.equalTo(view);
        make.width.equalTo(imageView.mas_height).multipliedBy(image.size.width / image.size.height);
    }];
    
    [hideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    view.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo([UIApplication sharedApplication].keyWindow);
    }];
    
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
    __block CGRect rect = CGRectNull;
    if (self.toRectBlock) {
        rect = self.toRectBlock();
    } else {
        rect = self.originRect;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        self.imageView.frame = rect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)pinchRecognized:(UIPinchGestureRecognizer *)gr {
    switch (gr.state) {
        case UIGestureRecognizerStateBegan: {
            CGAffineTransform transform = self.imageView.transform;
            self.originTransform = transform;
            transform = CGAffineTransformScale(transform, gr.scale, gr.scale);
            self.imageView.transform = transform;
            break;
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            CGAffineTransform transform = self.originTransform;
            transform = CGAffineTransformScale(transform, gr.scale, gr.scale);
            self.imageView.transform = transform;
            break;
        }
        default:
            break;
    }
    
    if (gr.state == UIGestureRecognizerStateEnded || gr.state == UIGestureRecognizerStateCancelled) {
        [self refreshImageViewFrame];
    }
}

- (void)panRecognized:(UIPanGestureRecognizer *)gr {
    switch (gr.state) {
        case UIGestureRecognizerStateBegan: {
            self.originCenter = self.imageView.center;
            CGPoint point = [gr translationInView:self];
            if (self.imageView.frame.size.height > [UIScreen mainScreen].bounds.size.height) {
                self.imageView.center = CGPointMake(self.imageView.center.x + point.x, self.imageView.center.y + point.y);
            } else {
                self.imageView.center = CGPointMake(self.imageView.center.x + point.x, self.imageView.center.y);
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            CGPoint point = [gr translationInView:self];
            if (self.imageView.frame.size.height > [UIScreen mainScreen].bounds.size.height) {
                self.imageView.center = CGPointMake(self.originCenter.x + point.x, self.originCenter.y + point.y);
            } else {
                self.imageView.center = CGPointMake(self.originCenter.x + point.x, self.originCenter.y);
            }
            break;
        }
        default:
            break;
    }
    if (gr.state == UIGestureRecognizerStateEnded || gr.state == UIGestureRecognizerStateCancelled) {
        [self refreshImageViewFrame];
    }
}

- (void)tapRecognized:(UITapGestureRecognizer *)gr {
    if (gr.state == UIGestureRecognizerStateRecognized) {
        [self hideButtonTapped:nil];
    }
}

- (void)refreshImageViewFrame {
    __block BOOL needFrame = NO;
    __block BOOL needCenter = NO;
    __block CGRect frame = CGRectNull;
    __block CGPoint center = CGPointZero;
    if (self.imageView.frame.size.width >= [UIScreen mainScreen].bounds.size.width) {
        if (self.imageView.frame.origin.x > 0) {
            needFrame = YES;
            frame = CGRectMake(0, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height);
        } else if (self.imageView.frame.origin.x + self.imageView.frame.size.width < [UIScreen mainScreen].bounds.size.width) {
            needFrame = YES;
            frame = CGRectMake([UIScreen mainScreen].bounds.size.width - self.imageView.frame.size.width, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height);
        }
    }
    if (self.imageView.frame.size.height <= [UIScreen mainScreen].bounds.size.height) {
        needCenter = YES;
        center = CGPointMake(self.imageView.center.x, [UIScreen mainScreen].bounds.size.height / 2.0);
    }
    [UIView animateWithDuration:0.2 animations:^{
        if (needCenter) {
            self.imageView.center = center;
        }
        if (needFrame) {
            self.imageView.frame = frame;
        }
    }];
}

- (void)setToRect:(ToRectBlock)block {
    self.toRectBlock = block;
}

@end

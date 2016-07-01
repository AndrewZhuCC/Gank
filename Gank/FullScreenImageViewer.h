//
//  FullScreenImageViewer.h
//  Gank
//
//  Created by 朱安智 on 16/7/1.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullScreenImageViewer : UIView
+ (FullScreenImageViewer *)showImageFromRect:(CGRect)rect image:(UIImage *)image;
@end

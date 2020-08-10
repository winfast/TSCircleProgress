//
//  Circle.h
//  YKL
//
//  Created by Apple on 15/12/7.
//  Copyright © 2015年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPGradientLayer : UIView

@property (assign, nonatomic) CGFloat progress;
@property (assign, nonatomic) CGFloat animationDuration;
@property (nonatomic, copy) void (^animatedCompletion)(CGFloat progress, BOOL finish);

- (instancetype)initWithFrame:(CGRect)frame colors:(NSArray <UIColor *> *)colors lineWidth:(CGFloat)lineWidth;
/// 设置进度
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end

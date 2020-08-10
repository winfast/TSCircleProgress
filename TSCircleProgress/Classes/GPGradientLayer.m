//
//  Circle.m
//  YKL
//
//  Created by Apple on 15/12/7.
//  Copyright © 2015年 Apple. All rights reserved.
//

#import "GPGradientLayer.h"

@interface GPGradientLayer () <CAAnimationDelegate>

@property (strong, nonatomic) CAShapeLayer *progressLayer;
@property (strong, nonatomic) CAGradientLayer *gradientLayer;
@property (assign, nonatomic) CGFloat lineWidth;

@end

@implementation GPGradientLayer


- (instancetype)initWithFrame:(CGRect)frame colors:(NSArray <UIColor *> *)colors lineWidth:(CGFloat)lineWidth
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.lineWidth = lineWidth;
        
        // 创建进度layer
        self.progressLayer = [CAShapeLayer layer];
        self.progressLayer.fillColor =  [[UIColor clearColor] CGColor];
        // 指定path的渲染颜色
        self.progressLayer.strokeColor  = [[UIColor blackColor] CGColor];
        self.progressLayer.lineCap = kCALineCapRound;
        self.progressLayer.lineWidth = lineWidth;
        self.progressLayer.strokeEnd = 0;
        
        // 设置渐变颜色
        self.gradientLayer =  [CAGradientLayer layer];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:colors.count];
        [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [temp addObject:(id)obj.CGColor];
        }];
        [self.gradientLayer setColors:temp.copy];
        self.gradientLayer.startPoint = CGPointMake(0.5, 0);
        self.gradientLayer.endPoint = CGPointMake(0.5, 1);
        // 用progressLayer来截取渐变层
        [self.gradientLayer setMask:self.progressLayer];
        [self.layer addSublayer:self.gradientLayer];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    // 创建贝塞尔路径
    CGFloat startAngle = - M_PI_2;
    CGFloat endAngle = startAngle + (2.0 * M_PI);
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.width / 2.0);
    // 半径
    CGFloat radius = (self.bounds.size.width - self.lineWidth) / 2.0;
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = self.lineWidth;
    path.lineCapStyle = kCGLineCapRound;
    [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.progressLayer.path = [path CGPath];
    
    if (self.progress <= 0) {
        self.progress = 0.001; // 为了开始有一个点
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.gradientLayer.frame = self.bounds;
    self.progressLayer.frame = self.bounds;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    self.progressLayer.strokeEnd = progress;
    [self.progressLayer removeAllAnimations];
}

/// 设置进度
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (animated) {
		if (progress == self.progress) {
			return;
		}
        CABasicAnimation *pathAnima = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnima.duration = self.animationDuration;
        pathAnima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        pathAnima.fromValue = @(_progress);
        pathAnima.toValue = @(progress);
        pathAnima.fillMode = kCAFillModeForwards;
        pathAnima.removedOnCompletion = NO;
        pathAnima.delegate = self;
        [self.progressLayer addAnimation:pathAnima forKey:@"strokeEndAnimation"];
        _progress = progress;
    } else {
        _progress = progress;
        self.progressLayer.strokeEnd = progress;
        [self.progressLayer removeAllAnimations];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.animatedCompletion && self.progress + 0.001 >= 1 && flag) {
        self.animatedCompletion(self.progress, flag);
    }
}

@end

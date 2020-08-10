//
//  GPGradientView.h
//  ProgressView
//
//  Created by sxiaojian on 15/10/29.
//  Copyright © 2015年 sxiaojian. All rights reserved.
//

#import "GOGradientView.h"
#import <CoreGraphics/CoreGraphics.h>

@interface GOGradientView ()

//@property (nonatomic, strong) UIColor *trackTintColor;
@property (nonatomic, readonly) CGFloat progress;
@property (nonatomic, assign) CGFloat backgroundRingWidth;
@property (nonatomic, assign) CGFloat progressRingWidth; // 线宽
@property (nonatomic, assign) BOOL isReverse;
//@property (nonatomic, assign) CGFloat moveSpeed;
@property (nonatomic, assign) CGFloat animationFromValue;
@property (nonatomic, assign) CGFloat animationToValue;
@property (nonatomic, assign) CFTimeInterval animationStartTime;
@property (nonatomic, strong) CADisplayLink *displayLink;
//@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, strong) CAShapeLayer *trackPointLayer;
@property (nonatomic, assign) CGFloat realTimeProgress;
@property (strong, nonatomic) NSArray *colors;
@property (strong, nonatomic) NSMutableArray <NSNumber *> *rcolors;
@property (strong, nonatomic) NSMutableArray <NSNumber *> *gcolors;
@property (strong, nonatomic) NSMutableArray <NSNumber *> *bcolors;

@end

@implementation GOGradientView

#pragma mark - Initialize
- (instancetype)initWithFrame:(CGRect)frame colors:(NSArray <UIColor *> *)colors lineWidth:(CGFloat)lineWidth
{
    self = [super initWithFrame:frame];
    if (self) {
        self.colors = colors;
        if (colors == nil) NSAssert(colors != nil, @"colors 不可为空！至少有一个颜色");
        if (colors.count == 1) {
            colors = @[colors.firstObject, colors.firstObject]; // 特殊处理下一种颜色的场景
        }
        self.rcolors = NSMutableArray.array;
        self.gcolors = NSMutableArray.array;
        self.bcolors = NSMutableArray.array;
        [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // 收集R G B各颜色数组
            CGFloat r;
            CGFloat g;
            CGFloat b;
            [obj getRed:&r green:&g blue:&b alpha:nil];
            [self.rcolors addObject:@(r)];
            [self.gcolors addObject:@(g)];
            [self.bcolors addObject:@(b)];
        }];
        
        self.backgroundColor = [UIColor clearColor]; // 该背景色设置其他不带透明度的颜色会覆盖进度条
//        self.trackTintColor = UIColor.clearColor;
//        self.backgroundRingWidth = lineWidth;
        self.progressRingWidth = lineWidth;

//        self.backgroundLayer = [CAShapeLayer layer];
//        self.backgroundLayer.fillColor = [UIColor clearColor].CGColor;
//        self.backgroundLayer.strokeColor = _trackTintColor.CGColor;
//        self.backgroundLayer.lineCap = kCALineCapRound;
//        self.backgroundLayer.lineWidth = lineWidth;
//        [self.layer addSublayer:self.backgroundLayer];
        
        // 终点标识，隐藏暂不使用
//        self.trackPointLayer = [CAShapeLayer layer];
//        self.trackPointLayer.fillColor = [UIColor clearColor].CGColor;
//        [self.layer addSublayer:self.trackPointLayer];
    }
    return self;
}

#pragma mark - Override super methods

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self drawBackground];
    [self drawProgress];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    _backgroundLayer.frame = self.bounds;
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    if (frame.size.width != frame.size.height) {
        frame.size.height = frame.size.width;
    }
    [super setFrame:frame];
}

#pragma mark - Intrinsic content size for AutoLayout

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}

#pragma mark - Getters and setters

//- (void)setTrackTintColor:(UIColor *)trackTintColor
//{
//    if (_trackTintColor != trackTintColor) {
//        _trackTintColor = trackTintColor;
//        _backgroundLayer.strokeColor = trackTintColor.CGColor;
//        [self setNeedsDisplay];
//    }
//}

//- (void)setBackgroundRingWidth:(CGFloat)backgroundRingWidth
//{
//    _backgroundRingWidth = backgroundRingWidth;
//    _backgroundLayer.lineWidth = _backgroundRingWidth;
//    [self setNeedsDisplay];
//}

- (void)setProgressRingWidth:(CGFloat)progressRingWidth
{
    _progressRingWidth = progressRingWidth;
    [self setNeedsDisplay];
}

#pragma mark - Progress

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (progress > 1) progress = 1;
    if (_progress == progress && !self.isReverse) return;

    if (animated == NO) {
        if (_displayLink) {
            [_displayLink invalidate];
            _displayLink = nil;
        }
        _progress = progress;
        _realTimeProgress = progress;
        [self setNeedsDisplay];
    } else {
        _animationStartTime = CACurrentMediaTime();
        _animationFromValue = self.progress;
        _animationToValue = progress;
        _progress = progress;
        _realTimeProgress = 0;
        if (!_displayLink) {
            [self.displayLink invalidate];
            self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateProgress:)];
            [self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
        }
    }
}

#pragma mark - Private methods

- (void)animateIndeterminate:(NSTimer *)timer
{
    CGAffineTransform transform = CGAffineTransformRotate(self.transform, 0.05);
    self.transform = transform;
}

- (void)animateProgress:(CADisplayLink *)displayLink
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat dt = (displayLink.timestamp - self.animationStartTime) / self.animationDuration;
        if (dt >= 1.0) {
            [self.displayLink invalidate];
            self.displayLink = nil;
            self.realTimeProgress = self.animationToValue;
            [self setNeedsDisplay];
            
            if (self.animatedCompletion) {
                self.animatedCompletion(self.progress, self.progress >= 1 - 0.001); // 减去误差
            }
            return;
        }

        self.realTimeProgress = self.animationFromValue + dt * (self.animationToValue - self.animationFromValue);
        [self setNeedsDisplay];
    });
}

- (void)drawBackground
{
    CGFloat startAngle = - M_PI_2;
    CGFloat endAngle = startAngle + (2.0 * M_PI);
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.width / 2.0);
    CGFloat radius = (self.bounds.size.width - _backgroundRingWidth) / 2.0;

    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = _progressRingWidth;
    path.lineCapStyle = kCGLineCapRound;
    [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];

//    _backgroundLayer.path = path.CGPath;
}

- (void)drawProgress
{
    CGFloat startAngle = - M_PI_2;
    CGFloat endAngle = startAngle + (2.0 * M_PI * _realTimeProgress);
    CGFloat trackPointEndAngle = startAngle + (2.0 * M_PI);
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.width / 2.0);
    CGFloat radius = (self.bounds.size.width - _progressRingWidth) / 2.0;
    
    int sectors = (int)self.rcolors.count * 40;
    float angle ;
    
    CGFloat startAngleNeedDraw ;

    if (endAngle - startAngle >  2.0 * M_PI) {
        angle = 2 * M_PI/sectors;
        startAngleNeedDraw = endAngle - 2.0 * M_PI;

    } else {
        angle = (endAngle - startAngle) / sectors;
        startAngleNeedDraw = startAngle;
    }
    // MARK: 颜色渐变逻辑
    UIBezierPath *sectorPath;
    for (int i = 0; i < sectors; i ++) {
        CGFloat R = 0.0;
        CGFloat G = 0.0;
        CGFloat B = 0.0;
        
        UIColor *color;
        if (self.rcolors.count == 2) {
            CGFloat part = (float)i / (float)sectors;
            // 2种颜色渐变
            R = self.rcolors[0].floatValue + (self.rcolors[1].floatValue - self.rcolors[0].floatValue) * part;
            G = self.gcolors[0].floatValue + (self.gcolors[1].floatValue - self.gcolors[0].floatValue) * part;
            B = self.bcolors[0].floatValue + (self.bcolors[1].floatValue - self.bcolors[0].floatValue) * part;
            color = [UIColor colorWithRed:R green:G blue:B alpha:1];
        } else if (self.rcolors.count == 3) {
            // 3种
            CGFloat part = sectors / 2;
            if (i <= part) {
                R = self.rcolors[0].floatValue + (self.rcolors[1].floatValue - self.rcolors[0].floatValue) * ((float)i / ((float)sectors / 2));
                G = self.gcolors[0].floatValue + (self.gcolors[1].floatValue - self.gcolors[0].floatValue) * ((float)i / ((float)sectors / 2));
                B = self.bcolors[0].floatValue + (self.bcolors[1].floatValue - self.bcolors[0].floatValue) * ((float)i / ((float)sectors / 2));
                color = [UIColor colorWithRed:R green:G blue:B alpha:1];
            }
            else {
                R = self.rcolors[1].floatValue + (self.rcolors[2].floatValue - self.rcolors[1].floatValue) * (((float)i - part) / ((float)sectors / 2));
                G = self.gcolors[1].floatValue + (self.gcolors[2].floatValue - self.gcolors[1].floatValue) * (((float)i - part) / ((float)sectors / 2));
                B = self.bcolors[1].floatValue + (self.bcolors[2].floatValue - self.bcolors[1].floatValue) * (((float)i - part) / ((float)sectors / 2));
                color = [UIColor colorWithRed:R green:G blue:B alpha:1];
            }
        }  else {
            // 4种
            CGFloat part = sectors / 3;
            if (i <= part) {
                R = self.rcolors[0].floatValue + (self.rcolors[1].floatValue - self.rcolors[0].floatValue) * ((float)i / ((float)sectors / 3));
                G = self.gcolors[0].floatValue + (self.gcolors[1].floatValue - self.gcolors[0].floatValue) * ((float)i / ((float)sectors / 3));
                B = self.bcolors[0].floatValue + (self.bcolors[1].floatValue - self.bcolors[0].floatValue) * ((float)i / ((float)sectors / 3));
                color = [UIColor colorWithRed:R green:G blue:B alpha:1];
            }
            else if (i <= part * 2) {
                R = self.rcolors[1].floatValue + (self.rcolors[2].floatValue - self.rcolors[1].floatValue) * (((float)i - part) / ((float)sectors / 3));
                G = self.gcolors[1].floatValue + (self.gcolors[2].floatValue - self.gcolors[1].floatValue) * (((float)i - part) / ((float)sectors / 3));
                B = self.bcolors[1].floatValue + (self.bcolors[2].floatValue - self.bcolors[1].floatValue) * (((float)i - part) / ((float)sectors / 3));
                color = [UIColor colorWithRed:R green:G blue:B alpha:1];
            }
            else {
                R = self.rcolors[2].floatValue + (self.rcolors[3].floatValue - self.rcolors[2].floatValue) * (((float)i - part * 2) / ((float)sectors / 3));
                G = self.gcolors[2].floatValue + (self.gcolors[3].floatValue - self.gcolors[2].floatValue) * (((float)i - part * 2) / ((float)sectors / 3));
                B = self.bcolors[2].floatValue + (self.bcolors[3].floatValue - self.bcolors[2].floatValue) * (((float)i - part * 2) / ((float)sectors / 3));
                color = [UIColor colorWithRed:R green:G blue:B alpha:1];
            }
        }

        sectorPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngleNeedDraw + i * angle endAngle:startAngleNeedDraw + (i + 1) * angle + 0.001 clockwise:YES];
        if (i == 0) {
            sectorPath.lineCapStyle = kCGLineCapRound;
        }

        [sectorPath setLineWidth:_progressRingWidth];
        [sectorPath setLineCapStyle:kCGLineCapRound];
        [color setStroke];
        [sectorPath stroke];
    }
    
    if (endAngle != startAngle) {
        CGSize shadowOffset = CGSizeMake(0, 5);
        CGAffineTransform transform = CGAffineTransformMakeRotation(endAngle);
        CGSize newOffset = CGSizeApplyAffineTransform(shadowOffset, transform);
        
        NSShadow* shadow = [[NSShadow alloc] init];
        [shadow setShadowColor: [UIColor colorWithWhite:0 alpha:0.2]];
        [shadow setShadowOffset: newOffset];
        [shadow setShadowBlurRadius:3];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        sectorPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:endAngle - angle endAngle:endAngle clockwise:YES];
        CGContextSaveGState(context);
        
        UIColor *color = [UIColor colorWithRed:self.rcolors.lastObject.floatValue green:self.gcolors.lastObject.floatValue blue:self.bcolors.lastObject.floatValue alpha:1];
        [sectorPath setLineWidth:_progressRingWidth];
        [sectorPath setLineCapStyle:kCGLineCapRound];
        
        CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
        [color setStroke];
        [sectorPath stroke];
        
        CGContextRestoreGState(context);
    }

    UIBezierPath *circularPath = [UIBezierPath bezierPath];
    [circularPath addArcWithCenter:sectorPath.currentPoint radius:_progressRingWidth/2 - 3 startAngle:startAngle endAngle:trackPointEndAngle clockwise:YES];
    _trackPointLayer.path = circularPath.CGPath;
}

// MARK: 颜色渐变反转
- (void)reverseGradienColor
{
    self.isReverse = YES;
    self.rcolors = [self.rcolors reverseObjectEnumerator].allObjects.mutableCopy;
    self.gcolors = [self.gcolors reverseObjectEnumerator].allObjects.mutableCopy;
    self.bcolors = [self.bcolors reverseObjectEnumerator].allObjects.mutableCopy;
    [self setProgress:self.progress animated:YES];
    self.isReverse = NO;
}

- (void)updateCircleWithColors:(NSArray <UIColor *> *)colors animated:(BOOL)animated
{
    self.colors = colors;
    [self setProgress:0 animated:animated];
	
	if (animated) {
		 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			   // 清空历史颜色
			   [self.rcolors removeAllObjects];
			   [self.gcolors removeAllObjects];
			   [self.bcolors removeAllObjects];
			   
			   [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
				   // 收集R G B各颜色数组
				   CGFloat r;
				   CGFloat g;
				   CGFloat b;
				   [obj getRed:&r green:&g blue:&b alpha:nil];
				   [self.rcolors addObject:@(r)];
				   [self.gcolors addObject:@(g)];
				   [self.bcolors addObject:@(b)];
			   }];
		   });
	} else {
		[self.rcolors removeAllObjects];
		[self.gcolors removeAllObjects];
		[self.bcolors removeAllObjects];
	  
		[colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		  // 收集R G B各颜色数组
			CGFloat r;
			CGFloat g;
			CGFloat b;
			[obj getRed:&r green:&g blue:&b alpha:nil];
			[self.rcolors addObject:@(r)];
			[self.gcolors addObject:@(g)];
			[self.bcolors addObject:@(b)];
	  }];
	}
}

@end

//
//  GPGradientView.h
//  ProgressView
//
//  Created by sxiaojian on 15/10/29.
//  Copyright © 2015年 sxiaojian. All rights reserved.
//

#import "GPGradientView.h"

@interface GPGradientView ()

@property (strong, nonatomic) UIImageView *backgroundView;

@property (strong, nonatomic) UIImageView *progressView;
@property (strong, nonatomic) CAShapeLayer *progressLayer;
@property (strong, nonatomic) UIBezierPath *progressPath;

//@property (strong, nonatomic) UIImageView *startPoint;
//@property (strong, nonatomic) CAShapeLayer *startPathLayer;
//@property (strong, nonatomic) UIBezierPath *startPath;

@property (strong, nonatomic) UIImageView *endPoint;
//@property (nonatomic, strong) CALayer *gradientLayer;
@property (nonatomic, strong) CALayer *shadowLayer;
@property (nonatomic, strong) CALayer *rotateLayer;

@property (strong, nonatomic) CAShapeLayer *endLayer;
@property (strong, nonatomic) UIBezierPath *endPath;

@property (assign, nonatomic) CGFloat angle;
@property (assign, nonatomic) CGFloat progress;
@property (strong, nonatomic) UIImage *normal;
@property (strong, nonatomic) UIImage *select;

@property (nonatomic) BOOL waiting;

@property (nonatomic, strong) UIImageView *endPointImageView;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CFTimeInterval animationStartTime;
@property (nonatomic, assign) CGFloat animationFromValue;
@property (nonatomic, assign) CGFloat animationToValue;
@property (nonatomic, assign) CGFloat realTimeProgress;

@end

@implementation GPGradientView

#pragma mark - Initialize
- (instancetype)initWithFrame:(CGRect)frame colors:(NSArray <UIColor *> *)colors lineWidth:(CGFloat)lineWidth
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        
        self.progressView = UIImageView.new;
        self.progressView.image = [self imageWithBundleName:@"GPCircleProgress" imageName:@"bg"];
        self.progressView.contentMode = UIViewContentModeScaleAspectFill;
        self.progressView.frame = self.bounds;
        [self addSubview:self.progressView];
		
		CALayer *circelLayer = CALayer.layer;
		circelLayer.frame = CGRectMake(self.frame.size.width * 0.5 - lineWidth * 0.5 - 0.5, 0, lineWidth + 1, lineWidth);
		circelLayer.masksToBounds = YES;
		circelLayer.contentsGravity = kCAGravityResizeAspectFill;
		circelLayer.contents = (id)[self imageWithBundleName:@"GPCircleProgress" imageName:@"preheat_img_circle"].CGImage;
		circelLayer.cornerRadius = lineWidth * 0.5;
		[self.progressView.layer addSublayer:circelLayer];
		

        self.progressPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0) radius:self.frame.size.width * 0.5 - lineWidth * 0.5 startAngle:- M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES];
        
        self.progressLayer = [CAShapeLayer layer];
        self.progressLayer.fillColor = [UIColor clearColor].CGColor;
        self.progressLayer.strokeColor = UIColor.redColor.CGColor;
        self.progressLayer.lineWidth = lineWidth;
        self.progressLayer.strokeEnd = 0;
        self.progressLayer.frame = self.bounds;
        self.progressLayer.path = self.progressPath.CGPath;
		self.progressLayer.lineCap = kCALineCapRound;
        self.progressView.layer.mask = self.progressLayer;
		self.progressLayer.strokeEnd = 0.001;
        
        self.normal = [self imageWithBundleName:@"GPCircleProgress" imageName:@"bg"];
        self.select = [self imageWithBundleName:@"GPCircleProgress" imageName:@"bgh"];
        
//        self.startPoint = UIImageView.alloc.init;
//        self.startPoint.frame = self.bounds;
//        self.startPoint.contentMode = UIViewContentModeScaleAspectFill;
//        self.startPoint.backgroundColor = UIColor.blackColor;
//        [self insertSubview:self.startPoint belowSubview:self.progressView];
//
        CGPoint center = CGPointMake(frame.size.width * 0.5, lineWidth * 0.5);
        CGFloat radius = lineWidth * 0.5;
//        self.startPath = [UIBezierPath bezierPathWithArcCenter:center
//                                                        radius:radius
//                                                    startAngle:-M_PI_2
//                                                      endAngle:M_PI_2
//                                                     clockwise:NO];
//		UIBezierPath *startTopArcBezierPath = [UIBezierPath bezierPathWithArcCenter:self.center radius:self.frame.size.width * 0.5 startAngle:-M_PI_2 endAngle:-M_PI_2 + M_PI_2/90.0 clockwise:YES];
//		self.startPath = [UIBezierPath bezierPath];
//		[self.startPath appendPath:[startTopArcBezierPath bezierPathByReversingPath]];
//		[self.startPath addArcWithCenter:center radius:radius startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:NO];
//		[self.startPath addArcWithCenter:self.center radius:self.frame.size.width * 0.5 - lineWidth startAngle:-M_PI_2 endAngle:-M_PI_2 + M_PI_2/90.0 clockwise:YES];
//		[self.startPath closePath];
		
//        self.startPathLayer = [CAShapeLayer layer];
//        self.startPathLayer.strokeColor = UIColor.clearColor.CGColor;
//        self.startPathLayer.fillColor = [UIColor redColor].CGColor;
//        self.startPathLayer.frame = self.bounds;
//        self.startPathLayer.path = self.startPath.CGPath;
//        self.startPoint.layer.mask = self.startPathLayer;
        
        self.endPoint = UIImageView.new;
        self.endPoint.layer.contents = (id)self.normal.CGImage;
        self.endPoint.layer.contentsGravity = kCAGravityResizeAspectFill;
        self.endPoint.frame = self.bounds;
        [self addSubview:self.endPoint];
		
//		self.gradientLayer = CALayer.layer;
//		self.gradientLayer.frame = self.layer.bounds;
//		self.gradientLayer.contentsGravity = kCAGravityResizeAspectFill;
//		self.gradientLayer.contents = (id)self.normal.CGImage;
//		[self.endPoint.layer addSublayer:self.gradientLayer];
		
        self.endPath = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:radius
                                                    startAngle:-M_PI_2
                                                      endAngle:M_PI_2 * 3
                                                     clockwise:YES];
        self.endLayer = [CAShapeLayer layer];
        self.endLayer.strokeColor = UIColor.clearColor.CGColor;
        self.endLayer.fillColor = [UIColor redColor].CGColor;
        self.endLayer.bounds = self.bounds;
        self.endLayer.position = self.center;
        self.endLayer.path = self.endPath.CGPath;
        self.endPoint.layer.mask = self.endLayer;
	
//		self.shadowLayer = [[KJShadowLayer alloc] kj_initWithFrame:CGRectMake(0, 0, 50 + 10, 50) ShadowType:KJShadowTypeProjection];
//		self.shadowLayer.kj_shadowPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 50, 50)];
////		self.shadowLayer.kj_shadowRadius = 3;
//		self.shadowLayer.backgroundColor = UIColor.whiteColor.CGColor;
//		self.shadowLayer.kj_shadowColor = UIColor.redColor;
//		self.shadowLayer.kj_shadowOpacity = 0.5;
//		self.shadowLayer.kj_shadowDiffuse = -5;
//		self.shadowLayer.kj_shadowRadius = 1;
////		self.shadowLayer.kj_shadowOffset = CGSizeMake(3, 3);
////		self.shadowLayer.kj_shadowAngle = 1;
//		[self.endPoint.layer addSublayer:self.shadowLayer];
		
//		self.rotateLayer = CALayer.layer;
//		self.rotateLayer.frame = self.endPoint.bounds;
//		self.rotateLayer.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.0].CGColor;
//		[self.endPoint.layer addSublayer:self.rotateLayer];
		
		
//		CGFloat hegith = lineWidth * 1.5;
//		self.shadowLayer = CALayer.layer;
//		self.shadowLayer.contents = (id)[self imageWithBundleName:@"GPCircleProgress" imageName:@"preheat_img_shadow"].CGImage;
//		self.shadowLayer.frame = CGRectMake(self.bounds.size.width * 0.5, -lineWidth * 0.25, hegith * (42/60.0), hegith);
//		self.shadowLayer.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.0].CGColor;
//		[self.rotateLayer addSublayer:self.shadowLayer];
		
		self.endPointImageView = UIImageView.alloc.init;
		self.endPointImageView.backgroundColor = UIColor.clearColor;
		self.endPointImageView.frame = CGRectMake(self.frame.size.width * 0.5 - lineWidth * 0.5 - 0.5, 0, lineWidth + 1, lineWidth);
		self.endPointImageView.image = [self imageWithBundleName:@"GPCircleProgress" imageName:@"preheat_img_circle"];
		[self addSubview:self.endPointImageView];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
	if (self.progress == progress) {
		return;
	}
	if (self.displayLink) {
		[self.displayLink removeFromRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
		[self.displayLink invalidate];
		self.displayLink = nil;
	}
	
	self.animationStartTime = CACurrentMediaTime();
	self.animationFromValue = self.progress;
	self.animationToValue = progress;
	self.progress = progress;
	self.realTimeProgress = 0.0;
	self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateProgress:)];
	[self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
}

- (void)animateProgress:(CADisplayLink *)displayLink {
	dispatch_async(dispatch_get_main_queue(), ^{
		CGFloat dt = (self.displayLink.timestamp - self.animationStartTime) / 1.0;
		if (dt >= 1.0) {
			[self.displayLink invalidate];
			self.displayLink = nil;
		}
		
		self.realTimeProgress = self.animationFromValue + dt * (self.animationToValue - self.animationFromValue);
		if (self.realTimeProgress >= 1) {
			self.realTimeProgress = 0.999;
		}
		else if (self.realTimeProgress <= 0) {
			self.realTimeProgress = 0.001;
		}
		//self.progressLayer.strokeEnd = self.realTimeProgress;
		CGFloat angle = M_PI * 2 * self.realTimeProgress;
		
		CABasicAnimation *strokeEnd = CABasicAnimation.animation;
		strokeEnd.keyPath = @"strokeEnd";
		strokeEnd.duration = self.displayLink.duration;
		strokeEnd.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		strokeEnd.fromValue = @(self.progress);
		strokeEnd.toValue = @(self.realTimeProgress);
		strokeEnd.fillMode = kCAFillModeForwards;
		strokeEnd.removedOnCompletion = NO;
		strokeEnd.autoreverses = NO;
		[self.progressLayer addAnimation:strokeEnd forKey:nil];

		CABasicAnimation *transform = CABasicAnimation.animation;
		transform.keyPath = @"transform.rotation.z";
		transform.duration = self.displayLink.duration;
		transform.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		transform.fromValue = @(self.angle);
		transform.toValue = @(angle);
		transform.fillMode = kCAFillModeForwards;
		transform.removedOnCompletion = NO;
		transform.autoreverses = NO;
		[self.endLayer addAnimation:transform forKey:nil];
		
		self.angle = angle;
		self.progress = self.realTimeProgress;
		
		//self.endLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1);
		
		if (self.realTimeProgress > 0.8) { // 切换颜色的比例
			self.endPoint.layer.contents = (id)self.select.CGImage;
			self.endPointImageView.hidden = YES;
		} else {
			self.endPoint.layer.contents = (id)self.normal.CGImage;
			self.endPointImageView.hidden = NO;
		}
	});
//	NSLog(@"%f   %d", progress, self.waiting);
//		if (((_progress < 0.7 && progress > 0.7)
//			 || (_progress > 0.7 && progress < 0.7)) && NO == self.waiting) {
//			self.waiting = YES;
//			[self setProgress:0.7 animated:YES];
//			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//				self.waiting = NO;
//				[self setProgress:progress animated:YES];
//			});
//			return;
//		}
//
//		if (YES == self.waiting && 0.7 != progress) return;
//
//		NSLog(@"self.progress = %f   progress = %f", self.progress, progress);
//		//需要留一点误差, 看起来效果更好
//		if (progress >= 0.9999) {
//			progress = 0.999;
//		}
//
//		CGFloat offset = 0;
//		CGFloat angle = M_PI * 2 * progress;
//		CGFloat realAngle = angle - offset > 0 ? angle - offset : 0;
//
//		CABasicAnimation *strokeEnd = CABasicAnimation.animation;
//		strokeEnd.keyPath = @"strokeEnd";
//		strokeEnd.duration = 1;
//		strokeEnd.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//		strokeEnd.fromValue = @(self.progress);
//
//		strokeEnd.toValue = @(progress);
//		strokeEnd.fillMode = kCAFillModeForwards;
//		strokeEnd.removedOnCompletion = NO;
//		strokeEnd.autoreverses = NO;
//		[self.progressLayer addAnimation:strokeEnd forKey:nil];
//
//		CABasicAnimation *transform = CABasicAnimation.animation;
//		transform.keyPath = @"transform.rotation.z";
//		transform.duration = 1;
//		transform.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//		transform.fromValue = @(self.angle);
//		transform.toValue = @(realAngle);
//		transform.fillMode = kCAFillModeForwards;
//		transform.removedOnCompletion = NO;
//		transform.autoreverses = NO;
//		[self.endLayer addAnimation:transform forKey:nil];
//
//	//    CABasicAnimation *shadowTransform = CABasicAnimation.animation;
//	//    shadowTransform.keyPath = @"transform.rotation.z";
//	//    shadowTransform.duration = 1;
//	//    shadowTransform.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//	//    shadowTransform.fromValue = @(self.angle);
//	//    shadowTransform.toValue = @(realAngle);
//	//    shadowTransform.fillMode = kCAFillModeForwards;
//	//    shadowTransform.removedOnCompletion = NO;
//	//    [self.rotateLayer addAnimation:shadowTransform forKey:nil];
//
//		if (progress > 0.8) { // 切换颜色的比例
//			self.gradientLayer.contents = (id)self.select.CGImage;
//		} else {
//			self.gradientLayer.contents = (id)self.normal.CGImage;
//		}
//
//		if (progress >= 0.3) {
//			self.endPointImageView.hidden = YES;
//		}
//		else {
//			self.endPointImageView.hidden = NO;
//		}
//
//		_progress = progress;
//		_angle = realAngle;
}

- (void)pauseAnimate {
	[self nx_pauseAnimate:self.progressLayer];
	[self nx_pauseAnimate:self.endLayer];
}

- (void)resumeAnimate {
	[self nx_resumeAnimate:self.progressLayer];
	[self nx_resumeAnimate:self.endLayer];
}

- (void)nx_pauseAnimate:(CALayer *)layer
{
    CFTimeInterval pauseTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    // 设置layer的timeOffset, 在继续操作也会使用到
    layer.timeOffset = pauseTime;
    // local time与parent time的比例为0, 意味着local time暂停了
    layer.speed = 0;
}
//继续动画
- (void)nx_resumeAnimate:(CALayer *)layer
{
    // 时间转换
    CFTimeInterval pauseTime = layer.timeOffset;
    // 计算暂停时间
    CFTimeInterval timeSincePause = CACurrentMediaTime() - pauseTime;
    // 取消
    layer.timeOffset = 0;
    // local time相对于parent time世界的beginTime
    layer.beginTime = timeSincePause;
    // 继续
    layer.speed = 1;
}


- (void)animateIndeterminate:(NSTimer *)timer
{
    
}


- (void)drawBackground
{
    
}

- (void)drawProgress
{
    
}

- (void)reverseGradienColor
{
   
}

- (void)updateCircleWithColors:(NSArray <UIColor *> *)colors animated:(BOOL)animated
{
    
}

- (UIImage *)imageWithBundleName:(NSString *)bundleName imageName:(NSString *)imageName {
	if (imageName.length <= 0) {
		return nil;
	}
	NSBundle *clsBundle = [NSBundle bundleForClass:self.class];
	NSURL *resUrl = [clsBundle URLForResource:bundleName withExtension:@"bundle"];
	if (!resUrl) {
		return nil;
	}
	NSBundle *resBundle = [NSBundle bundleWithURL:resUrl];
	NSLog(@"resBundle = %@ \t\n",resBundle);
	if (!resBundle.loaded) {
		[resBundle load];
	}
	UIImage *retImg = [UIImage imageNamed:imageName inBundle:resBundle compatibleWithTraitCollection:nil];
	return retImg;
}


@end

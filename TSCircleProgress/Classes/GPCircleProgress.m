//
//  GPCircleProgress.m
//  GPCircleProgress
//
//  Created by Kalan on 2019/12/6.
//

#import "GPCircleProgress.h"
#import "GPGradientView.h"
#import "GOGradientView.h"
#import "GPGradientLayer.h"

@implementation GPCircleConfig

@end

@interface GPCircleProgress ()

@property (strong, nonatomic) GPCircleConfig *config;
@property (strong, nonatomic) GPGradientView *gradientView;
@property (strong, nonatomic) GOGradientView *singleColorView;
@property (strong, nonatomic) GPGradientLayer *gradientLayer;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, strong) CAGradientLayer *backgroundGradientLayer;

@property (nonatomic, strong) GPGradientView *backgroundGradientView;

@property (strong, nonatomic) UIImageView *progressView;
@property (strong, nonatomic) CAShapeLayer *progressLayer;
@property (strong, nonatomic) UIBezierPath *progressPath;

@end

@implementation GPCircleProgress

- (instancetype)initWithFrame:(CGRect)frame config:(GPCircleConfig *)config
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.config = config;
        
        /// 背景视图
        if (config.circleType == GPCircleTypeGradientView) {
            
            self.progressView = UIImageView.new;
            self.progressView.image = [self imageWithBundleName:@"GPCircleProgress" imageName:@"bg"];
            self.progressView.contentMode = UIViewContentModeScaleAspectFill;
            self.progressView.frame = self.bounds;
            self.progressView.alpha = 0.4;
            [self addSubview:self.progressView];

            self.progressPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0) radius:self.frame.size.width * 0.5 - config.lineWidth * 0.5 startAngle:- M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES];
            
            self.progressLayer = [CAShapeLayer layer];
            self.progressLayer.fillColor = [UIColor clearColor].CGColor;
            self.progressLayer.strokeColor = UIColor.redColor.CGColor;
            self.progressLayer.lineWidth = config.lineWidth;
            self.progressLayer.strokeEnd = 0;
            self.progressLayer.frame = self.bounds;
            self.progressLayer.path = self.progressPath.CGPath;
            self.progressView.layer.mask = self.progressLayer;
            
            self.progressLayer.strokeEnd = 1.0;
			
			if (config.trackTintColors) {
				self.backgroundGradientView = [GPGradientView.alloc initWithFrame:self.bounds colors:config.trackTintColors lineWidth:config.lineWidth];
				[self.backgroundGradientView setProgress:1 animated:NO];
				[self addSubview:self.backgroundGradientView];
			}
			else {
				_backgroundLayer = [CAShapeLayer layer];
				_backgroundLayer.fillColor = [UIColor clearColor].CGColor;
				_backgroundLayer.strokeColor = config.trackTintColor.CGColor;
				_backgroundLayer.lineCap = kCALineCapRound;
				_backgroundLayer.lineWidth = config.lineWidth;
				[self.layer addSublayer:_backgroundLayer];
			}
			
            self.gradientView = [GPGradientView.alloc initWithFrame:self.bounds colors:config.colors lineWidth:config.lineWidth];
            [self addSubview:self.gradientView];
            
            __weak typeof(self) weakself = self;
            self.gradientView.animationDuration = config.animationDuration > 0 ? config.animationDuration : 1;
            self.gradientView.animatedCompletion = ^(CGFloat progress, BOOL finish) {
                if (weakself.animatedCompletion) {
                    weakself.animatedCompletion(progress, finish);
                }
            };
        }
        else if (config.circleType == GPCircleTypeGradientLayer) {
			if (config.trackTintColor) {
				_backgroundLayer = [CAShapeLayer layer];
				_backgroundLayer.fillColor = [UIColor clearColor].CGColor;
				_backgroundLayer.strokeColor = config.trackTintColor.CGColor;
				_backgroundLayer.lineCap = kCALineCapRound;
				_backgroundLayer.lineWidth = config.lineWidth;
				[self.layer addSublayer:_backgroundLayer];
			}
			else {
				_backgroundLayer = [CAShapeLayer layer];
				_backgroundLayer.fillColor = [UIColor clearColor].CGColor;
				_backgroundLayer.strokeColor = UIColor.yellowColor.CGColor;
				_backgroundLayer.lineCap = kCALineCapRound;
				_backgroundLayer.lineWidth = config.lineWidth;
				
				NSMutableArray *temp = [NSMutableArray arrayWithCapacity:config.trackTintColors.count];
				[config.trackTintColors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
					[temp addObject:(id)obj.CGColor];
				}];
				_backgroundGradientLayer = [CAGradientLayer layer];
				_backgroundGradientLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
				_backgroundGradientLayer.colors = temp;
				_backgroundGradientLayer.bounds = self.bounds;
				_backgroundGradientLayer.startPoint = CGPointMake(0.0, 0.0);
				_backgroundGradientLayer.endPoint = CGPointMake(0.0, 1.0);
				[_backgroundGradientLayer setMask:_backgroundLayer];
				[self.layer addSublayer:_backgroundGradientLayer];
			}
			
			self.gradientLayer = [GPGradientLayer.alloc initWithFrame:self.bounds colors:config.colors lineWidth:config.lineWidth];
			self.gradientLayer.animationDuration = config.animationDuration > 0 ? config.animationDuration : 1;
			[self addSubview:self.gradientLayer];
			
			__weak typeof(self) weakself = self;
			self.gradientLayer.animatedCompletion = ^(CGFloat progress, BOOL finish) {
				if (weakself.animatedCompletion) {
					weakself.animatedCompletion(progress, finish);
				}
			};
        }
        else if (config.circleType == GPCircleTypeGradientSingleColor) {
            if (config.trackTintColor) {
                _backgroundLayer = [CAShapeLayer layer];
                _backgroundLayer.fillColor = [UIColor clearColor].CGColor;
                _backgroundLayer.strokeColor = config.trackTintColor.CGColor;
                _backgroundLayer.lineCap = kCALineCapRound;
                _backgroundLayer.lineWidth = config.lineWidth;
                [self.layer addSublayer:_backgroundLayer];
            }
            else {
                _backgroundLayer = [CAShapeLayer layer];
                _backgroundLayer.fillColor = [UIColor clearColor].CGColor;
                _backgroundLayer.strokeColor = UIColor.yellowColor.CGColor;
                _backgroundLayer.lineCap = kCALineCapRound;
                _backgroundLayer.lineWidth = config.lineWidth;
                
                NSMutableArray *temp = [NSMutableArray arrayWithCapacity:config.trackTintColors.count];
                [config.trackTintColors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [temp addObject:(id)obj.CGColor];
                }];
                _backgroundGradientLayer = [CAGradientLayer layer];
                _backgroundGradientLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
                _backgroundGradientLayer.colors = temp;
                _backgroundGradientLayer.bounds = self.bounds;
                _backgroundGradientLayer.startPoint = CGPointMake(0.0, 0.0);
                _backgroundGradientLayer.endPoint = CGPointMake(0.0, 1.0);
                [_backgroundGradientLayer setMask:_backgroundLayer];
                [self.layer addSublayer:_backgroundGradientLayer];
            }
            
            self.singleColorView = [GOGradientView.alloc initWithFrame:self.bounds colors:config.colors lineWidth:config.lineWidth];
            [self addSubview:self.singleColorView];

            __weak typeof(self) weakself = self;
            self.singleColorView.animationDuration = config.animationDuration > 0 ? config.animationDuration : 1;
            self.singleColorView.animatedCompletion = ^(CGFloat progress, BOOL finish) {
                if (weakself.animatedCompletion) {
                    weakself.animatedCompletion(progress, finish);
                }
            };
        }
        
        self.centerLabel = UILabel.alloc.init;
        self.centerLabel.font = [UIFont boldSystemFontOfSize:20];
        self.centerLabel.textColor = config.colors.lastObject;
        self.centerLabel.textAlignment = NSTextAlignmentCenter;
        self.centerLabel.layer.masksToBounds = YES;
        [self addSubview:self.centerLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    /// 重置视图尺寸
    self.singleColorView.frame = self.bounds;
    self.gradientView.frame = self.bounds;
    self.gradientLayer.frame = self.bounds;
	self.backgroundGradientView.frame = self.bounds;
    self.centerLabel.bounds = CGRectMake(0, 0, self.bounds.size.width - self.config.lineWidth * 2 - 10, self.bounds.size.width - self.config.lineWidth * 2 - 10);
    self.centerLabel.layer.cornerRadius = self.centerLabel.bounds.size.width * 0.5;
    
    if (self.config.circleType == GPCircleTypeGradientView) {
        self.centerLabel.center = self.gradientView.center;
    }
    else if (self.config.circleType == GPCircleTypeGradientLayer) {
        self.centerLabel.center = self.gradientLayer.center;
    }
    else if (self.config.circleType == GPCircleTypeGradientSingleColor) {
        self.centerLabel.center = self.singleColorView.center;
    }
}

-(void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setProgress:progress animated:NO];
}

/// 设置进度
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    _progress = progress;
    [self.gradientView setProgress:progress animated:animated];
    [self.gradientLayer setProgress:progress animated:animated];
    [self.singleColorView setProgress:progress animated:animated];
}

// 翻转渐变颜色
- (void)reverseGradienColor
{
//    [self.gradientView reverseGradienColor];
}

- (void)updateCircleWithColors:(NSArray <UIColor *> *)colors animated:(BOOL)animated
{
//    [self.gradientView updateCircleWithColors:colors animated:animated];
}


- (NSArray *)colors
{
    return self.gradientView.colors;
}

- (void)drawRect:(CGRect)rect
{
    if (self.config.circleType == GPCircleTypeGradientView) {
        return;
    }
    /// 绘制进度轨迹背景
    CGFloat startAngle = - M_PI_2;
    CGFloat endAngle = startAngle + (2.0 * M_PI);
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.width / 2.0);
    CGFloat radius = (self.bounds.size.width - self.config.lineWidth) / 2.0;

    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = self.config.lineWidth;
    path.lineCapStyle = kCGLineCapRound;
    [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];

    _backgroundLayer.path = path.CGPath;
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

- (void)resumeAnimate {
	[self.gradientView resumeAnimate];
}
- (void)pauseAnimate {
	[self.gradientView pauseAnimate];
}

@end

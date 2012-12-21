
#import "PRTween.h"

#define kPRTweenFramerate 1.0/60

@implementation PRTweenPeriod
@synthesize startValue;
@synthesize endValue;
@synthesize tweenedValue;
@synthesize duration;
@synthesize delay;
@synthesize startOffset;

+ (id)periodWithStartValue:(CGFloat)aStartValue endValue:(CGFloat)anEndValue duration:(CGFloat)duration {
    PRTweenPeriod *period = [PRTweenPeriod new];
    
    period.startValue = period.tweenedValue = aStartValue;
    period.endValue = anEndValue;
    period.duration = duration;
    period.startOffset = [[PRTween sharedInstance] timeOffset];
    
    return [period autorelease];
}

@end

@implementation PRTweenLerpPeriod
@synthesize startLerp;
@synthesize endLerp;
@synthesize tweenedLerp;

+ (id)periodWithStartValue:(NSValue*)aStartValue endValue:(NSValue*)anEndValue duration:(CGFloat)duration {
    PRTweenLerpPeriod *period = [[self class] new];
    period.startLerp = aStartValue;
    period.tweenedLerp = aStartValue;
    period.endLerp = anEndValue;
    period.duration = duration;
    period.startOffset = [[PRTween sharedInstance] timeOffset];
    
    return [period autorelease];
}

- (void)dealloc {
    [startLerp release];
    [endLerp release];
    [tweenedLerp release];
    [super dealloc];
}

@end

@implementation PRTweenCGPointLerpPeriod

+ (id)periodWithStartCGPoint:(CGPoint)aStartPoint endCGPoint:(CGPoint)anEndPoint duration:(CGFloat)duration {
    return [PRTweenCGPointLerpPeriod periodWithStartValue:[NSValue valueWithCGPoint:aStartPoint] endValue:[NSValue valueWithCGPoint:anEndPoint] duration:duration];
}

- (CGPoint)startCGPoint { return [self.startLerp CGPointValue]; }
- (CGPoint)tweenedCGPoint { return [self.tweenedLerp CGPointValue]; }
- (CGPoint)endCGPoint { return [self.endLerp CGPointValue]; }

- (NSValue*)tweenedValueForProgress:(CGFloat)progress {
    
    CGPoint startPoint = self.startCGPoint;
    CGPoint endPoint = self.endCGPoint;
    CGPoint distance = CGPointMake(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
    CGPoint tweenedPoint = CGPointMake(startPoint.x + distance.x * progress, startPoint.y + distance.y * progress);
    
    return [NSValue valueWithCGPoint:tweenedPoint];
    
}

- (void)setProgress:(CGFloat)progress {
    self.tweenedLerp = [self tweenedValueForProgress:progress];
}

@end

@implementation PRTweenCGRectLerpPeriod

+ (id)periodWithStartCGRect:(CGRect)aStartRect endCGRect:(CGRect)anEndRect duration:(CGFloat)duration {
    return [PRTweenCGRectLerpPeriod periodWithStartValue:[NSValue valueWithCGRect:aStartRect] endValue:[NSValue valueWithCGRect:anEndRect] duration:duration];
}

- (CGRect)startCGRect { return [self.startLerp CGRectValue]; }
- (CGRect)tweenedCGRect { return [self.tweenedLerp CGRectValue]; }
- (CGRect)endCGRect { return [self.endLerp CGRectValue]; }

- (NSValue *)tweenedValueForProgress:(CGFloat)progress {
    
    CGRect startRect = self.startCGRect;
    CGRect endRect = self.endCGRect;
    CGRect distance = CGRectMake(endRect.origin.x - startRect.origin.x, endRect.origin.y - startRect.origin.y, endRect.size.width - startRect.size.width, endRect.size.height - startRect.size.height);
    CGRect tweenedRect = CGRectMake(startRect.origin.x + distance.origin.x * progress, startRect.origin.y + distance.origin.y * progress, startRect.size.width + distance.size.width * progress, startRect.size.height + distance.size.height * progress);
    
    return [NSValue valueWithCGRect:tweenedRect];
    
}

- (void)setProgress:(CGFloat)progress {
    self.tweenedLerp = [self tweenedValueForProgress:progress];
}

@end

@interface PRTweenOperation ()
@property (nonatomic) BOOL canUseBuiltAnimation;
@end

@implementation PRTweenOperation
@synthesize period;
@synthesize target;
@synthesize updateSelector;
@synthesize completeSelector;
@synthesize timingFunction;
@synthesize boundRef;
@synthesize boundObject;
@synthesize boundGetter;
@synthesize boundSetter;
@synthesize canUseBuiltAnimation;
@synthesize override;

#if NS_BLOCKS_AVAILABLE
@synthesize updateBlock;
@synthesize completeBlock;
#endif

- (void)dealloc {
#if NS_BLOCKS_AVAILABLE
    [updateBlock release];
    [completeBlock release];
#endif
    [period release];
    [target release];
    [boundObject release];
    [super dealloc];
}

@end

@implementation PRTweenCGPointLerp

+ (PRTweenOperation *)lerp:(id)object property:(NSString *)property from:(CGPoint)from to:(CGPoint)to duration:(CGFloat)duration timingFunction:(PRTweenTimingFunction)timingFunction target:(NSObject *)target completeSelector:(SEL)selector {
    return [PRTween lerp:object property:property period:[PRTweenCGPointLerpPeriod periodWithStartCGPoint:from endCGPoint:to duration:duration] timingFunction:timingFunction target:target completeSelector:selector];
}

+ (PRTweenOperation *)lerp:(id)object property:(NSString *)property from:(CGPoint)from to:(CGPoint)to duration:(CGFloat)duration delay:(CGFloat)delay timingFunction:(PRTweenTimingFunction)timingFunction target:(NSObject *)target completeSelector:(SEL)selector {
    PRTweenCGPointLerpPeriod *period = [PRTweenCGPointLerpPeriod periodWithStartCGPoint:from endCGPoint:to duration:duration];
    period.delay = delay;
    return [PRTween lerp:object property:property period:period timingFunction:timingFunction target:target completeSelector:selector];
}

+ (PRTweenOperation *)lerp:(id)object property:(NSString *)property from:(CGPoint)from to:(CGPoint)to duration:(CGFloat)duration {
    return [PRTweenCGPointLerp lerp:object property:property from:from to:to duration:duration timingFunction:NULL target:nil completeSelector:NULL];
}

#if NS_BLOCKS_AVAILABLE
+ (PRTweenOperation *)lerp:(id)object property:(NSString *)property from:(CGPoint)from to:(CGPoint)to duration:(CGFloat)duration timingFunction:(PRTweenTimingFunction)timingFunction updateBlock:(PRTweenUpdateBlock)updateBlock completeBlock:(PRTweenCompleteBlock)completeBlock {
    return [PRTween lerp:object property:property period:[PRTweenCGPointLerpPeriod periodWithStartCGPoint:from endCGPoint:to duration:duration] timingFunction:timingFunction updateBlock:updateBlock completeBlock:completeBlock];
}
#endif

@end

@implementation PRTweenCGRectLerp

+ (PRTweenOperation *)lerp:(id)object property:(NSString *)property from:(CGRect)from to:(CGRect)to duration:(CGFloat)duration timingFunction:(PRTweenTimingFunction)timingFunction target:(NSObject *)target completeSelector:(SEL)selector {
    return [PRTween lerp:object property:property period:[PRTweenCGRectLerpPeriod periodWithStartCGRect:from endCGRect:to duration:duration] timingFunction:timingFunction target:target completeSelector:selector];
}

+ (PRTweenOperation *)lerp:(id)object property:(NSString *)property from:(CGRect)from to:(CGRect)to duration:(CGFloat)duration delay:(CGFloat)delay timingFunction:(PRTweenTimingFunction)timingFunction target:(NSObject *)target completeSelector:(SEL)selector {
    PRTweenCGRectLerpPeriod *period = [PRTweenCGRectLerpPeriod periodWithStartCGRect:from endCGRect:to duration:duration];
    period.delay = delay;
    return [PRTween lerp:object property:property period:period timingFunction:timingFunction target:target completeSelector:selector];
}

+ (PRTweenOperation *)lerp:(id)object property:(NSString *)property from:(CGRect)from to:(CGRect)to duration:(CGFloat)duration {
    return [PRTweenCGRectLerp lerp:object property:property from:from to:to duration:duration timingFunction:NULL target:nil completeSelector:NULL];
}

#if NS_BLOCKS_AVAILABLE
+ (PRTweenOperation *)lerp:(id)object property:(NSString *)property from:(CGRect)from to:(CGRect)to duration:(CGFloat)duration timingFunction:(PRTweenTimingFunction)timingFunction updateBlock:(PRTweenUpdateBlock)updateBlock completeBlock:(PRTweenCompleteBlock)completeBlock { 
    return [PRTweenCGRectLerp lerp:object property:property from:from to:to duration:duration timingFunction:NULL updateBlock:updateBlock completeBlock:completeBlock];
}
#endif

@end

@interface PRTween ()
+ (SEL)setterFromProperty:(NSString *)property;
- (void)update;
@end

static PRTween *instance = nil;
static NSArray *animationSelectorsForCoreAnimation = nil;
static NSArray *animationSelectorsForUIView = nil;

@implementation PRTween
@synthesize timeOffset;
@synthesize defaultTimingFunction;
@synthesize useBuiltInAnimationsWhenPossible;

+ (PRTween *)sharedInstance {
    if (instance == nil) {
        instance = [[PRTween alloc] init];
        instance.useBuiltInAnimationsWhenPossible = YES;
    }
    return instance;
}

+ (PRTweenOperation *)tween:(id)object property:(NSString*)property from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration timingFunction:(PRTweenTimingFunction)timingFunction target:(NSObject*)target completeSelector:(SEL)selector {
    
    PRTweenPeriod *period = [PRTweenPeriod periodWithStartValue:from endValue:to duration:duration];
    PRTweenOperation *operation = [[PRTweenOperation new] autorelease];
    operation.period = period;
    operation.timingFunction = timingFunction;
    operation.target = target;
    operation.completeSelector = selector;
    operation.boundObject = object;
    operation.boundGetter = NSSelectorFromString([NSString stringWithFormat:@"%@", property]);
    operation.boundSetter = [PRTween setterFromProperty:property];
    [operation addObserver:[PRTween sharedInstance] forKeyPath:@"period.tweenedValue" options:NSKeyValueObservingOptionNew context:NULL];
    
    [[PRTween sharedInstance] performSelector:@selector(addTweenOperation:) withObject:operation afterDelay:0];
    return operation;
    
}

+ (PRTweenOperation *)tween:(CGFloat *)ref from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration timingFunction:(PRTweenTimingFunction)timingFunction target:(NSObject*)target completeSelector:(SEL)selector {
    
    PRTweenPeriod *period = [PRTweenPeriod periodWithStartValue:from endValue:to duration:duration];
    PRTweenOperation *operation = [[PRTweenOperation new] autorelease];
    operation.period = period;
    operation.timingFunction = timingFunction;
    operation.target = target;
    operation.completeSelector = selector;
    operation.boundRef = ref;
    [operation addObserver:[PRTween sharedInstance] forKeyPath:@"period.tweenedValue" options:NSKeyValueObservingOptionNew context:NULL];
    
    [[PRTween sharedInstance] performSelector:@selector(addTweenOperation:) withObject:operation afterDelay:0];
    return operation;
    
}

+ (PRTweenOperation *)tween:(id)object property:(NSString*)property from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration {
    return [PRTween tween:object property:property from:from to:to duration:duration timingFunction:NULL target:nil completeSelector:NULL];
}

+ (PRTweenOperation *)tween:(CGFloat *)ref from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration {
    return [PRTween tween:ref from:from to:to duration:duration timingFunction:NULL target:nil completeSelector:NULL];
}

+ (PRTweenOperation *)lerp:(id)object property:(NSString *)property period:(PRTweenLerpPeriod <PRTweenLerpPeriod> *)period  timingFunction:(PRTweenTimingFunction)timingFunction target:(NSObject *)target completeSelector:(SEL)selector {
    
    //PRTweenPeriod *period = [PRTweenLerpPeriod periodWithStartValue:from endValue:to duration:duration];
    PRTweenOperation *operation = [[PRTweenOperation new] autorelease];
    operation.period = period;
    operation.timingFunction = timingFunction;
    operation.target = target;
    operation.completeSelector = selector;
    operation.boundObject = object;
    operation.boundGetter = NSSelectorFromString([NSString stringWithFormat:@"%@", property]);
    operation.boundSetter = [PRTween setterFromProperty:property];
    [operation addObserver:[PRTween sharedInstance] forKeyPath:@"period.tweenedLerp" options:NSKeyValueObservingOptionNew context:NULL];
    
    [[PRTween sharedInstance] performSelector:@selector(addTweenOperation:) withObject:operation afterDelay:0];
    return operation;
    
}

#if NS_BLOCKS_AVAILABLE
+ (PRTweenOperation *)tween:(id)object property:(NSString*)property from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration timingFunction:(PRTweenTimingFunction)timingFunction updateBlock:(PRTweenUpdateBlock)updateBlock completeBlock:(PRTweenCompleteBlock)completeBlock {
    
    PRTweenPeriod *period = [PRTweenPeriod periodWithStartValue:from endValue:to duration:duration];
    PRTweenOperation *operation = [[PRTweenOperation new] autorelease];
    operation.period = period;
    operation.timingFunction = timingFunction;
    operation.updateBlock = updateBlock;
    operation.completeBlock = completeBlock;
    operation.boundObject = object;
    operation.boundGetter = NSSelectorFromString([NSString stringWithFormat:@"%@", property]);
    operation.boundSetter = [PRTween setterFromProperty:property];
    [operation addObserver:[PRTween sharedInstance] forKeyPath:@"period.tweenedValue" options:NSKeyValueObservingOptionNew context:NULL];
    
    [[PRTween sharedInstance] performSelector:@selector(addTweenOperation:) withObject:operation afterDelay:0];
    return operation;
    
}

+ (PRTweenOperation *)tween:(CGFloat *)ref from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration timingFunction:(PRTweenTimingFunction)timingFunction updateBlock:(PRTweenUpdateBlock)updateBlock completeBlock:(PRTweenCompleteBlock)completeBlock {
    
    PRTweenPeriod *period = [PRTweenPeriod periodWithStartValue:from endValue:to duration:duration];
    PRTweenOperation *operation = [[PRTweenOperation new] autorelease];
    operation.period = period;
    operation.timingFunction = timingFunction;
    operation.updateBlock = updateBlock;
    operation.completeBlock = completeBlock;
    operation.boundRef = ref;
    [operation addObserver:[PRTween sharedInstance] forKeyPath:@"period.tweenedValue" options:NSKeyValueObservingOptionNew context:NULL];
    
    [[PRTween sharedInstance] performSelector:@selector(addTweenOperation:) withObject:operation afterDelay:0];
    return operation;
    
}

+ (PRTweenOperation *)lerp:(id)object property:(NSString *)property period:(PRTweenLerpPeriod <PRTweenLerpPeriod> *)period  timingFunction:(PRTweenTimingFunction)timingFunction updateBlock:(PRTweenUpdateBlock)updateBlock completeBlock:(PRTweenCompleteBlock)completeBlock {
    
    //PRTweenPeriod *period = [PRTweenLerpPeriod periodWithStartValue:from endValue:to duration:duration];
    PRTweenOperation *operation = [[PRTweenOperation new] autorelease];
    operation.period = period;
    operation.timingFunction = timingFunction;
    operation.updateBlock = updateBlock;
    operation.completeBlock = completeBlock;
    operation.boundObject = object;
    operation.boundGetter = NSSelectorFromString([NSString stringWithFormat:@"%@", property]);
    operation.boundSetter = [PRTween setterFromProperty:property];
    [operation addObserver:[PRTween sharedInstance] forKeyPath:@"period.tweenedLerp" options:NSKeyValueObservingOptionNew context:NULL];
    
    [[PRTween sharedInstance] performSelector:@selector(addTweenOperation:) withObject:operation afterDelay:0];
    return operation;
    
}
#endif

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    PRTweenOperation *operation = (PRTweenOperation*)object;
    
    if ([operation.period isKindOfClass:[PRTweenLerpPeriod class]]) {
        PRTweenLerpPeriod *lerpPeriod = (PRTweenLerpPeriod*)operation.period;
        
        NSUInteger bufferSize = 0;
        NSGetSizeAndAlignment([lerpPeriod.tweenedLerp objCType], &bufferSize, NULL);
        void *tweenedValue = malloc(bufferSize);
        [lerpPeriod.tweenedLerp getValue:tweenedValue];
        
        if (operation.boundObject && [operation.boundObject respondsToSelector:operation.boundGetter] && [operation.boundObject respondsToSelector:operation.boundSetter]) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[operation.boundObject class] instanceMethodSignatureForSelector:operation.boundSetter]];
            [invocation setTarget:operation.boundObject];
            [invocation setSelector:operation.boundSetter];
            [invocation setArgument:tweenedValue atIndex:2];
            [invocation invoke];
        }
        
        free(tweenedValue);
        
    } else {
        
        CGFloat tweenedValue = operation.period.tweenedValue;
        
        if (operation.boundObject && [operation.boundObject respondsToSelector:operation.boundGetter] && [operation.boundObject respondsToSelector:operation.boundSetter]) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[operation.boundObject class] instanceMethodSignatureForSelector:operation.boundSetter]];
            [invocation setTarget:operation.boundObject];
            [invocation setSelector:operation.boundSetter];
            [invocation setArgument:&tweenedValue atIndex:2];
            [invocation invoke];
        } else if (operation.boundRef) {
            *operation.boundRef = tweenedValue;
        }
        
    }
    
}

- (id)init {
    self = [super init];
    
    if (self != nil) {
        NSLog(@"jingInit");
        
        tweenOperations = [[NSMutableArray alloc] init];
        expiredTweenOperations = [[NSMutableArray alloc] init];
        timeOffset = 0;
        if (timer == nil) {
            timer = [NSTimer scheduledTimerWithTimeInterval:kPRTweenFramerate target:self selector:@selector(update) userInfo:nil repeats:YES];
        }
        self.defaultTimingFunction = &PRTweenTimingFunctionQuadInOut;
    }
    return self;
}

- (PRTweenOperation*)addTweenOperation:(PRTweenOperation*)operation {
    NSLog(@"jing1");
    if (useBuiltInAnimationsWhenPossible && !operation.override) {
    
        if (animationSelectorsForCoreAnimation == nil) {
            animationSelectorsForCoreAnimation = [[NSArray alloc] initWithObjects:
                                      @"setBounds:",            // CGRect
                                      @"setPosition:",          // CGPoint
                                      @"setZPosition:",         // CGFloat
                                      @"setAnchorPoint:",       // CGPoint
                                      @"setAnchorPointZ:",      // CGFloat
                                      //@"setTransform:",         // CATransform3D
                                      //@"setSublayerTransform:", // CATransform3D
                                      @"setFrame:",             // CGRect
                                      @"setContentsRect"        // CGRect
                                      @"setContentsScale:",     // CGFloat
                                      @"setContentsCenter:",    // CGPoint
                                      //@"setBackgroundColor:",   // CGColorRef
                                      @"setCornerRadius:",      // CGFloat
                                      @"setBorderWidth:",       // CGFloat
                                      @"setOpacity:",           // CGFloat
                                      //@"setShadowColor:",       // CGColorRef
                                      @"setShadowOpacity:",     // CGFloat
                                      @"setShadowOffset:",      // CGSize
                                      @"setShadowRadius:",      // CGFloat
                                      //@"setShadowPath:",
                                      nil];
            NSLog(@"jing2");
        }
        
        if (animationSelectorsForUIView == nil) {
            animationSelectorsForUIView = [[NSArray alloc] initWithObjects:
                                        @"setFrame:",           // CGRect
                                        @"setBounds:",          // CGRect
                                        @"setCenter:",          // CGPoint
                                        @"setTransform:",       // CGAffineTransform
                                        @"setAlpha:",           // CGFloat
                                        //@"setBackgroundColor:", // UIColor
                                        @"setContentStretch:",  // CGRect
                                        nil];
            NSLog(@"jing3");
        }
        
        if (operation.boundSetter && operation.boundObject &&
            
            !(operation.timingFunction == &PRTweenTimingFunctionCADefault ||
                                                                operation.timingFunction == &PRTweenTimingFunctionCAEaseIn ||
                                                                operation.timingFunction == &PRTweenTimingFunctionCAEaseOut ||
                                                                operation.timingFunction == &PRTweenTimingFunctionCAEaseInOut ||
                                                                operation.timingFunction == &PRTweenTimingFunctionCALinear ||
                                                                operation.timingFunction == &PRTweenTimingFunctionUIViewEaseIn ||
                                                                operation.timingFunction == &PRTweenTimingFunctionUIViewEaseOut ||
                                                                operation.timingFunction == &PRTweenTimingFunctionUIViewEaseInOut ||
                                                                operation.timingFunction == &PRTweenTimingFunctionUIViewLinear || 
                                                                operation.timingFunction == NULL))
        {
            NSLog(@"jing4");//if中的条件都不符合
            goto complete;
        }
                                                               
        
        if (operation.boundSetter && operation.boundObject && [operation.boundObject isKindOfClass:[CALayer class]]) {
            NSLog(@"jing5");//不满足
            for (NSString *selector in animationSelectorsForCoreAnimation) {
                NSString *setter = NSStringFromSelector(operation.boundSetter);
                if ([selector isEqualToString:setter]) {
                    NSLog(@"Using Core Animation for %@", NSStringFromSelector(operation.boundSetter));
                    operation.canUseBuiltAnimation = YES;
                    
                    NSString *propertyUnformatted = [selector stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
                    NSString *propertyFormatted = [[propertyUnformatted stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[propertyUnformatted substringToIndex:1] lowercaseString]] substringToIndex:[propertyUnformatted length] - 1];
                    //NSLog(@"%@", propertyFormatted);
                    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:propertyFormatted];
                    animation.duration = operation.period.duration;
                    
                    if (![operation.period isKindOfClass:[PRTweenLerpPeriod class]] && ![operation.period conformsToProtocol:@protocol(PRTweenLerpPeriod)]) {
                        animation.fromValue = [NSNumber numberWithFloat:operation.period.startValue];
                        animation.toValue = [NSNumber numberWithFloat:operation.period.endValue];
                    } else {
                        PRTweenLerpPeriod *period = (PRTweenLerpPeriod*)operation.period;
                        animation.fromValue = period.startLerp;
                        animation.toValue = period.endLerp;
                    }
                    
                    if (operation.timingFunction == &PRTweenTimingFunctionCAEaseIn) {
                        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                    } else if (operation.timingFunction == &PRTweenTimingFunctionCAEaseOut) {
                        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                    } else if (operation.timingFunction == &PRTweenTimingFunctionCAEaseInOut) {
                        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    } else if (operation.timingFunction == &PRTweenTimingFunctionCALinear) {
                        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                    } else {
                        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
                    }
                    
                    [operation.boundObject setValue:animation.toValue forKeyPath:propertyFormatted];
                    [operation.boundObject addAnimation:animation forKey:@"PRTweenCAAnimation"];
                    
                    goto complete;
                }
            }
        } else if (operation.boundSetter && operation.boundObject && [operation.boundObject isKindOfClass:[UIView class]]) {
            NSLog(@"jing6");//不满足
            for (NSString *selector in animationSelectorsForUIView) {
                NSString *setter = NSStringFromSelector(operation.boundSetter);
                if ([selector isEqualToString:setter]) {
                    NSLog(@"Using UIView Animation for %@", NSStringFromSelector(operation.boundSetter));
                    operation.canUseBuiltAnimation = YES;
                    
                    NSString *propertyUnformatted = [selector stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
                    NSString *propertyFormatted = [[propertyUnformatted stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[propertyUnformatted substringToIndex:1] lowercaseString]] substringToIndex:[propertyUnformatted length] - 1];
                    
                    NSValue *fromValue = nil;
                    NSValue *toValue = nil;
                    
                    if (![operation.period isKindOfClass:[PRTweenLerpPeriod class]] && ![operation.period conformsToProtocol:@protocol(PRTweenLerpPeriod)]) {
                        fromValue = [NSNumber numberWithFloat:operation.period.startValue];
                        toValue = [NSNumber numberWithFloat:operation.period.endValue];
                    } else {
                        PRTweenLerpPeriod *period = (PRTweenLerpPeriod*)operation.period;
                        fromValue = period.startLerp;
                        toValue = period.endLerp;
                    }
                    
                    [operation.boundObject setValue:fromValue forKeyPath:propertyFormatted];
                    [UIView beginAnimations:nil context:NULL];
                    [UIView setAnimationDuration:operation.period.duration];
                    
                    if (operation.timingFunction == &PRTweenTimingFunctionUIViewEaseIn) {
                        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                    } else if (operation.timingFunction == &PRTweenTimingFunctionUIViewEaseOut) {
                        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                    } else if (operation.timingFunction == &PRTweenTimingFunctionUIViewEaseInOut) {
                       [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    } else if (operation.timingFunction == &PRTweenTimingFunctionUIViewLinear) {
                        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
                    }
                    
                    [operation.boundObject setValue:toValue forKeyPath:propertyFormatted];
                    [UIView commitAnimations];
                    
                    goto complete;
                }
            }
        }
        
    }
    
complete:
    [tweenOperations addObject:operation];
    NSLog(@"jing7");
    return operation;
}

#if NS_BLOCKS_AVAILABLE
- (PRTweenOperation*)addTweenPeriod:(PRTweenPeriod *)period 
                        updateBlock:(void (^)(PRTweenPeriod *period))updateBlock 
                    completionBlock:(void (^)())completeBlock {
    return [self addTweenPeriod:period updateBlock:updateBlock completionBlock:completeBlock timingFunction:self.defaultTimingFunction];
}

- (PRTweenOperation*)addTweenPeriod:(PRTweenPeriod *)period 
                        updateBlock:(void (^)(PRTweenPeriod *period))anUpdateBlock 
                    completionBlock:(void (^)())completeBlock 
                     timingFunction:(PRTweenTimingFunction)timingFunction {
    
    PRTweenOperation *tweenOperation = [[PRTweenOperation new] autorelease];
    tweenOperation.period = period;
    tweenOperation.timingFunction = timingFunction;
    tweenOperation.updateBlock = anUpdateBlock;
    tweenOperation.completeBlock = completeBlock;
    return [self addTweenOperation:tweenOperation];
    
}
#endif

- (PRTweenOperation*)addTweenPeriod:(PRTweenPeriod *)period target:(NSObject *)target selector:(SEL)selector {
    return [self addTweenPeriod:period target:target selector:selector timingFunction:self.defaultTimingFunction];
}

- (PRTweenOperation*)addTweenPeriod:(PRTweenPeriod *)period target:(NSObject *)target selector:(SEL)selector timingFunction:(PRTweenTimingFunction)timingFunction {
    
    PRTweenOperation *tweenOperation = [[PRTweenOperation new] autorelease];
    tweenOperation.period = period;
    tweenOperation.target = target;
    tweenOperation.timingFunction = timingFunction;
    tweenOperation.updateSelector = selector;
    
    return [self addTweenOperation:tweenOperation];
    
}

- (void)removeTweenOperation:(PRTweenOperation *)tweenOperation {
    if (tweenOperation != nil) {
        if ([tweenOperations containsObject:tweenOperation]) {
            [expiredTweenOperations addObject:tweenOperation];
        }
    }
}

+ (SEL)setterFromProperty:(NSString *)property {
    return NSSelectorFromString([NSString stringWithFormat:@"set%@:", [property stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[property substringToIndex:1] capitalizedString]]]);
}

- (void)update {
    timeOffset += kPRTweenFramerate;
    
    //NSLog(@"jing8");//满足
    
    for (PRTweenOperation *tweenOperation in tweenOperations) {
        
        PRTweenPeriod *period = tweenOperation.period;
        
        // if operation is delayed, pass over it for now
        if (timeOffset <= period.startOffset + period.delay) {
            continue;
            NSLog(@"jing9");//不满足
        }
        
        CGFloat (*timingFunction)(CGFloat, CGFloat, CGFloat, CGFloat) = tweenOperation.timingFunction;
        
        if (timingFunction == NULL) {
            timingFunction = self.defaultTimingFunction;
            NSLog(@"jing10");//不满足
        }
        
        if (timingFunction != NULL && tweenOperation.canUseBuiltAnimation == NO) {
            //NSLog(@"jing11");//满足
            if (timeOffset <= period.startOffset + period.delay + period.duration) {
                //NSLog(@"jing9");//满足
                if ([period isKindOfClass:[PRTweenLerpPeriod class]]) {
                    NSLog(@"jing9");//不满足
                    if ([period conformsToProtocol:@protocol(PRTweenLerpPeriod)]) {
                        PRTweenLerpPeriod <PRTweenLerpPeriod> *lerpPeriod = (PRTweenLerpPeriod <PRTweenLerpPeriod> *)period;
                        CGFloat progress = timingFunction(timeOffset - period.startOffset - period.delay, 0.0, 1.0, period.duration);
                        [lerpPeriod setProgress:progress];
                        
                    } else {
                        // @TODO: Throw exception
                        NSLog(@"Class doesn't conform to PRTweenLerp");
                    }
                } else {
                    //NSLog(@"jing9");//满足
                    
                    // if tween operation is valid, calculate tweened value using timing function
                    period.tweenedValue =
                    timingFunction(
        timeOffset - period.startOffset - period.delay,
        period.startValue,
        period.endValue - period.startValue,
        period.duration);
                    
                    NSLog(@"%f=%f",timeOffset,period.tweenedValue);
                    //NSLog(@"%f",period.duration);//
                    //period.tweenedValue表示变化值
                    
                    //timeOffset表示时间值，每次update增加1/60
                    //period.startOffset 始终为0
                    //period.delay 始终为0
                    
                    //period.startValue 始终为0
                    //period.endValue始终为504
                    //period.duration始终为1.5
                }
            } else {
                // move expired tween operations to list for cleanup
                NSLog(@"jing11");//满足一次
                period.tweenedValue = period.endValue;
                [expiredTweenOperations addObject:tweenOperation];
            }
            
            NSObject *target = tweenOperation.target;
            SEL selector = tweenOperation.updateSelector;
            
            if (period != nil) {
                if (target != nil && selector != NULL) {
                     //NSLog(@"jing1");//满足
                    [target performSelector:selector withObject:period afterDelay:0];    
                }
                
                // Check to see if blocks/GCD are supported
                if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_4_0) {
                    // fire off update block
                    if (tweenOperation.updateBlock != NULL) {
                        tweenOperation.updateBlock(period);
                    } 
                }
            }
        } else if (tweenOperation.canUseBuiltAnimation == YES) {
            NSLog(@"jingjing");//不满足
            if (timeOffset > period.startOffset + period.delay + period.duration) {
                [expiredTweenOperations addObject:tweenOperation];
            }
        }
    }
    
    // clean up expired tween operations
    for (PRTweenOperation *tweenOperation in expiredTweenOperations) {
        
        NSLog(@"jing99");
        
        if (tweenOperation.completeSelector) [tweenOperation.target performSelector:tweenOperation.completeSelector withObject:nil afterDelay:0];
        // Check to see if blocks/GCD are supported
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_4_0) {        
            if (tweenOperation.completeBlock != NULL) {
                tweenOperation.completeBlock();
            }
        }

        // @HACK: Come up with a better pattern for removing observers.
        @try {
            [tweenOperation removeObserver:[PRTween sharedInstance] forKeyPath:@"period.tweenedValue"];
        } @catch (id exception) {
        }
        @try {
            [tweenOperation removeObserver:[PRTween sharedInstance] forKeyPath:@"period.tweenedLerp"];
        } @catch (id exception) {
        }
        
        [tweenOperations removeObject:tweenOperation];
        tweenOperation = nil;
    }
    [expiredTweenOperations removeAllObjects];
}

- (void)dealloc {
    [tweenOperations release];
    [expiredTweenOperations release];
    [timer invalidate];
    
    [super dealloc];
}

@end

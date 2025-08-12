// RCTBlurView.mm

#import "RCTBlurView.h"

#import <react/renderer/components/AppSpec/ComponentDescriptors.h>
#import <react/renderer/components/AppSpec/EventEmitters.h>
#import <react/renderer/components/AppSpec/Props.h>
#import <react/renderer/components/AppSpec/RCTComponentViewHelpers.h>

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// MARK: - Private API hook
@interface UIBlurEffect (Private)
- (id)effectSettings;
@end

using namespace facebook::react;

// MARK: - Defaults

static inline UIBlurEffectStyle const kDefaultBlurStyle = UIBlurEffectStyleLight;
static inline CGFloat const kDefaultBlurRadius = 6.0;

// MARK: - Custom Effect Subclass (blur radius only)

@interface RNCustomBlurEffect : UIBlurEffect
@property (nonatomic, strong, nullable) NSNumber *blurRadius;
+ (instancetype)effectWithStyle:(UIBlurEffectStyle)style
                     blurRadius:(nullable NSNumber *)radius;
@end

@implementation RNCustomBlurEffect

+ (instancetype)effectWithStyle:(UIBlurEffectStyle)style
                     blurRadius:(NSNumber * _Nullable)radius
{
  id base = [super effectWithStyle:style]; // create a genuine effect
  object_setClass(base, self);             // swap class at runtime

  RNCustomBlurEffect *effect = base;
  effect.blurRadius = radius;
  return effect;
}

// Associated storage for blur radius
- (void)setBlurRadius:(NSNumber * _Nullable)radius {
  objc_setAssociatedObject(self, @selector(blurRadius),
                           radius, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSNumber * _Nullable)blurRadius {
  return objc_getAssociatedObject(self, @selector(blurRadius));
}

/**
 Called by the system. We inject only the blur radius here.
 */
- (id)effectSettings
{
  id settings = [super effectSettings];
  if (self.blurRadius != nil) {
    [settings setValue:self.blurRadius forKey:@"blurRadius"];
  }
  return settings;
}

- (id)copyWithZone:(NSZone *)zone
{
  id copy = [super copyWithZone:zone];
  object_setClass(copy, [self class]); // preserve subclass

  objc_setAssociatedObject(copy, @selector(blurRadius),
                           self.blurRadius, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  return copy;
}

@end

// MARK: - Fabric View

@interface RCTBlurView () <RCTIOSBlurViewViewProtocol>
@end

@implementation RCTBlurView {
  UIVisualEffectView *_blurView;
}

#pragma mark - Lifecycle

- (instancetype)init
{
  if (self = [super init]) {
    _blurView = [[UIVisualEffectView alloc] initWithEffect:nil];
    _blurView.alpha = 1.0;
    [self addSubview:_blurView];

    _blurView.effect = [self buildDefaultEffect];
  }
  return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
  [super layoutSubviews];
  _blurView.frame = self.bounds;
}

#pragma mark - Fabric plumbing

- (void)updateProps:(Props::Shared const &)props
          oldProps:(Props::Shared const &)oldProps
{
  [super updateProps:props oldProps:oldProps];
}

- (const IOSBlurViewEventEmitter &)eventEmitter
{
  return static_cast<const IOSBlurViewEventEmitter &>(*_eventEmitter);
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<IOSBlurViewComponentDescriptor>();
}

#pragma mark - Helpers

- (UIBlurEffect *)buildDefaultEffect
{
  return [RNCustomBlurEffect effectWithStyle:kDefaultBlurStyle
                                  blurRadius:@(kDefaultBlurRadius)];
}

@end

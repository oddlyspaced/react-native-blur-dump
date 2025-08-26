// RCTBlurView.mm

#import "RCTBlurView.h"

#import <react/renderer/components/AppSpec/ComponentDescriptors.h>
#import <react/renderer/components/AppSpec/EventEmitters.h>
#import <react/renderer/components/AppSpec/Props.h>
#import <react/renderer/components/AppSpec/RCTComponentViewHelpers.h>

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface UIBlurEffect (Private)
- (id)effectSettings;
@end

using namespace facebook::react;

// MARK: - Defaults

static inline UIBlurEffectStyle const kDefaultBlurStyle = UIBlurEffectStyleLight;
static inline CGFloat const kDefaultBlurRadius = 6.0;

// MARK: - KVC-safe helper

static inline void RNSetSetting(id settings, NSString *key, id value) {
  @try {
    [settings setValue:value forKey:key];
  } @catch (__unused NSException *e) {
    // Silently ignore unknown keys on different iOS versions
  }
}

// MARK: - Custom Effect Subclass

@interface RNCustomBlurEffect : UIBlurEffect
@property (nonatomic, strong, nullable) NSNumber *blurRadius;
+ (instancetype)effectWithStyle:(UIBlurEffectStyle)style
                     blurRadius:(nullable NSNumber *)radius;
@end

@implementation RNCustomBlurEffect

+ (instancetype)effectWithStyle:(UIBlurEffectStyle)style
                     blurRadius:(NSNumber * _Nullable)radius
{
  id base = [super effectWithStyle:style];
  object_setClass(base, self);
  RNCustomBlurEffect *effect = base;
  effect.blurRadius = radius;
  return effect;
}

- (void)setBlurRadius:(NSNumber * _Nullable)radius {
  objc_setAssociatedObject(self, @selector(blurRadius),
                           radius, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSNumber * _Nullable)blurRadius {
  return objc_getAssociatedObject(self, @selector(blurRadius));
}

- (id)effectSettings
{
  id settings = [super effectSettings];

  // Keep blur radius if provided
  if (self.blurRadius != nil) {
    RNSetSetting(settings, @"blurRadius", self.blurRadius);
  }

  // Remove built-in tint/luminance overlays so our custom tint is clean
  RNSetSetting(settings, @"grayscaleTintAlpha", @0);
  RNSetSetting(settings, @"luminanceAlpha", @0);
  RNSetSetting(settings, @"colorTintAlpha", @0);
  RNSetSetting(settings, @"colorTint", UIColor.clearColor);
  RNSetSetting(settings, @"tintColor", (id)kCFNull);
  RNSetSetting(settings, @"saturationDeltaFactor", @1.0);

  return settings;
}

- (id)copyWithZone:(NSZone *)zone
{
  id copy = [super copyWithZone:zone];
  object_setClass(copy, [self class]);
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
  UIView *_tintOverlay;
}

- (instancetype)init
{
  if (self = [super init]) {
    _blurView = [[UIVisualEffectView alloc] initWithEffect:nil];
    _blurView.alpha = 1.0;

    // Clear backgrounds to let blur/tint read underlying content
    _blurView.backgroundColor = UIColor.clearColor;
    _blurView.contentView.backgroundColor = UIColor.clearColor;
    self.backgroundColor = UIColor.clearColor;

    [self addSubview:_blurView];

    // 50% cyan (#00ffff) tint overlay above the blur
    _tintOverlay = [UIView new];
    _tintOverlay.userInteractionEnabled = NO;
    _tintOverlay.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.05];
    [self addSubview:_tintOverlay];

    // initial effect
    _blurView.effect = [self buildDefaultEffect];
  }
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  _blurView.frame = self.bounds;
  _tintOverlay.frame = self.bounds;
  [self bringSubviewToFront:_tintOverlay];
}

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

- (UIBlurEffect *)buildDefaultEffect
{
  return [RNCustomBlurEffect effectWithStyle:kDefaultBlurStyle
                                  blurRadius:@(kDefaultBlurRadius)];
}

@end

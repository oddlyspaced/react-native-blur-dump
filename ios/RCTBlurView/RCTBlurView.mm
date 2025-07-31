// RCTBlurView.mm
#import "RCTBlurView.h"

#import <react/renderer/components/AppSpec/ComponentDescriptors.h>
#import <react/renderer/components/AppSpec/EventEmitters.h>
#import <react/renderer/components/AppSpec/Props.h>
#import <react/renderer/components/AppSpec/RCTComponentViewHelpers.h>

#import <UIKit/UIKit.h>
#import <objc/runtime.h>           // object_setClass, assoc. objects

@interface UIBlurEffect (Private)
- (id)effectSettings;
@end

using namespace facebook::react;

#pragma mark - Private Blur-Effect Subclass
//
// Mirrors logic in @react-native-community/blur’s
//   BlurEffectWithAmount.m
//
@interface RNCustomBlurEffect : UIBlurEffect
@property (nonatomic,strong) NSNumber *blurRadius;
@property (nonatomic,strong) UIColor  *colorTint;
@end

@implementation RNCustomBlurEffect
@dynamic blurRadius, colorTint;

+ (instancetype)effectWithStyle:(UIBlurEffectStyle)style
                     blurRadius:(NSNumber *)radius
                      colorTint:(UIColor  *)tint
{
  // 1. Create a *real* UIBlurEffect first …
  id instance = [super effectWithStyle:style];
  // 2. …then swap its class to our subclass at runtime.
  object_setClass(instance, self);

  RNCustomBlurEffect *effect = instance;
  effect.blurRadius = radius;
  effect.colorTint  = tint;
  return effect;
}

// store / retrieve properties via objc-runtime
- (void)setBlurRadius:(NSNumber *)radius {
  objc_setAssociatedObject(self, @selector(blurRadius),
                           radius, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSNumber *)blurRadius {
  return objc_getAssociatedObject(self, @selector(blurRadius));
}
- (void)setColorTint:(UIColor *)tint {
  objc_setAssociatedObject(self, @selector(colorTint),
                           tint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIColor *)colorTint {
  return objc_getAssociatedObject(self, @selector(colorTint));
}

/**
 * Private entry-point used inside CoreAnimation.
 * We inject our radius & tint here.
 */
- (id)effectSettings
{
  id settings = [super effectSettings];          // real settings object

  if (self.blurRadius) {
    [settings setValue:self.blurRadius forKey:@"blurRadius"];
  }
  if (self.colorTint) {
    [settings setValue:self.colorTint            forKey:@"colorTint"];
    [settings setValue:@(1.0)                    forKey:@"colorTintAlpha"];
  }
  return settings;
}

- (id)copyWithZone:(NSZone *)zone
{
  id copy = [super copyWithZone:zone];
  object_setClass(copy, [self class]);           // preserve subclass
  objc_setAssociatedObject(copy, @selector(blurRadius),
                           self.blurRadius, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(copy, @selector(colorTint),
                           self.colorTint,  OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  return copy;
}
@end


#pragma mark - Fabric View

@interface RCTBlurView () <RCTIOSBlurViewViewProtocol>
@end

@implementation RCTBlurView {
  UIVisualEffectView *_blurView;
}

- (instancetype)init
{
  if (self = [super init]) {

    // Build the customised effect **before** attaching it to the view.
    UIBlurEffect *effect =
      [RNCustomBlurEffect effectWithStyle:UIBlurEffectStyleLight
                               blurRadius:@1
                                colorTint:[UIColor colorWithRed:0
                                                           green:1
                                                            blue:0
                                                           alpha:1]];

    // Create the blur view *without* an effect first
    _blurView = [[UIVisualEffectView alloc] initWithEffect:nil];
    _blurView.alpha = 1.0;               // overall opacity
    [self addSubview:_blurView];

    // Now assign the mutated effect – ensures CoreImage rebuilds shader
    _blurView.effect = effect;
  }
  return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
  [super layoutSubviews];
  _blurView.frame = self.bounds;
}

#pragma mark - Fabric Boilerplate

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

@end

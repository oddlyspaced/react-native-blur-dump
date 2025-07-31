// RCTBlurView.mm

#import "RCTBlurView.h"

// Fabric-generated headers for this component.
// (Codegen will produce these when you add RCTBlurView to your JS schema.)
#import <react/renderer/components/AppSpec/ComponentDescriptors.h>
#import <react/renderer/components/AppSpec/EventEmitters.h>
#import <react/renderer/components/AppSpec/Props.h>
#import <react/renderer/components/AppSpec/RCTComponentViewHelpers.h>

#import <UIKit/UIKit.h>

using namespace facebook::react;

@interface RCTBlurView () <RCTIOSBlurViewViewProtocol>
@end

@implementation RCTBlurView {
  UIVisualEffectView *_blurView; // The actual blur view
}

#pragma mark - Init

- (instancetype)init
{
  if (self = [super init]) {
    // Always use a light blur effect
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];

    _blurView = [[UIVisualEffectView alloc] initWithEffect:effect];

    /**
     * “Amount” ≈ opacity for our purposes.
     * 1.0 feels like roughly a “10” on a 0-10 scale.
     * Tune this if you want a stronger or lighter blur.
     */
    _blurView.alpha = 1.0;

    [self addSubview:_blurView];
  }
  return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
  [super layoutSubviews];
  _blurView.frame = self.bounds; // Fill the host view
}

#pragma mark - Props (none)

/// You’re not sending any props, but Fabric still calls this.
/// Simply forward to super so Fabric can do its bookkeeping.
- (void)updateProps:(Props::Shared const &)props
          oldProps:(Props::Shared const &)oldProps
{
  [super updateProps:props oldProps:oldProps];
}

#pragma mark - Event Emitter (optional)

/// Not emitting any events, but Fabric expects a typed accessor.
- (const IOSBlurViewEventEmitter &)eventEmitter
{
  return static_cast<const IOSBlurViewEventEmitter &>(*_eventEmitter);
}

#pragma mark - Descriptor Provider

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<IOSBlurViewComponentDescriptor>();
}

@end

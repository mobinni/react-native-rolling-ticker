#import "RollingTickerView.h"
#import <React/RCTViewManager.h>

@interface RollingTickerViewManager : RCTViewManager
@end

@implementation RollingTickerViewManager

RCT_EXPORT_MODULE(RollingTickerView)

- (UIView *)view
{
  return [[UIView alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(color, NSString)
RCT_EXPORT_VIEW_PROPERTY(value, NSString)

@end

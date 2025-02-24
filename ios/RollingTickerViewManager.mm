#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "RCTBridge.h"

@interface RollingTickerViewManager : RCTViewManager
@end

@implementation RollingTickerViewManager

RCT_EXPORT_MODULE(RollingTickerView)

- (UIView *)view
{
  return [[UIView alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(color, NSString)

@end

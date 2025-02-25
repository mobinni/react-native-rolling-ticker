#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

#ifndef RollingTickerViewNativeComponent_h
#define RollingTickerViewNativeComponent_h

NS_ASSUME_NONNULL_BEGIN


@interface RollingTickerView : RCTViewComponentView

@property (nonatomic, strong) UILabel *label;

@end

NS_ASSUME_NONNULL_END

#endif /* RollingTickerViewNativeComponent_h */

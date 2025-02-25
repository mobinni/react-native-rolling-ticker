#import "RollingTickerView.h"
#import "generated/RNRollingTickerViewSpec/ComponentDescriptors.h"
#import "generated/RNRollingTickerViewSpec/EventEmitters.h"
#import "generated/RNRollingTickerViewSpec/Props.h"
#import "generated/RNRollingTickerViewSpec/RCTComponentViewHelpers.h"
#import "RCTFabricComponentsPlugins.h"
#import <QuartzCore/QuartzCore.h>

using namespace facebook::react;

@interface RollingTickerView () <RCTRollingTickerViewViewProtocol>
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *previousValue;
@end

@implementation RollingTickerView {
    UIView * _view;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider {
    return concreteComponentDescriptorProvider<RollingTickerViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        static const auto defaultProps = std::make_shared<const RollingTickerViewProps>();
        _props = defaultProps;
        _view = [[UIView alloc] init];
      _value = @"0";

        self.contentView = _view;
        self.clipsToBounds = YES; // Ensure subviews are clipped to the bounds
    }
    return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps {
    const auto &oldViewProps = *std::static_pointer_cast<RollingTickerViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<RollingTickerViewProps const>(props);

    NSString *newValue = [NSString stringWithUTF8String:oldViewProps.value.c_str()];

    [self setValue: newValue];
    [super updateProps:props oldProps:oldProps];
}

// Helper function to split value into digits and non-digits
- (NSArray *)splitValue:(NSString *)value {
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < value.length; i++) {
        unichar character = [value characterAtIndex:i];
        NSString *charString = [NSString stringWithFormat:@"%C", character];
        if ([charString rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound) {
            [result addObject:@{@"type": @"digit", @"value": charString}];
        } else {
            [result addObject:@{@"type": @"non-digit", @"value": charString}];
        }
    }
    return result;
}

- (void)animateRollingForLabel:(UILabel *)label fromDigit:(NSInteger)fromDigit toDigit:(NSInteger)toDigit isIncrease:(BOOL)isIncrease {
    CGFloat labelHeight = label.frame.size.height;
    
    label.text =  [NSString stringWithFormat:@"%ld", (long)fromDigit];
    // Create a new label for the new digit (temporary label for the next value)
    UILabel *newDigitLabel = [[UILabel alloc] initWithFrame:label.frame];
    newDigitLabel.text = [NSString stringWithFormat:@"%ld", (long)toDigit];
    newDigitLabel.font = label.font;
    newDigitLabel.textAlignment = NSTextAlignmentCenter;
    newDigitLabel.layer.masksToBounds = YES;
    
    newDigitLabel.layer.position = CGPointMake(label.layer.position.x, label.frame.origin.y); // Position below
    
    // Add the new label to the view hierarchy
    [self addSubview:newDigitLabel];

    // Animation for rolling out the old digit (opposite direction of the new digit)
    CABasicAnimation *rollOutAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
  rollOutAnimation.fromValue = isIncrease ? @(labelHeight * 2) : @(-labelHeight * 2);
    rollOutAnimation.toValue = isIncrease ? @(labelHeight) : @(-labelHeight); // Roll out down or up (opposite of new direction)
    rollOutAnimation.duration = 0.5;
    rollOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    rollOutAnimation.fillMode = kCAFillModeForwards;
    rollOutAnimation.removedOnCompletion = NO;
    
    // Animation for rolling in the new digit (opposite direction of the old digit)
    CABasicAnimation *rollInAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    rollInAnimation.fromValue = isIncrease ? @(-labelHeight) : @(labelHeight);  // Start from the opposite direction of the new digit
    rollInAnimation.toValue = @(0); // Move to the final position
    rollInAnimation.duration = 0.5;
    rollInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    rollInAnimation.fillMode = kCAFillModeForwards;
    rollInAnimation.removedOnCompletion = NO;
    
    // Apply the roll-out animation to the current label
    [label.layer addAnimation:rollOutAnimation forKey:@"rollOut"];
    
    // Apply the roll-in animation to the new label (next value)
    [newDigitLabel.layer addAnimation:rollInAnimation forKey:@"rollIn"];
    
    // After the roll-out animation finishes, update the label's text to the new digit and remove the extra label
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(rollOutAnimation.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        label.text = [NSString stringWithFormat:@"%ld", (long)toDigit];
        // Remove the extra label after the animation is complete
//        [newDigitLabel removeFromSuperview];
    });
}
// Update the view with digits and animate
- (void)updateView {
    NSArray *digits = [self splitValue:self.value];
    NSArray *previousDigits = [self splitValue:self.previousValue];
    
    // If either array is empty, skip processing
    if (digits.count == 0 || previousDigits.count == 0) {
        return;
    }
    
    CGFloat xPosition = 0;
    
    // Clear existing subviews before adding new ones
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    // Ensure both arrays have the same number of digits
    NSInteger maxDigitsCount = MAX(digits.count, previousDigits.count);
    for (NSInteger i = 0; i < maxDigitsCount; i++) {
        NSDictionary *item = digits[i];
        NSDictionary *previousItem = (i < previousDigits.count) ? previousDigits[i] : nil;
        
        NSString *type = item[@"type"];
        NSString *value = item[@"value"];
        UILabel *digitLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPosition, 0, 30, 40)];
        digitLabel.text = value;
        digitLabel.font = [UIFont systemFontOfSize:32];
        digitLabel.textAlignment = NSTextAlignmentCenter;
        digitLabel.layer.masksToBounds = YES;
        [self addSubview:digitLabel];

        if ([type isEqualToString:@"digit"]) {
            NSInteger fromDigit = previousItem ? [previousItem[@"value"] integerValue] : 0; // Default to 0 if no previous digit
            NSInteger toDigit = [value integerValue]; // Get new digit

            // Determine if the value is increasing or decreasing
            BOOL isIncrease = (toDigit > fromDigit);

            // Animate the digit only if it changes
            if (fromDigit != toDigit) {
                [self animateRollingForLabel:digitLabel fromDigit:fromDigit toDigit:toDigit isIncrease:isIncrease];
            }
        } else {
            // Non-digit, just display without animation
            digitLabel.text = value;
        }

        xPosition += 30;  // Move to the next digit's position
    }
}

// Set the value and update the view
- (void)setValue:(NSString *)value {
    NSString *oldValue = _value;
    _value = value;
    self.previousValue = oldValue; // Save old value to compare with new value
    
    // Compare old value and new value to check which digits changed
    if (![oldValue isEqualToString:value]) {
        [self updateView];
    }
}

@end

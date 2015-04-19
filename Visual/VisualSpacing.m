#import "VisualSpacing.h"

@implementation VisualSpacing

- (BOOL)isSpacingForFirstItemLabel:(NSString *)firstItemLabel secondItemLabel:(NSString *)secondItemLabel {
    BOOL firstItemMatch = firstItemLabel ? [firstItemLabel isEqualToString:self.firstItemLabel] : !self.firstItemLabel;
    BOOL secondItemMatch = secondItemLabel ? [secondItemLabel isEqualToString:self.secondItemLabel] : !self.secondItemLabel;
    return firstItemMatch && secondItemMatch;
}

@end

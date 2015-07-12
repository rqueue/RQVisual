#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RQVisualMasterHelper.h"

#define RQVisualDictionaryOfVariableBindings(...) [RQVisualMasterHelper dictionaryOfVariableBindings:NSDictionaryOfVariableBindings(__VA_ARGS__)]

@interface RQVisualMaster : NSObject

+ (void)setDefaultVerticalPaddig:(CGFloat)verticalPadding;
+ (void)setDefaultHorizontalPadding:(CGFloat)horizontalPadding;
// Returns view at min size
+ (UIView *)viewFromVisualFormats:(NSArray *)visualFormats rowSpacingVisualFormat:(NSString *)rowSpacingVisualFormat variableBindings:(NSDictionary *)variableBindings;
+ (void)addSubviewsToView:(UIView *)containerView usingVisualFormats:(NSArray *)visualFormats rowSpacingVisualFormat:(NSString *)rowSpacingVisualFormat variableBindings:(NSDictionary *)variableBindings;

@end

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VisualMaster : NSObject

// Returns view at min size
+ (UIView *)viewFromVisualFormats:(NSArray *)visualFormats rowSpacingVisualFormat:(NSString *)rowSpacingVisualFormat variableBindings:(NSDictionary *)variableBindings;
+ (void)addSubviewsToView:(UIView *)containerView usingVisualFormats:(NSArray *)visualFormats rowSpacingVisualFormat:(NSString *)rowSpacingVisualFormat variableBindings:(NSDictionary *)variableBindings;

@end

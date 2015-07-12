#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RQVisualMasterHelper.h"

/**
 Wrapper for NSDictionaryOfVariableBindings, which modifies the dictionary returned so that arguments of the form `self.someProperty` have keys with "self." removed.
 For example, calling this method with `self.someProperty` will yield: `@{ "someProperty": self.someProperty }`.
 */
#define RQVisualDictionaryOfVariableBindings(...) [RQVisualMasterHelper dictionaryOfVariableBindings:NSDictionaryOfVariableBindings(__VA_ARGS__)]

@interface RQVisualMaster : NSObject

/**
 Sets the spacing that will be used between rows if none is provided in the visual format.

 Note: The default vertical spacing does not affect the spacing between: 

           - The first row and the top of its superview

           - The last row and the bottom of its superview

       These values will always be 0.0 unless otherwise specified in the visual format.
 @param verticalPadding The default spacing to use between rows.
 */
+ (void)setDefaultVerticalPaddig:(CGFloat)verticalPadding;

/**
 Sets the spacing that will be used between views in the same row if none is provided in the visual format.

 Note: The default horizontal spacing does not affect the spacing between:

           - The first view in a row and the left edge of its superview

           - The last view in a row row and the right edge of its superview

       These values will always be 0.0 unless otherwise specified in the visual format.
 @param horizontalPadding The default spacing to use between views in the same row.
 */
+ (void)setDefaultHorizontalPadding:(CGFloat)horizontalPadding;

/**
 Creates a UIView containing the given views with all horizontal and vertical constraints as specified in the visual formats.
 @see https://github.com/rqueue/RQVisual/wiki for more information on the visual format syntax
 @param visualFormats NSArray of visual formats representing the layout of each row. The visual format strings should be ordered from the topmost to bottommost row.
 @param rowSpacingVisualFormat NSString specifying the spacing between the rows passed in as `visualFormats`.
 @param variableBindings NSDictionary mapping the view names used in `visualFormats` to the views themselves. See the RQVisualDictionaryOfVariableBindings macro to more easily create variable bindings.
 @return UIView A view containing all of the subviews with constraints applied. This view is returned at the minimal size it can take on without breaking constraints.
 */
+ (UIView *)viewFromVisualFormats:(NSArray *)visualFormats rowSpacingVisualFormat:(NSString *)rowSpacingVisualFormat variableBindings:(NSDictionary *)variableBindings;

/**
 Adds the given views to a given container view with all horizontal and vertical constraints as specified in the visual formats.
 @see https://github.com/rqueue/RQVisual/wiki for more information on the visual format syntax
 @param containerView UIView to add the views to.
 @param visualFormats NSArray of visual formats representing the layout of each row. The visual format strings should be ordered from the topmost to bottommost row.
 @param rowSpacingVisualFormat NSString specifying the spacing between the rows passed in as `visualFormats`.
 @param variableBindings NSDictionary mapping the view names used in `visualFormats` to the views themselves. See the RQVisualDictionaryOfVariableBindings macro to more easily create variable bindings.
 @return UIView A view containing all of the subviews with constraints applied. This view is returned at the minimal size it can take on without breaking constraints.
 */
+ (void)addSubviewsToView:(UIView *)containerView usingVisualFormats:(NSArray *)visualFormats rowSpacingVisualFormat:(NSString *)rowSpacingVisualFormat variableBindings:(NSDictionary *)variableBindings;

@end

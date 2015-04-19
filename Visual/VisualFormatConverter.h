#import <Foundation/Foundation.h>

@interface VisualFormatConverter : NSObject

+ (NSArray *)visualRowSpacingsForRowVisualFormat:(NSString *)rowVisualFormat;
+ (NSArray *)visualItemsForVisualFormat:(NSString *)visualFormat variableBindings:(NSDictionary *)variableBindings;

@end

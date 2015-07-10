#import <Foundation/Foundation.h>

@interface VisualFormatConverter : NSObject

+ (NSArray *)visualSpacingsForVisualFormat:(NSString *)visualFormat;
+ (NSArray *)visualItemsForVisualFormat:(NSString *)visualFormat variableBindings:(NSDictionary *)variableBindings;

@end

#import <Foundation/Foundation.h>

@interface RQVisualFormatConverter : NSObject

+ (NSArray *)visualSpacingsForVisualFormat:(NSString *)visualFormat;
+ (NSArray *)visualItemsForVisualFormat:(NSString *)visualFormat variableBindings:(NSDictionary *)variableBindings;

@end

#import "NSString+Parse.h"

@implementation NSString (Parse)

- (NSString *)substringByRemovingRange:(NSRange)range {
    NSMutableString *modifiedVisualFormat = [[NSMutableString alloc] init];
    [modifiedVisualFormat appendString:[self substringToIndex:range.location]];
    NSUInteger stringToRemoveEndIndex = range.location + range.length;
    [modifiedVisualFormat appendString:[self substringWithRange:NSMakeRange(stringToRemoveEndIndex, [self length] - stringToRemoveEndIndex)]];
    return [modifiedVisualFormat copy];
}

@end

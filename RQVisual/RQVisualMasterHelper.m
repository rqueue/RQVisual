#import "RQVisualMasterHelper.h"
#import <UIKit/UIKit.h>

@implementation RQVisualMasterHelper

+ (NSDictionary *)dictionaryOfVariableBindings:(NSDictionary *)variableBindings {
    NSMutableDictionary *bindings = [variableBindings mutableCopy];

    NSArray *keys = [bindings allKeys];
    for (NSString *key in keys) {
        NSMutableString *mutableKey = [key mutableCopy];
        [mutableKey replaceOccurrencesOfString:@"self." withString:@"" options:0 range:NSMakeRange(0, [key length])];
        if (![key isEqualToString:mutableKey]) {
            bindings[[mutableKey copy]] = bindings[key];
            [bindings removeObjectForKey:key];
        }
    }

    return [bindings copy];
}

@end

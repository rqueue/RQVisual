#import "NSMutableArray+Stack.h"

@implementation NSMutableArray (Stack)

- (id)pop {
    id obj = [self firstObject];
    if (obj) {
        [self removeObjectAtIndex:0];
    }
    return obj;
}

@end

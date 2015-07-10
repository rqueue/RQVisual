#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RQVisualSpacing : NSObject

@property (nonatomic) CGFloat spacing;
@property (nonatomic, copy) NSString *firstItemLabel;
@property (nonatomic, copy) NSString *secondItemLabel;

- (BOOL)isSpacingForFirstItemLabel:(NSString *)firstItemLabel secondItemLabel:(NSString *)secondItemLabel;

@end

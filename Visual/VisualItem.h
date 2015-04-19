#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VisualItemDimensionType) {
    VisualItemDimensionTypeFixed,
    VisualItemDimensionTypeDynamic,
    VisualItemDimensionTypeEqual,
};

@interface VisualItem : NSObject

@property (nonatomic, copy) NSString *visualFormat;
@property (nonatomic, copy) NSString *viewName;
@property (nonatomic, copy) NSString *rowLabel;
@property (nonatomic) UIView *view;
@property (nonatomic) VisualItemDimensionType heightType;
@property (nonatomic) VisualItemDimensionType widthType;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;

@end

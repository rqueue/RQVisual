#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VisualItemDimensionType) {
    VisualItemDimensionTypeFixed,
    VisualItemDimensionTypeDynamic,
    VisualItemDimensionTypeEqual,
};

typedef NS_ENUM(NSInteger, VisualItemAlignmentType) {
    VisualItemAlignmentTypeNone,
    VisualItemAlignmentTypeLeft,
    VisualItemAlignmentTypeRight,
    VisualItemAlignmentTypeCenter,
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
@property (nonatomic) NSLayoutConstraint *topConstraint;
@property (nonatomic) NSLayoutConstraint *bottomConstraint;
@property (nonatomic) NSLayoutConstraint *leftConstraint;
@property (nonatomic) NSLayoutConstraint *rightConstraint;
@property (nonatomic) NSLayoutConstraint *widthConstraint;
@property (nonatomic) NSLayoutConstraint *heightConstraint;
@property (nonatomic) VisualItemAlignmentType horizontalAlignmentType;

@end

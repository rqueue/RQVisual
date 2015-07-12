#import "RQVisualMaster.h"
#import "NSMutableArray+Stack.h"
#import "RQVisualSpacing.h"
#import "RQVisualItem.h"
#import "RQVisualFormatConverter.h"

static CGFloat const kVisualMasterVerticalPadding = 10.0;
static CGFloat const kVisualMasterHorizontalPadding = 10.0;

@interface RQVisualMaster()

@property (nonatomic) CGFloat defaultVerticalPadding;
@property (nonatomic) CGFloat defaultHorizontalPadding;

@end

@implementation RQVisualMaster

+ (instancetype)sharedInstance {
    static RQVisualMaster *visualMaster = nil;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        visualMaster = [[RQVisualMaster alloc] init];
        visualMaster.defaultVerticalPadding = kVisualMasterVerticalPadding;
        visualMaster.defaultHorizontalPadding = kVisualMasterHorizontalPadding;
    });

    return visualMaster;
}

+ (void)setDefaultVerticalPaddig:(CGFloat)verticalPadding {
    RQVisualMaster *vm = [RQVisualMaster sharedInstance];
    vm.defaultVerticalPadding = verticalPadding;
}

+ (void)setDefaultHorizontalPadding:(CGFloat)horizontalPadding {
    RQVisualMaster *vm = [RQVisualMaster sharedInstance];
    vm.defaultHorizontalPadding = horizontalPadding;
}

+ (UIView *)viewFromVisualFormats:(NSArray *)visualFormats rowSpacingVisualFormat:(NSString *)rowSpacingVisualFormat variableBindings:(NSDictionary *)variableBindings {
    UIView *containerView = [[UIView alloc] init];
    [self addSubviewsToView:containerView usingVisualFormats:visualFormats rowSpacingVisualFormat:rowSpacingVisualFormat variableBindings:variableBindings];
    return containerView;
}

+ (void)addSubviewsToView:(UIView *)containerView usingVisualFormats:(NSArray *)visualFormats rowSpacingVisualFormat:(NSString *)rowSpacingVisualFormat variableBindings:(NSDictionary *)variableBindings {

    NSMutableArray *visualItemsRows = [NSMutableArray array];
    NSMutableArray *visualItemSpacings = [NSMutableArray array];
    for (NSString *visualFormat in visualFormats) {
        NSArray *visualItems = [RQVisualFormatConverter visualItemsForVisualFormat:visualFormat variableBindings:variableBindings];
        [visualItemsRows addObject:visualItems];

        NSArray *visualItemSpacing = [RQVisualFormatConverter visualSpacingsForVisualFormat:visualFormat];
        [visualItemSpacings addObject:visualItemSpacing];
    }

    CGFloat height = 0;
    CGFloat width = 0;

    NSMutableArray *visualRowSpacings = [NSMutableArray arrayWithArray:[RQVisualFormatConverter visualSpacingsForVisualFormat:rowSpacingVisualFormat]];
    RQVisualSpacing *visualRowSpacing = [visualRowSpacings pop];
    for (NSUInteger row = 0; row < [visualItemsRows count]; row++) {
        CGFloat defaultHorizontalPadding = [RQVisualMaster sharedInstance].defaultHorizontalPadding;
        CGFloat defaultVerticalPadding = [RQVisualMaster sharedInstance].defaultVerticalPadding;

        NSMutableArray *visualItemSpacingsForRow = [visualItemSpacings[row] mutableCopy];
        RQVisualSpacing *visualItemSpacing = [visualItemSpacingsForRow pop];

        CGFloat rowSpacingHeight = 0;
        if (row > 0) {
            rowSpacingHeight = defaultVerticalPadding;
        }

        CGFloat rowWidth = 0;
        NSArray *visualItems = visualItemsRows[row];
        for (NSUInteger i = 0; i < [visualItems count]; i++) {
            RQVisualItem *visualItem = visualItems[i];

            switch (visualItem.widthType) {
                case VisualItemDimensionTypeFixed:
                    rowWidth += visualItem.width;
                    break;
                default:
                    break;
            }

            UIView *view = visualItem.view;
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [containerView addSubview:view];

            // Vertical Constraints
            if (visualItem.heightType == VisualItemDimensionTypeFixed) {
                NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view
                                                                              attribute:NSLayoutAttributeHeight
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:nil
                                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                                             multiplier:1.0
                                                                               constant:visualItem.height];
                [containerView addConstraint:constraint];
                visualItem.heightConstraint = constraint;
            }

            if (i == 0) {
                if (row == 0) {
                    // Constrain view to top
                    CGFloat constant = 0.0;
                    if ([visualRowSpacing isSpacingForFirstItemLabel:nil secondItemLabel:visualItem.rowLabel]) {
                        constant = visualRowSpacing.spacing;
                        rowSpacingHeight = visualRowSpacing.spacing;
                        visualRowSpacing = [visualRowSpacings pop];
                    }
                    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view
                                                                                  attribute:NSLayoutAttributeTop
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:containerView
                                                                                  attribute:NSLayoutAttributeTop
                                                                                 multiplier:1.0
                                                                                   constant:constant];
                    [containerView addConstraint:constraint];
                    visualItem.topConstraint = constraint;
                } else {
                    // Constrain view to a view above
                    RQVisualItem *aboveVisualItem = visualItemsRows[row - 1][0];
                    UIView *aboveView = aboveVisualItem.view;

                    CGFloat constant = defaultVerticalPadding;
                    if ([visualRowSpacing isSpacingForFirstItemLabel:aboveVisualItem.rowLabel secondItemLabel:visualItem.rowLabel]) {
                        constant = visualRowSpacing.spacing;
                        rowSpacingHeight = visualRowSpacing.spacing;
                        visualRowSpacing = [visualRowSpacings pop];
                    }
                    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view
                                                                                  attribute:NSLayoutAttributeTop
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:aboveView
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                 multiplier:1.0
                                                                                   constant:constant];
                    [containerView addConstraint:constraint];
                    visualItem.topConstraint = constraint;
                    aboveVisualItem.bottomConstraint = constraint;
                }
            } else {
                RQVisualItem *firstVisualItem = visualItems[0];
                UIView *firstView = firstVisualItem.view;
                NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:firstView
                                                                              attribute:NSLayoutAttributeTop
                                                                             multiplier:1.0
                                                                               constant:0.0];
                [containerView addConstraint:constraint];
                visualItem.topConstraint = constraint;
            }

            if (row == [visualItemsRows count] - 1) {
                // Constrain view to bottom
                if (i == 0) {
                    CGFloat constant = 0.0;
                    NSLayoutRelation relation = NSLayoutRelationEqual;
                    if ([visualRowSpacing isSpacingForFirstItemLabel:visualItem.rowLabel secondItemLabel:nil]) {
                        constant = visualRowSpacing.spacing;
                        rowSpacingHeight = visualRowSpacing.spacing;
                        visualRowSpacing = [visualRowSpacings pop];
                    } else if (visualItem.heightType == VisualItemDimensionTypeFixed) {
                        if (row == 0 || ((RQVisualItem *)visualItemsRows[row - 1][0]).heightType != VisualItemDimensionTypeDynamic) {
                            relation = NSLayoutRelationGreaterThanOrEqual;
                        }
                    }
                    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:containerView
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                  relatedBy:relation
                                                                                     toItem:view
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                 multiplier:1.0
                                                                                   constant:constant];
                    [containerView addConstraint:constraint];
                    visualItem.bottomConstraint = constraint;
                } else {
                    RQVisualItem *firstVisualItem = visualItems[0];
                    UIView *firstView = firstVisualItem.view;
                    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:firstView
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                 multiplier:1.0
                                                                                   constant:0.0];
                    [containerView addConstraint:constraint];
                    visualItem.bottomConstraint = constraint;
                }
            }

            // Horizontal Constraints
            if (i == 0) {
                // Add height once per row
                if (visualItem.heightType == VisualItemDimensionTypeFixed) {
                    height += visualItem.height;
                }

                // Constrain view to left
                NSString *visual = [NSString stringWithFormat:@"H:%@", visualItem.visualFormat];

                CGFloat spacing = 0.0;
                if ([visualItemSpacing isSpacingForFirstItemLabel:nil secondItemLabel:visualItem.viewName]) {
                    spacing = visualItemSpacing.spacing;
                    visualItemSpacing = [visualItemSpacingsForRow pop];
                }

                [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visual
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:@{visualItem.viewName: visualItem.view}]];
                NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:visualItem.view
                                                                                  attribute:NSLayoutAttributeLeading
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:containerView
                                                                                  attribute:NSLayoutAttributeLeading
                                                                                 multiplier:1.0
                                                                                   constant:spacing];
                [containerView addConstraint:leftConstraint];
                visualItem.leftConstraint = leftConstraint;
            } else {
                // Constraint view to view to left
                RQVisualItem *leftVisualItem = visualItems[i - 1];
                UIView *leftView = leftVisualItem.view;
                NSDictionary *variables = @{visualItem.viewName: visualItem.view};
                NSString *visual = [NSString stringWithFormat:@"H:%@", visualItem.visualFormat];

                CGFloat spacing = defaultHorizontalPadding;
                if ([visualItemSpacing isSpacingForFirstItemLabel:leftVisualItem.viewName secondItemLabel:visualItem.viewName]) {
                    spacing = visualItemSpacing.spacing;
                    visualItemSpacing = [visualItemSpacingsForRow pop];
                }

                NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:visual
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:variables];
                [containerView addConstraints:constraints];
                visualItem.widthConstraint = [constraints firstObject];
                NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:visualItem.view
                                                                              attribute:NSLayoutAttributeLeading
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:leftView
                                                                              attribute:NSLayoutAttributeTrailing
                                                                             multiplier:1.0
                                                                               constant:spacing];
                [containerView addConstraint:constraint];
                visualItem.leftConstraint = constraint;
                leftVisualItem.rightConstraint = constraint;
                rowWidth += defaultHorizontalPadding;
            }

            if (i == [visualItems count] - 1) {
                // Constrain view to right
                NSLayoutRelation relation = NSLayoutRelationEqual;
                RQVisualItem *previousVisualItem = i > 0 ? visualItems[i - 1] : nil;
                if (visualItem.widthType == VisualItemDimensionTypeFixed && (i == 0 || previousVisualItem.widthType == VisualItemDimensionTypeFixed)) {
                    relation = NSLayoutRelationGreaterThanOrEqual;
                }

                CGFloat spacing = 0.0;
                if ([visualItemSpacing isSpacingForFirstItemLabel:visualItem.viewName secondItemLabel:nil]) {
                    spacing = visualItemSpacing.spacing;
                    visualItemSpacing = [visualItemSpacingsForRow pop];
                }

                NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:containerView
                                                                              attribute:NSLayoutAttributeTrailing
                                                                              relatedBy:relation
                                                                                 toItem:visualItem.view
                                                                              attribute:NSLayoutAttributeTrailing
                                                                             multiplier:1.0
                                                                               constant:spacing];
                [containerView addConstraint:constraint];
                visualItem.rightConstraint = constraint;
            }
        }

        width = MAX(width, rowWidth);
        height += rowSpacingHeight;

        [self addEqualWidthConstraintsForVisualItems:visualItems containerView:containerView];
        [self adjustHorizontalConstraintsForVisualItems:visualItems containerView:containerView];
    }

    containerView.frame = CGRectMake(0.0, 0.0, width, height);
}

#pragma mark - Internal

+ (void)adjustHorizontalConstraintsForVisualItems:(NSArray *)visualItems containerView:(UIView *)containerView {
    NSMutableArray *centeredItems = [NSMutableArray array];
    for (NSUInteger i = 0; i < [visualItems count]; i ++) {
        RQVisualItem *visualItem = visualItems[i];
        RQVisualItem *previousVisualItem = i > 0 ? visualItems[i - 1] : nil;
        RQVisualItem *nextVisualItem = i + 1 < [visualItems count] ? visualItems[i + 1] : nil;

        if (visualItem.horizontalAlignmentType == VisualItemAlignmentTypeLeft || visualItem.horizontalAlignmentType == VisualItemAlignmentTypeCenter) {
            if (!nextVisualItem || (nextVisualItem.horizontalAlignmentType != VisualItemAlignmentTypeLeft && nextVisualItem.widthType == VisualItemDimensionTypeFixed)) {
                [containerView removeConstraint:visualItem.rightConstraint];
            }
        }

        if (visualItem.horizontalAlignmentType == VisualItemAlignmentTypeRight || visualItem.horizontalAlignmentType == VisualItemAlignmentTypeCenter) {
            if (!previousVisualItem || (previousVisualItem.horizontalAlignmentType != VisualItemAlignmentTypeRight && previousVisualItem.widthType == VisualItemDimensionTypeFixed)) {
                [containerView removeConstraint:visualItem.leftConstraint];
            }
        }

        if (visualItem.horizontalAlignmentType == VisualItemAlignmentTypeCenter) {
            [centeredItems addObject:visualItem];
        }
    }

    if ([centeredItems count] > 0) {
        CGFloat totalWidth = 0;
        for (NSInteger i = 0; i < [centeredItems count]; i++) {
            RQVisualItem *visualItem = centeredItems[i];
            totalWidth += visualItem.width;
            if (i < [centeredItems count] - 1) {
                totalWidth += visualItem.rightConstraint.constant;
            }
        }

        CGFloat offsetFromCenter = -totalWidth / 2.0;
        for (NSUInteger i = 0; i < [centeredItems count]; i++) {
            RQVisualItem *visualItem = centeredItems[i];
            [containerView addConstraint:[NSLayoutConstraint constraintWithItem:visualItem.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:containerView
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1.0
                                                                       constant:offsetFromCenter]];
            offsetFromCenter += visualItem.width + visualItem.rightConstraint.constant;
        }
    }
}

+ (void)addEqualWidthConstraintsForVisualItems:(NSArray *)visualItems containerView:(UIView *)containerView {
    NSMutableArray *visualItemsWithEqualWidths = [NSMutableArray array];
    for (RQVisualItem *visualItem in visualItems) {
        if (visualItem.widthType == VisualItemDimensionTypeEqual) {
            [visualItemsWithEqualWidths addObject:visualItem];
        }
    }

    if ([visualItemsWithEqualWidths count] > 1) {
        for (NSUInteger k = 1; k < [visualItemsWithEqualWidths count]; k++) {
            RQVisualItem *previousVisualItem = visualItemsWithEqualWidths[k - 1];
            RQVisualItem *currentVisualItem = visualItemsWithEqualWidths[k];
            [containerView addConstraint:[NSLayoutConstraint constraintWithItem:previousVisualItem.view
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:currentVisualItem.view
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:1.0
                                                                       constant:0.0]];
        }
    }
}

@end

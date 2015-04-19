#import "VisualMaster.h"
#import "NSMutableArray+Stack.h"
#import "VisualRowSpacing.h"
#import "VisualItem.h"

static CGFloat const kVisualMasterVerticalPadding = 10.0;
static CGFloat const kVisualMasterHorizontalPadding = 10.0;
static NSString * const kVisualMasterEqualWidthSyntax = @"==";

@implementation VisualMaster

+ (UIView *)viewFromVisualFormats:(NSArray *)visualFormats rowSpacingVisualFormat:(NSString *)rowSpacingVisualFormat variableBindings:(NSDictionary *)variableBindings {
    UIView *containerView = [[UIView alloc] init];
    [self addSubviewsToView:containerView usingVisualFormats:visualFormats rowSpacingVisualFormat:rowSpacingVisualFormat variableBindings:variableBindings];
    return containerView;
}

+ (void)addSubviewsToView:(UIView *)containerView usingVisualFormats:(NSArray *)visualFormats rowSpacingVisualFormat:(NSString *)rowSpacingVisualFormat variableBindings:(NSDictionary *)variableBindings {
    containerView.translatesAutoresizingMaskIntoConstraints = NO;

    NSMutableArray *visualItemsRows = [NSMutableArray array];
    for (NSString *visualFormat in visualFormats) {
        NSArray *visualItems = [self visualItemsForVisualFormat:visualFormat variableBindings:variableBindings];
        [visualItemsRows addObject:visualItems];
    }

    CGFloat height = 0;
    CGFloat width = 0;

    NSMutableArray *visualRowSpacings = [NSMutableArray arrayWithArray:[self visualRowSpacingsForRowVisualFormat:rowSpacingVisualFormat]];
    VisualRowSpacing *visualRowSpacing = [visualRowSpacings pop];
    for (NSUInteger row = 0; row < [visualItemsRows count]; row++) {
        if (row > 0) {
            height += kVisualMasterVerticalPadding;
        }

        CGFloat rowWidth = 0;
        NSArray *visualItems = visualItemsRows[row];
        NSMutableArray *visualItemsWithEqualWidths = [NSMutableArray array];
        for (NSUInteger i = 0; i < [visualItems count]; i++) {
            VisualItem *visualItem = visualItems[i];

            switch (visualItem.widthType) {
                case VisualItemDimensionTypeFixed:
                    rowWidth += visualItem.width;
                    break;
                case VisualItemDimensionTypeEqual:
                    [visualItemsWithEqualWidths addObject:visualItem];
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
            
            if (row == 0) {
                // Constrain view to top
                if (i == 0) {
                    CGFloat constant = 0.0;
                    if (visualRowSpacing && !visualRowSpacing.topRowLabel && [visualRowSpacing.bottomRowLabel isEqualToString:visualItem.rowLabel]) {
                        constant = visualRowSpacing.spacing;
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
                    VisualItem *firstVisualItem = visualItems[0];
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
            } else {
                // Constrain view to a view above
                VisualItem *aboveVisualItem = visualItemsRows[row - 1][0];
                UIView *aboveView = aboveVisualItem.view;

                CGFloat constant = kVisualMasterVerticalPadding;
                if (visualRowSpacing && [visualRowSpacing.topRowLabel isEqualToString:aboveVisualItem.rowLabel] && [visualRowSpacing.bottomRowLabel isEqualToString:visualItem.rowLabel]) {
                    constant = visualRowSpacing.spacing;
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

            if (row == [visualItemsRows count] - 1) {
                // Constrain view to bottom
                if (i == 0) {
                    CGFloat constant = 0.0;
                    if (visualRowSpacing && [visualRowSpacing.topRowLabel isEqualToString:visualItem.rowLabel] && !visualRowSpacing.bottomRowLabel) {
                        constant = visualRowSpacing.spacing;
                        visualRowSpacing = [visualRowSpacings pop];
                    }
                    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:containerView
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:view
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                 multiplier:1.0
                                                                                   constant:constant];
                    [containerView addConstraint:constraint];
                    visualItem.bottomConstraint = constraint;
                } else {
                    VisualItem *firstVisualItem = visualItems[0];
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
                                                                                   constant:0.0];
                [containerView addConstraint:leftConstraint];
                visualItem.leftConstraint = leftConstraint;
            } else {
                // Constraint view to view to left
                VisualItem *leftVisualItem = visualItems[i - 1];
                UIView *leftView = leftVisualItem.view;
                NSDictionary *variables = @{visualItem.viewName: visualItem.view};
                NSString *visual = [NSString stringWithFormat:@"H:%@", visualItem.visualFormat];
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
                                                                               constant:kVisualMasterHorizontalPadding];
                [containerView addConstraint:constraint];
                visualItem.leftConstraint = constraint;
                leftVisualItem.rightConstraint = constraint;
                rowWidth += kVisualMasterHorizontalPadding;
            }

            if (i == [visualItems count] - 1) {
                // Constrain view to right
                NSLayoutRelation relation = NSLayoutRelationEqual;
                VisualItem *previousVisualItem = i > 0 ? visualItems[i - 1] : nil;
                if (visualItem.widthType == VisualItemDimensionTypeFixed && (i == 0 || previousVisualItem.widthType == VisualItemDimensionTypeFixed)) {
                    relation = NSLayoutRelationGreaterThanOrEqual;
                }
                NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:visualItem.view
                                                                              attribute:NSLayoutAttributeTrailing
                                                                              relatedBy:relation
                                                                                 toItem:containerView
                                                                              attribute:NSLayoutAttributeTrailing
                                                                             multiplier:1.0
                                                                               constant:0.0];
                [containerView addConstraint:constraint];
                visualItem.rightConstraint = constraint;
            }
        }

        width = MAX(width, rowWidth);

        if ([visualItemsWithEqualWidths count] > 1) {
            for (NSUInteger k = 1; k < [visualItemsWithEqualWidths count]; k++) {
                VisualItem *previousVisualItem = visualItemsWithEqualWidths[k - 1];
                VisualItem *currentVisualItem = visualItemsWithEqualWidths[k];
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

    containerView.frame = CGRectMake(0.0, 0.0, width, height);
}

#pragma mark - Internal

+ (NSArray *)visualItemsForVisualFormat:(NSString *)visualFormat variableBindings:(NSDictionary *)variableBindings {
    NSMutableArray *visualItems = [NSMutableArray array];
    NSString *rowLabel = [self rowLabelForVisualFormat:visualFormat];

    NSString *formatRemaining = [self visualFormatByRemovingRowLabel:visualFormat];
    NSString *pattern = @"\\[(\\w+)(\\(([\\d\\.=]+)\\))?\\]";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];

    NSString *heightString = [self heightStringForVisualFormat:visualFormat];

    while ([formatRemaining length] > 0) {
        NSTextCheckingResult *match = [regex firstMatchInString:formatRemaining options:0 range:NSMakeRange(0, [formatRemaining length])];
        if (match) {
            NSString *viewString = [formatRemaining substringWithRange:[match rangeAtIndex:1]];
            NSString *widthString = nil;
            NSRange widthRange = [match rangeAtIndex:2];
            if (widthRange.length > 0) {
                widthString = [formatRemaining substringWithRange:[match rangeAtIndex:3]];
            }
            VisualItem *visualItem = [[VisualItem alloc] init];
            visualItem.rowLabel = rowLabel;
            visualItem.visualFormat = [self visualFormatForVisualFormat:[formatRemaining substringWithRange:[match rangeAtIndex:0]] widthString:widthString range:widthRange];
            visualItem.viewName = viewString;
            visualItem.width = [widthString floatValue];
            visualItem.widthType = [self visualItemDimensionTypeForWidthString:widthString];
            visualItem.height = [heightString floatValue];
            visualItem.heightType = heightString ? VisualItemDimensionTypeFixed : VisualItemDimensionTypeDynamic;
            visualItem.view = [variableBindings objectForKey:viewString];
            [visualItems addObject:visualItem];
            formatRemaining = [formatRemaining substringFromIndex:match.range.location + match.range.length];
        } else {
            break;
        }
    }

    return [visualItems copy];
}

+ (VisualItemDimensionType)visualItemDimensionTypeForWidthString:(NSString *)widthString {
    if (!widthString) {
        return VisualItemDimensionTypeDynamic;
    } else if ([widthString isEqualToString:kVisualMasterEqualWidthSyntax]) {
        return VisualItemDimensionTypeEqual;
    } else {
        return VisualItemDimensionTypeFixed;
    }
}

+ (NSString *)visualFormatForVisualFormat:(NSString *)visualFormat widthString:(NSString *)widthString range:(NSRange)range {
    if ([widthString isEqualToString:kVisualMasterEqualWidthSyntax]) {
        NSMutableString *modifiedVisualFormat = [[NSMutableString alloc] init];
        [modifiedVisualFormat appendString:[visualFormat substringToIndex:range.location]];
        NSUInteger widthStringEndIndex = range.location + range.length;
        [modifiedVisualFormat appendString:[visualFormat substringWithRange:NSMakeRange(widthStringEndIndex, [visualFormat length] - widthStringEndIndex)]];
        return [modifiedVisualFormat copy];
    } else {
        return visualFormat;
    }
}

+ (NSString *)heightStringForVisualFormat:(NSString *)visualFormat {
    NSString *heightPattern = @"\\[.+\\](?:\\(([\\d\\.]+)\\))?";
    NSRegularExpression *heightRegex = [NSRegularExpression regularExpressionWithPattern:heightPattern options:0 error:nil];
    NSTextCheckingResult *heightMatch = [heightRegex firstMatchInString:visualFormat options:0 range:NSMakeRange(0, [visualFormat length])];
    if (heightMatch) {
        NSRange heightValueRange = [heightMatch rangeAtIndex:1];
        if (heightValueRange.length > 0) {
            return [visualFormat substringWithRange:[heightMatch rangeAtIndex:1]];
        }
    }
    return nil;
}

+ (NSString *)rowLabelForVisualFormat:(NSString *)visualFormat {
    NSTextCheckingResult *match = [self rowLabelMatchForVisualFormat:visualFormat];
    if (match) {
        NSRange rowLabelRange = [match rangeAtIndex:1];
        if (rowLabelRange.length > 0) {
            return [visualFormat substringWithRange:rowLabelRange];
        }
    }
    return nil;
}

+ (NSString *)visualFormatByRemovingRowLabel:(NSString *)visualFormat {
    NSTextCheckingResult *match = [self rowLabelMatchForVisualFormat:visualFormat];
    if (match) {
        NSRange range = [match rangeAtIndex:0];
        return [visualFormat substringFromIndex:range.location + range.length];
    }
    return visualFormat;
}

+ (NSTextCheckingResult *)rowLabelMatchForVisualFormat:(NSString *)visualFormat {
    NSString *pattern = @"^(\\w+):";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:visualFormat options:0 range:NSMakeRange(0, [visualFormat length])];
    return match;
}

+ (NSArray *)visualRowSpacingsForRowVisualFormat:(NSString *)rowVisualFormat {
    NSMutableArray *visualRowSpacings = [NSMutableArray array];
    NSString *pattern = @"(?:\\||(?:\\[(\\w+)\\]))-(?:(?:(\\d+))|(?:\\((\\d+)\\)))-(?:\\||(?:\\[(\\w+)\\]))";
    NSString *formatRemaining = [rowVisualFormat copy];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];

    while ([formatRemaining length] > 0) {
        NSTextCheckingResult *match = [regex firstMatchInString:formatRemaining options:0 range:NSMakeRange(0, [formatRemaining length])];
        if (match) {
            NSRange topRowLabelRange = [match rangeAtIndex:1];
            NSRange spacingStringRangeWithoutParen = [match rangeAtIndex:2];
            NSRange spacingStringRangeWithParen = [match rangeAtIndex:3];
            NSRange spacingStringRange = spacingStringRangeWithoutParen.length > 0 ? spacingStringRangeWithoutParen : spacingStringRangeWithParen;
            NSRange bottomRowLabelRange = [match rangeAtIndex:4];

            NSString *topRowLabel = topRowLabelRange.length > 0 ? [formatRemaining substringWithRange:topRowLabelRange] : nil;
            NSString *spacingString = [formatRemaining substringWithRange:spacingStringRange];
            NSString *bottomRowLabel = bottomRowLabelRange.length > 0 ? [formatRemaining substringWithRange:bottomRowLabelRange] : nil;

            VisualRowSpacing *visualRowSpacing = [[VisualRowSpacing alloc] init];
            visualRowSpacing.topRowLabel = topRowLabel;
            visualRowSpacing.bottomRowLabel = bottomRowLabel;
            visualRowSpacing.spacing = [spacingString floatValue];
            [visualRowSpacings addObject:visualRowSpacing];

            if (bottomRowLabelRange.length > 0) {
                formatRemaining = [formatRemaining substringFromIndex:bottomRowLabelRange.location - 1];
            } else {
                break;
            }
        } else {
            break;
        }
    }

    return [visualRowSpacings copy];
}

@end

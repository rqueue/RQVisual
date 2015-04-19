#import "VisualFormatConverter.h"
#import "NSString+Parse.h"
#import "VisualItem.h"
#import "VisualSpacing.h"

static NSString * const kVisualFormatConverterEqualWidthSyntax = @"(==)";
static NSString *const kVisualFormatConverterVisualItemVisualFormat = @"\\[(\\w+)(\\(([\\d\\.=]+)\\))?([<>]+)?\\]";

@implementation VisualFormatConverter

#pragma mark - Public

+ (NSArray *)visualItemsForVisualFormat:(NSString *)visualFormat variableBindings:(NSDictionary *)variableBindings {
    NSMutableArray *visualItems = [NSMutableArray array];
    NSString *rowLabel = [self rowLabelForVisualFormat:visualFormat];

    NSString *formatRemaining = [self visualFormatByRemovingRowLabel:visualFormat];
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:kVisualFormatConverterVisualItemVisualFormat options:NSRegularExpressionCaseInsensitive error:nil];

    NSString *heightString = [self heightStringForVisualFormat:visualFormat];

    while ([formatRemaining length] > 0) {
        NSTextCheckingResult *match = [regex firstMatchInString:formatRemaining options:0 range:NSMakeRange(0, [formatRemaining length])];
        if (match) {
            VisualItem *visualItem = [self visualItemForVisualItemVisualFormat:[formatRemaining substringWithRange:[match rangeAtIndex:0]]
                                                              variableBindings:variableBindings
                                                                  heightString:heightString
                                                                      rowLabel:rowLabel];
            [visualItems addObject:visualItem];
            formatRemaining = [formatRemaining substringFromIndex:match.range.location + match.range.length];
        } else {
            break;
        }
    }

    return [visualItems copy];
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

            VisualSpacing *visualRowSpacing = [[VisualSpacing alloc] init];
            visualRowSpacing.firstItemLabel = topRowLabel;
            visualRowSpacing.secondItemLabel = bottomRowLabel;
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

#pragma mark - Internal

+ (VisualItem *)visualItemForVisualItemVisualFormat:(NSString *)visualItemVisualFormat
                                   variableBindings:(NSDictionary *)variableBindings
                                       heightString:(NSString *)heightString
                                           rowLabel:(NSString *)rowLabel {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kVisualFormatConverterVisualItemVisualFormat options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:visualItemVisualFormat options:0 range:NSMakeRange(0, [visualItemVisualFormat length])];
    NSString *viewString = [visualItemVisualFormat substringWithRange:[match rangeAtIndex:1]];

    NSString *widthString = nil;
    NSRange widthRange = [match rangeAtIndex:2];
    if (widthRange.length > 0) {
        widthString = [visualItemVisualFormat substringWithRange:[match rangeAtIndex:3]];
    }

    NSString *alignmentString = nil;
    NSRange alignmentRange = [match rangeAtIndex:4];
    if (alignmentRange.length > 0) {
        alignmentString = [visualItemVisualFormat substringWithRange:alignmentRange];
    }

    VisualItem *visualItem = [[VisualItem alloc] init];
    visualItem.rowLabel = rowLabel;
    visualItem.visualFormat = [self visualFormatForVisualFormat:[visualItemVisualFormat substringWithRange:[match rangeAtIndex:0]] widthRange:widthRange alignmentRange:alignmentRange];
    visualItem.viewName = viewString;
    visualItem.width = [widthString floatValue];
    visualItem.widthType = [self visualItemDimensionTypeForWidthString:widthString];
    visualItem.height = [heightString floatValue];
    visualItem.heightType = heightString ? VisualItemDimensionTypeFixed : VisualItemDimensionTypeDynamic;
    visualItem.view = [variableBindings objectForKey:viewString];
    visualItem.horizontalAlignmentType = [self visualItemAlignmentTypeForAlignmentString:alignmentString];
    return visualItem;
}

+ (VisualItemDimensionType)visualItemDimensionTypeForWidthString:(NSString *)widthString {
    if (!widthString) {
        return VisualItemDimensionTypeDynamic;
    } else if ([widthString isEqualToString:kVisualFormatConverterEqualWidthSyntax]) {
        return VisualItemDimensionTypeEqual;
    } else {
        return VisualItemDimensionTypeFixed;
    }
}

+ (VisualItemAlignmentType)visualItemAlignmentTypeForAlignmentString:(NSString *)alignmentString {
    if ([alignmentString isEqualToString:@"<"]) {
        return VisualItemAlignmentTypeLeft;
    } else if ([alignmentString isEqualToString:@">"]) {
        return VisualItemAlignmentTypeRight;
    } else if ([alignmentString isEqualToString:@"<>"]) {
        return VisualItemAlignmentTypeCenter;
    } else {
        return VisualItemAlignmentTypeNone;
    }
}

+ (NSString *)visualFormatForVisualFormat:(NSString *)visualFormat widthRange:(NSRange)widthRange alignmentRange:(NSRange)alignmentRange {
    NSString *visualString = visualFormat;
    if (alignmentRange.length > 0) {
        visualString = [visualString substringByRemovingRange:alignmentRange];
    }

    NSString *widthString = widthRange.length > 0 ? [visualFormat substringWithRange:widthRange] : nil;
    if ([widthString isEqualToString:kVisualFormatConverterEqualWidthSyntax]) {
        return [visualString substringByRemovingRange:widthRange];
    } else {
        return visualString;
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

@end

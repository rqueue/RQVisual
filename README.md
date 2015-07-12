# Visual

**Disclaimer:** Still in development

Visual is a tool for easily laying out views in code using visual formats similar to Auto Layout's Visual Format Language. All of the views are laid out using Auto Layout constraints so you get all the benefits of Auto Layout without the verbose NSLayoutConstraint syntax.

## Why not just use Auto Layout's Visual Format Language?

Auto Layout's Visual Format Language certaintly cuts down on the lines of code needed to add multiple constraints to a view, but the motivation behind Visual was to simplify this even more. With Visual it's possible to layout your entire view with a single method call (depending on how complicated your view is of course). Implicit padding between views is also added and can be optionally overidden or configured to a specific value. This enables a "standard" spacing to be applied between views automatically without having to specify it in your visual format.

## Examples

For all of the following examples you can either of the following methods:
```Objective-C
+ (UIView *)viewFromVisualFormats:(NSArray *)visualFormats rowSpacingVisualFormat:(NSString *)rowSpacingVisualFormat variableBindings:(NSDictionary *)variableBindings;
+ (void)addSubviewsToView:(UIView *)containerView usingVisualFormats:(NSArray *)visualFormats rowSpacingVisualFormat:(NSString *)rowSpacingVisualFormat variableBindings:(NSDictionary *)variableBindings;
``` 
The first method will return your views in a new container view and the second method will add your views to an existing view.

### Ex. 1 - Basic layout

Suppose I want to create a view with a `UIImageView` with a fixed width of 50.0 on the left and a `UILabel` of dynamic width to its right. Something like this:
```
|[imageView][       label        ]|
```
Using Visual we would do:
```Objective-C
UIView *containerView = [VisualMaster viewFromVisualFormats:@[@"[imageView(50)][label]"]
                                     rowSpacingVisualFormat:nil
                                           variableBindings:@{ @"imageView": imageView,
                                                               @"label":     label }];

```
This looks very similar to just using NSLayoutConstraint's `+ constraintsWithVisualFormat:options:metrics:views:` method, however here there have been a few implicit horizontal and vertical constraints added:

* The horizontal padding between the `imageView` and `label` has been set to `10.0` (the default horizontal padding).
* Both views have been constrained to the top and bottom edges of the view created.
* The `imageView` has been constrained to the left edge of the view created.
* The `label` has been constrained to the right edge of the view created.

If the `containerView` is resized, the `label` will stretch in width and both the `imageView` and `label` will stretch in height. 

If we wanted to fix the height of these views, we would simply add a specific height to the end of the visual format:
```Objective-C
UIView *containerView = [VisualMaster viewFromVisualFormats:@[@"[imageView(50)][label](60)"]
                                     rowSpacingVisualFormat:nil
                                           variableBindings:@{ @"imageView": imageView,
                                                               @"label":     label }];

```
Now, both the `imageView` and `label` will be constrained to a height of `60`.

One thing to note is that the `containerView` here will be returned with a frame size of its minimum possible size without breaking the constraints. For the above example this means `50 x 60` since the label has a dynamic width and is allowed to have a width of `0.0`.

### Ex. 2 - Customizing spacing of views within the same row

Spacing between items in a row can be applied in the same way as Auto Layout's Visual Format Language:
```Objective-C
UIView *containerView = [VisualMaster viewFromVisualFormats:@[@"|-(30)-[imageView(50)]-(40)-[label](60)"]
                                     rowSpacingVisualFormat:nil
                                           variableBindings:@{ @"imageView": imageView,
                                                               @"label":     label }];

```
Any unspecified spacing will use the default values which are `10` for between two items (if you haven't set your own default value) and `0` for items on the ends with their superview.

### Ex. 3 - Constraining views in the same row to have equal widths

Specfying that views in the same row should have equal widths can be done too:
```Objective-C
UIView *containerView = [VisualMaster viewFromVisualFormats:@[@"[imageView(==)][label(==)](60)"]
                                     rowSpacingVisualFormat:nil
                                           variableBindings:@{ @"imageView": imageView,
                                                               @"label":     label }];

```
Here `imageView` and `label` will have equal width constraints and both have a height of `60` (the height constraint is optional of course).

### Ex. 4 - Centering and pinning views in a row

If you want to center some views or pin some views to certain sides, you can use `<` to specify pinning to the left, `>` to specify pinning to the right, and `<>` for centering. To generate a view like this:
```
|[imageView]     [label]     [button]|
```
We would do the following:
```Objective-C
UIView *containerView = [VisualMaster viewFromVisualFormats:@[@"[imageView(50)<][label(50)<>][button(50)>](60)"]
                                     rowSpacingVisualFormat:nil
                                           variableBindings:@{ @"imageView": imageView,
                                                               @"label":     label,
                                                               @"button"     button }];

```

Mutiple views can also be centered together such as :
```
|          [imageview][label]           |
```
Just use the `<>` syntax for both views:
```Objective-C
UIView *containerView = [VisualMaster viewFromVisualFormats:@[@"[imageView(50)<>][label(50)<>](60)"]
                                     rowSpacingVisualFormat:nil
                                           variableBindings:@{ @"imageView": imageView,
                                                               @"label":     label }];

```

Note that for these examples of pinning and centering views you must specify width constraints on your views. This is because if a view is allowed to stretch in width, it doesn't make sense to pin/center it.

### Ex. 5 - Multiple rows

Making views with multiple rows is just as easy. Suppose we want the same view as in Ex. 1, but below it we want a `UITextView`.
```
|[imageView][       label        ]|
|[            textView           ]|
```
With Visual this would be:

```Objective-C
UIView *containerView = [VisualMaster viewFromVisualFormats:@[@"[imageView(50)][label](60)",
                                                              @"[textView]"]
                                     rowSpacingVisualFormat:nil
                                           variableBindings:@{ @"imageView": imageView,
                                                               @"label":     label,
                                                               @"textView":  textView }];

```
Here we have all of the same implicit constraints added horizontally and vertically as in Ex. 1, except now there is also vertical padding between the `textView` and the `imageView`/`label`. The default vertical padding is `10.0` as well.

If we want to customize the spacing between rows, we could do the following:
```Objective-C
UIView *containerView = [VisualMaster viewFromVisualFormats:@[@"r1:[imageView(50)][label](60)",
                                                              @"r2:[textView]"]
                                     rowSpacingVisualFormat:@"|-5-[r1]-5-[r2]-15-|"
                                           variableBindings:@{ @"imageView": imageView,
                                                               @"label":     label,
                                                               @"textView":  textView }];

```
Here the vertical spacing will be constructed as you would expect:

* The first row (`r1`) will be `5.0` points from its superview's top.
* The first row and second row (`r2`) will be `5.0` points apart.
* The second row will be `15.0` points from the bottom of its superview's bottom.

To specify custom padding between rows, you must add labels to the rows by preceding the visual format string with a name for that row and a colon. The name can be anything as long as it matches the variables in the `rowSpacingVisualFormat`. The `rowSpacingVisualFormat` string is composed in the same way as Auto Layout's Visual Format Language except instead of placing views between square brackets you place row labels.

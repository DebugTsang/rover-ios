//
//  RXDetailViewController.h
//  Pods
//
//  Created by Ata Namvari on 2015-01-30.
//
//

#import <UIKit/UIKit.h>

@class RVViewDefinition;
@class RXBlockView;

@interface RXDetailViewController : UIViewController

@property (nonatomic, weak) RVViewDefinition *viewDefinition;
@property (readonly) UIScrollView *scrollView;
@property (readonly) UIView *containerView;
@property (readonly) UIView *titleBar;

@property (nonatomic, strong, readonly) NSLayoutConstraint *titleBarTopConstraint;
@property (nonatomic, strong, readonly) NSLayoutConstraint *scrollViewHeightConstraint;

- (instancetype)initWithViewDefinition:(RVViewDefinition *)viewDefinition;

- (void)addBlockView:(RXBlockView *)blockView;
- (void)addHeaderBlockView:(RXBlockView *)blockView;
- (void)addBottomStickyBlockView:(RXBlockView *)blockView;


@end
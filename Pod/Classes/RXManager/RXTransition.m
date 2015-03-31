//
//  RXTransitionAnimator.m
//  Pods
//
//  Created by Ata Namvari on 2015-01-30.
//
//

#import "RXTransition.h"
#import "RXDetailViewController.h"

#define kThreshold 100.f

@interface RXTransition ()

@property (nonatomic, weak) RXDetailViewController *presentedViewController;

@end

@implementation RXTransition

- (instancetype)initWithParentViewController:(UIViewController *)viewController {
    self = [self init];
    if (self) {
        self.parentViewController = viewController;
    }
    return self;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    _presentedViewController = (RXDetailViewController *)presented;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator{
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator{
    return nil;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return .5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *contextView = [transitionContext containerView];
    
    NSLog(@"fromVC: %@", fromVC );
    
    if ([toVC isKindOfClass:[RXDetailViewController class]]) {
        // Presenting
        RXDetailViewController *detailVC = (RXDetailViewController *)toVC;
        [contextView addSubview:toVC.view];
        detailVC.titleBarTopConstraint.constant = detailVC.scrollViewHeightConstraint.constant;
        [toVC.view layoutIfNeeded];
        detailVC.titleBarTopConstraint.constant = 0;
        
        UIView *container = detailVC.containerView;
        container.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.5, 0.5), CGAffineTransformMakeTranslation(0, 400));
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             container.transform = CGAffineTransformIdentity;
                             [detailVC.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    } else {
        // Dismissing
        RXDetailViewController *detailVC = (RXDetailViewController *)fromVC;
        detailVC.titleBarTopConstraint.constant = detailVC.scrollViewHeightConstraint.constant;
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [detailVC.view layoutIfNeeded];
                             detailVC.containerView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.5, 0.5), CGAffineTransformMakeTranslation(0, 400));
                             //fromViewController.containerView.alpha = 0;
                             //[fromViewController.scrollView setContentOffset:CGPointMake(0, -400) animated:NO];
                         } completion:^(BOOL finished) {
                             //[fromViewController.view removeFromSuperview];
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    }
    

}

- (void)animationEnded:(BOOL) transitionCompleted{
    
}

#pragma mark - UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    self.transitionContext=transitionContext;
    
    UIView* inView = [transitionContext containerView];
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    RXDetailViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    NSLog(@"TO VC: %@", toViewController);
    
    //[inView addSubview:toViewController.view];
    //[inView addSubview:fromViewController.view];
    //[fromViewController.containerView removeFromSuperview];
//    toViewController.view.transform=CGAffineTransformMakeScale(1, 1);
//    fromViewController.view.transform=CGAffineTransformMakeScale(1, 1);
//    toViewController.view.alpha=0;
//    [inView addSubview:toViewController.view];
//    CGRect frame=toViewController.view.frame;
//    frame.origin.y=inView.bounds.size.height;
//    toViewController.view.frame=frame;
//    toViewController.view.alpha=1;
}

#pragma mark - UIPercentDrivenInteractiveTransition

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    
    if (percentComplete<0) {
        percentComplete=0;
    } else if (percentComplete>1){
        percentComplete=1;
    } else if (percentComplete > .2) {
        //[self finishInteractiveTransitionWithDuration:.7];
        return;
    }
    
    //UIViewController* toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    RXDetailViewController* fromViewController = (RXDetailViewController *)[self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
//    [fromViewController prepareLayoutForInteractiveTransition:percentComplete];
    [fromViewController.view layoutIfNeeded];
    
}

- (void)cancelInteractiveTransitionWithDuration:(CGFloat)duration{
    
    UIViewController* toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         fromViewController.view.transform=CGAffineTransformMakeTranslation(0, 400);
                         CGRect frame=toViewController.view.frame;
                         frame.origin.y=-toViewController.view.bounds.size.height;
                         toViewController.view.frame=frame;
                     } completion:^(BOOL finished) {
                         [toViewController.view removeFromSuperview];
                         [self.transitionContext cancelInteractiveTransition];
                         [self.transitionContext completeTransition:NO];
                         self.transitionContext=nil;
                     }];
    
    
    [self cancelInteractiveTransition];
}


- (void)finishInteractiveTransitionWithDuration:(CGFloat)duration{
    
    UIViewController* toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    RXDetailViewController* fromViewController = (RXDetailViewController *)[self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    
//    [fromViewController prepareLayoutForInteractiveTransition:1];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [fromViewController.view layoutIfNeeded];
                         //fromViewController.containerView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.5, 0.5), CGAffineTransformMakeTranslation(0, 400));
                         //fromViewController.containerView.alpha = 0;
                         //[fromViewController.scrollView setContentOffset:CGPointMake(0, -400) animated:NO];
                     } completion:^(BOOL finished) {
                         //[fromViewController.view removeFromSuperview];
                         [self.transitionContext completeTransition:YES];
                         self.transitionContext=nil;

                     }];
    
    [self finishInteractiveTransition];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    static BOOL dismissalBegan = NO;
    
    if (!scrollView.scrollEnabled) {
        //dismissalBegan = NO;
        return;
    }
    
    CGFloat percent = -scrollView.contentOffset.y / scrollView.frame.size.height;
    
    if (percent > 0.2) {
        if (!dismissalBegan) {
            scrollView.scrollEnabled = NO;
            scrollView.contentOffset = CGPointMake(0, -0.2*scrollView.frame.size.height);
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
            dismissalBegan = YES;
        }
        
//
//        
//        if (percent > 0.2) {
//            scrollView.scrollEnabled = NO;
//            scrollView.contentOffset = CGPointMake(0, -0.2*scrollView.frame.size.height);
//            [self finishInteractiveTransitionWithDuration:0.6];
//            _isDismissing = YES;
//            return;
//        }
//        
//        [self updateInteractiveTransition:percent];
        
        return;
    } else if (percent > 0) {
        _presentedViewController.titleBarTopConstraint.constant = _presentedViewController.scrollViewHeightConstraint.constant * percent;
        [_presentedViewController.view layoutIfNeeded];
    }
    
    dismissalBegan = NO;
    
}


@end

//
//  RVCardView.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-28.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCardView.h"
#import "RVMoreButton.h"
#import "RVCardViewCorner.h"
#import "RVCardViewButtonIcon.h"
#import "RVCloseButton.h"
#import "RVCardBarcodeView.h"
#import "RVCard.h"

#import <RSBarcodes/RSUnifiedCodeGenerator.h>

typedef enum : NSUInteger {
    RVButtonActionNone      =   0,
    RVButtonActionFavortie  =   1,
    RVButtonActionBarcode   =   2
} RVButtonAction;

@interface RVCardView()

@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) RVMoreButton *moreButton;
@property (strong, nonatomic) RVCardViewCorner *corner;
@property (strong, nonatomic) UITextView *longDescriptionTextView;

// Close button
@property (strong, nonatomic) RVCloseButton *closeButton;

// BarcodeView
@property (strong, nonatomic) RVCardBarcodeView *barcodeView;

// Constraints
@property (strong, nonatomic) NSLayoutConstraint *cornerTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *cornerRightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *moreButtonTopConstraint;

@end

@implementation RVCardView

- (void)setImageURL:(NSURL *)imageURL
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = image;
        });
    });
    _imageURL = imageURL;
}

- (void)setShadow:(CGFloat)shadow
{
    self.shadowView.layer.opacity = shadow;
    _shadow = shadow;
}

- (void)setLongDescription:(NSString *)longDescription
{
    NSArray *styles = @[ @"font: -apple-system-body;",
                         @"font-size: 14px;",
                         @"line-height: 21px;"];
    
    NSString *html = [NSString stringWithFormat:@"<div style=\"%@\">%@<div>", [styles componentsJoinedByString:@" "], longDescription];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    self.longDescriptionTextView.attributedText = attributedString;
    
    if (longDescription.length > 0) {
        self.moreButton.alpha = 1.0;
    } else {
        self.moreButton.alpha = 0.0;
    }
    
    _longDescription = longDescription;
}

- (void)setSecondaryBackgroundColor:(UIColor *)secondaryBackgroundColor {
    self.corner.backgroundColor = secondaryBackgroundColor;
    //self.buttonBar.activeColor = secondaryBackgroundColor;
    _secondaryBackgroundColor = secondaryBackgroundColor;
}

- (void)setSecondaryFontColor:(UIColor *)secondaryFontColor {
    self.corner.iconColor = secondaryFontColor;
    _secondaryFontColor = secondaryFontColor;
}

- (void)setLiked:(BOOL)liked {
    if (liked) {
        self.discarded = NO;
    }
    
    //if (!self.isExpanded) {
        if (liked) {
            self.cornerTopConstraint.constant = 0.0;
            self.cornerRightConstraint.constant = 0.0;
            [UIView animateWithDuration:0.2 animations:^{
                self.corner.alpha = 1.0;
                [self layoutIfNeeded];
            }];
        } else {
            self.cornerTopConstraint.constant = -30.0;
            self.cornerRightConstraint.constant = 30.0;
            [UIView animateWithDuration:0.2 animations:^{
                self.corner.alpha = 0.0;
                [self layoutIfNeeded];
            }];
        }
    //}
    
    _liked = liked;
    liked = liked; // Why?
}

- (void)setDiscarded:(BOOL)discarded {
    if (discarded) {
        self.liked = NO;
    }
    
    _discarded = discarded;
}

- (void)setUseCloseButton:(BOOL)useCloseButton {
    _useCloseButton = useCloseButton;
    self.closeButton.hidden = !self.useCloseButton;
}

- (void)setCard:(RVCard *)card
{
    self.title = card.title;
    self.shortDescription = card.shortDescription;
    
    if (card.longDescription) {
        self.longDescription = card.longDescription;
    }
    
    self.imageURL = card.imageURL;
    self.backgroundColor = card.primaryBackgroundColor;
    self.fontColor = card.primaryFontColor;
    self.secondaryBackgroundColor = card.secondaryBackgroundColor;
    self.secondaryFontColor = card.secondaryFontColor;
    self.liked = card.likedAt != nil;
    self.discarded = card.discardedAt != nil;
    
    if (card.barcode) {
        self.barcodeView = [[RVCardBarcodeView alloc] initWithFrame:self.frame];
        self.barcodeView.cardView = self;
        self.barcodeView.title = self.title;
        self.barcodeView.shortDescription = card.offerDetails;
        [self.barcodeView setBarcode:card.barcode withType:AVMetadataObjectTypeCode128Code];
    } else {
        self.barcodeView = nil;
    }
    
    [self.buttonBar setLeftButtonTitle:card.leftButtonCaption andRightButtonTitle:card.rightButtonCaption];
    [self.buttonBar setFontColor:card.primaryFontColor];
    
    _card = card;
}

#pragma mark - Private Properties



#pragma mark - Initialization

- (void)addSubviews
{
    [super addSubviews];
    
    self.shadowView = [[UIView alloc] initWithFrame:self.frame];
    self.shadowView.translatesAutoresizingMaskIntoConstraints = NO;
    self.shadowView.backgroundColor = [UIColor blackColor];
    self.shadowView.alpha = 0.0;
    self.shadowView.userInteractionEnabled = NO;
    [self addSubview:self.shadowView];
    
    self.corner = [RVCardViewCorner new];
    self.corner.translatesAutoresizingMaskIntoConstraints = NO;
    self.corner.alpha = 0.0;
    self.corner.icon.iconType = RVCardViewButtonIconTypeHeart;
    [self.containerView addSubview:self.corner];
    
    self.moreButton = [RVMoreButton new];
    self.moreButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.moreButton.alpha = 0.0;
    [self.contentView addSubview:self.moreButton];
    [self.contentView sendSubviewToBack:self.moreButton];
    
    self.longDescriptionTextView = [UITextView new];
    self.longDescriptionTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.longDescriptionTextView.font = [UIFont systemFontOfSize:14.0];
    self.longDescriptionTextView.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.5 blue:233.0/255.0 alpha:1.0];
    self.longDescriptionTextView.scrollEnabled = NO;
    self.longDescriptionTextView.editable = NO;
    self.longDescriptionTextView.alpha = 0.0;
    self.longDescriptionTextView.textContainerInset = UIEdgeInsetsMake(20.0, 20.0, 0.0, 20.0);
    [self.contentView addSubview:self.longDescriptionTextView];
}

- (void)configureLayout
{
    [super configureLayout];
    
    NSDictionary *views = @{ @"moreButton": self.moreButton,
                             @"shadowView": self.shadowView,
                             @"longDescriptionTextView": self.longDescriptionTextView,
                             @"corner": self.corner};
    
    //----------------------------------------
    //  shadowView
    //----------------------------------------
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[shadowView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[shadowView]|" options:0 metrics:nil views:views]];

    //----------------------------------------
    //  corner
    //----------------------------------------
    
    // Set the width and height of the corner
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[corner(60)]" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[corner(60)]" options:0 metrics:nil views:views]];
    
    // Pin the corner to the top edge
    self.cornerTopConstraint = [NSLayoutConstraint constraintWithItem:self.corner attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-30.0];
    [self.containerView addConstraint:self.cornerTopConstraint];
    
    // Pin the corner to the right edge
    self.cornerRightConstraint = [NSLayoutConstraint constraintWithItem:self.corner attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeRight multiplier:1.0 constant:30.0];
    [self.containerView addConstraint:self.cornerRightConstraint];
    
    //----------------------------------------
    //  moreButton
    //----------------------------------------
    
    // Width and height of moreButton
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[moreButton(50)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[moreButton(25)]" options:0 metrics:nil views:views]];

    // Horizontally center moreButton
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.moreButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];

    // Tie bottom edge of moreButton to top edge of imageView
    self.moreButtonTopConstraint = [NSLayoutConstraint constraintWithItem:self.moreButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:25.0];
    [self.contentView addConstraint:self.moreButtonTopConstraint];
    
    //----------------------------------------
    //  longDescription
    //----------------------------------------
    
    // Horizontal spacing of longDescription
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[longDescriptionTextView]|" options:0 metrics:nil views:views]];
    
    // Tie the bottom edge of longDescription to the contentView
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[longDescriptionTextView]|" options:0 metrics:nil views:views]];
    
    // Set the longDescription's minimum height so it always extends to the bottom edge of the screen
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat minHeight = screenBounds.size.height - 344.0;
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.longDescriptionTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1.0 constant:minHeight]];
    
    // Top position of longDescription
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.longDescriptionTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
}


#pragma mark - RVCardViewBarButtonDelegate

- (void)buttonBarLeftButtonPressed:(RVCardViewButtonBar *)buttonBar {
    [self performAction:self.card.leftButtonAction.integerValue];

}

- (void)buttonBarRightButtonPressed:(RVCardViewButtonBar *)buttonBar {
    [self performAction:self.card.rightButtonAction.integerValue];
}

#pragma mark - Button Actions

- (void)performAction:(RVButtonAction)action
{
    switch (action) {
        case RVButtonActionFavortie:
            [self likeButtonPressed];
            break;
        case RVButtonActionBarcode:
            [self barcodeButtonPressed];
            break;
        default:
            break;
    }
}

- (void)likeButtonPressed
{
    if (self.delegate) {
        [self.delegate cardViewLikeButtonPressed:self];
    }
}

- (void)barcodeButtonPressed
{
    if (self.isExpanded) {
        [self slideInBarcodeView];
    } else {
        [self flipCardToBarcodeView];
    }
}

#pragma mark - Expand/Contract

- (void)didShow
{
    self.moreButtonTopConstraint.constant = 0.0;
    [UIView animateWithDuration:0.1 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)expandToFrame:(CGRect)frame animated:(BOOL)animated
{
    self.moreButtonTopConstraint.constant = 25.0;
    
    [super expandToFrame:frame animated:animated];
    
    if (self.barcodeView) {
        [self.barcodeView expandToFrame:frame animated:NO];
    }
}

- (void)contractToFrame:(CGRect)frame atCenter:(CGPoint)center animated:(BOOL)animated
{
    self.moreButtonTopConstraint.constant = 0.0;
    
    [super contractToFrame:frame atCenter:center animated:animated];
    
    if (self.barcodeView) {
        [self.barcodeView contractToFrame:frame atCenter:center animated:NO];
    }
}

- (void)expandAnimations
{
    self.moreButton.alpha = 0.0;
    self.longDescriptionTextView.alpha = 1.0;
}

- (void)contractAnimations
{
    self.moreButton.alpha = 1.0;
    self.longDescriptionTextView.alpha = 0.0;
}

#pragma mark - Barcode Transitions

- (void)flipCardToBarcodeView
{
    self.barcodeView.frame = self.bounds;
    [UIView transitionWithView:self duration:0.4 options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [self.containerView removeFromSuperview];
                        [self addSubview:self.barcodeView];
                    }
                    completion:NULL];
}

- (void)slideInBarcodeView
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [self.layer addAnimation:transition forKey:nil];
    
    self.barcodeView.frame = self.bounds;
    [self.containerView removeFromSuperview];
    [self.barcodeView configureContainerLayout];
    [self addSubview:self.barcodeView];
}

@end
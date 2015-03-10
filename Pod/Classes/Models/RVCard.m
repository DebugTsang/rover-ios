//
//  RVCard.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-27.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVModelProject.h"
#import "RVCardProject.h"
#import "RVColorUtilities.h"

@implementation RVCard

#pragma mark - Properties

- (UIColor *)primaryBackgroundColor {
    if (!_primaryBackgroundColor) {
        return [UIColor colorWithRed:37.0/255.0 green:111.0/255.0 blue:203.0/255.0 alpha:1.0];
    }
    
    return _primaryBackgroundColor;
}

- (UIColor *)primaryFontColor {
    if (!_primaryFontColor) {
        return [UIColor whiteColor];
    }
    
    return _primaryFontColor;
}

- (UIColor *)secondaryBackgroundColor {
    if (!_secondaryBackgroundColor) {
        return [UIColor colorWithRed:37.0/255.0 green:111.0/255.0 blue:203.0/255.0 alpha:1.0];
    }
    
    return _secondaryBackgroundColor;
}

- (UIColor *)secondaryFontColor {
    if (!_secondaryFontColor) {
        return [UIColor whiteColor];
    }
    
    return _secondaryFontColor;
}

- (NSURL *)imageURL
{
    if (!_imageURL) {
        return nil;
    }
    
    NSInteger screenWidth = [UIScreen mainScreen].bounds.size.width * UIScreen.mainScreen.scale;
    NSInteger screenHeight;
    
    switch (screenWidth) {
        case 750:
            screenHeight = 469;
            break;
        case 1242:
            screenHeight = 776;
            break;
        default: {
            screenWidth = 640;
            screenHeight = 400;
        }
            break;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?w=%ld&h=%ld&fit=crop&fm=jpg", _imageURL.absoluteString, (long)screenWidth, (long)screenHeight]];
    
    return url;
}

#pragma mark - Initialization

- (id)initWithJSON:(NSDictionary *)JSON {
    self = [super initWithJSON:JSON];
    if (self) {
        self.isUnread = YES;
    }
    return self;
}

#pragma mark - Overridden Methods

- (NSString *)modelName {
    return @"card";
}

- (void)updateWithJSON:(NSDictionary *)JSON {
    [super updateWithJSON:JSON];
    
    // organizationTitle
    NSString *organizationTitle = [JSON objectForKey:@"organization_title"];
    if (organizationTitle != (id)[NSNull null] && [organizationTitle length] > 0) {
        self.organizationTitle = organizationTitle;
    }
    
    // title
    NSString *title = [JSON objectForKey:@"title"];
    if (title != (id)[NSNull null] && [title length] > 0) {
        self.title = title;
    }
    
    // cardId
    NSNumber *cardId = [JSON objectForKey:@"card_id"];
    if (cardId != (id)[NSNull null]) {
        self.cardId = cardId;
    }
    
    // shortDescription
    NSString *shortDescription = [JSON objectForKey:@"short_description_html"];
    if (shortDescription != (id)[NSNull null] && [shortDescription length] > 0) {
        self.shortDescription = shortDescription;
    }
    
    // longDescription
    NSString *longDescription = [JSON objectForKey:@"long_description"];
    if (longDescription != (id)[NSNull null] && [longDescription length] > 0) {
        self.longDescription = longDescription;
    }
    
    // imageURL
    NSString *imageURL = [JSON objectForKey:@"image_url"];
    if (imageURL != (id)[NSNull null] && [imageURL length] > 0) {
        self.imageURL = [NSURL URLWithString:imageURL];
    }
    
    // primaryBackgroundColor
    NSString *primaryBackgroundColor = [JSON objectForKey:@"primary_background_color"];
    if (primaryBackgroundColor != (id)[NSNull null] && [primaryBackgroundColor length] > 0) {
        self.primaryBackgroundColor = [RVColorUtilities colorFromHexString:primaryBackgroundColor];
    }
    
    // primaryFontColor
    NSString *primaryFontColor = [JSON objectForKey:@"primary_font_color"];
    if (primaryFontColor != (id)[NSNull null] && [primaryFontColor length] > 0) {
        self.primaryFontColor = [RVColorUtilities colorFromHexString:primaryFontColor];
    }
    
    // secondaryBackgroundColor
    NSString *secondaryBackgroundColor = [JSON objectForKey:@"secondary_background_color"];
    if (secondaryBackgroundColor != (id)[NSNull null] && [secondaryBackgroundColor length] > 0) {
        self.secondaryBackgroundColor = [RVColorUtilities colorFromHexString:secondaryBackgroundColor];
    }
    
    // secondaryFontColor
    NSString *secondaryFontColor = [JSON objectForKey:@"secondary_font_color"];
    if (secondaryFontColor != (id)[NSNull null] && [secondaryFontColor length] > 0) {
        self.secondaryFontColor = [RVColorUtilities colorFromHexString:secondaryFontColor];
    }
    
    NSDateFormatter *dateFormatter = [self dateFormatter];
    
    // viewedAt
    NSString *viewedAt = [JSON objectForKey:@"viewed_at"];
    if (viewedAt != (id)[NSNull null] && [viewedAt length] > 0) {
        self.viewedAt = [dateFormatter dateFromString:viewedAt];
    }
    
    // likedAt
    NSString *likedAt = [JSON objectForKey:@"liked_at"];
    if (likedAt != (id)[NSNull null] && [likedAt length] > 0) {
        self.likedAt = [dateFormatter dateFromString:likedAt];
    }
    
    // discardedAt
    NSString *discardedAt = [JSON objectForKey:@"discarded_at"];
    if (discardedAt != (id)[NSNull null] && [discardedAt length] > 0) {
        self.discardedAt = [dateFormatter dateFromString:discardedAt];
    }
    
    // expiresAt
    NSString *expiresAt = [JSON objectForKey:@"expires_at"];
    if (expiresAt != (id)[NSNull null] && [expiresAt length] > 0) {
        self.expiresAt = [dateFormatter dateFromString:expiresAt];
    }

    // buttons
    NSArray *buttons = [JSON objectForKey:@"buttons"];
    if (buttons != (id)[NSNull null] && [buttons count] > 0) {
        self.buttons = buttons;
    }
    
    // barcode
    NSString *barcode = [JSON objectForKey:@"barcode"];
    if (barcode != (id)[NSNull null] && [barcode length] > 0) {
        self.barcode = barcode;
    }
    
    // barcodeType
    NSNumber *barcodeType = [JSON objectForKey:@"barcode_type"];
    if (barcodeType != (id)[NSNull null]) {
        self.barcodeType = barcodeType;
    }
    
    // barcodeInstructions
    NSString *barcodeInstructions = [JSON objectForKey:@"barcode_instructions"];
    if (barcodeInstructions != (id)[NSNull null] && [barcodeInstructions length] > 0) {
        self.barcodeInstructions = barcodeInstructions;
    }
    
    // tags
    NSArray *tags = [JSON objectForKey:@"tags"];
    if (tags != (id)[NSNull null] && [tags count] > 0) {
        self.tags = tags;
    }
    
    // lastExpandedAt
    NSString *lastExpandedAt = [JSON objectForKey:@"last_expanded_at"];
    if (lastExpandedAt != (id)[NSNull null] && [lastExpandedAt length] > 0) {
        self.lastExpandedAt = [dateFormatter dateFromString:lastExpandedAt];
    }
    
    // lastViewedBarcodeAt
    NSString *lastViewedBarcodeAt = [JSON objectForKey:@"last_viewed_barcode_at"];
    if (lastViewedBarcodeAt != (id)[NSNull null] && [lastViewedBarcodeAt length] > 0) {
        self.lastViewedBarcodeAt = [dateFormatter dateFromString:lastViewedBarcodeAt];
    }
    
    // terms
    NSString *terms = [JSON objectForKey:@"terms"];
    if (terms != (id)[NSNull null] && [terms length] > 0) {
        self.terms = terms;
    }
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *JSON = [[super toJSON] mutableCopy];
    NSDateFormatter *dateFormatter = [self dateFormatter];
    
    // viewedAt
    if (self.viewedAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.viewedAt] forKey:@"viewed_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"viewed_at"];
    }
    
    // likedAt
    if (self.likedAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.likedAt] forKey:@"liked_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"liked_at"];
    }
    
    // discardedAt
    if (self.discardedAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.discardedAt] forKey:@"discarded_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"discarded_at"];
    }
    
    // expiresAt
    if (self.expiresAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.expiresAt] forKey:@"expires_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"expires_at"];
    }
    
    // lastExpandedAt
    if (self.lastExpandedAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.lastExpandedAt] forKey:@"last_expanded_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"last_expanded_at"];
    }
    
    // lastViewedBarcodeAt
    if (self.lastViewedBarcodeAt) {
        [JSON setObject:[dateFormatter stringFromDate:self.lastViewedBarcodeAt] forKey:@"last_viewed_barcode_at"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"last_viewed_barcode_at"];
    }
    
    // lastViewedFrom
    if (self.lastViewedFrom) {
        [JSON setObject:self.lastViewedFrom forKey:@"last_viewed_from"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"last_viewed_from"];
    }
    
    // lastViewedPosition
    if (self.lastViewedPosition) {
        [JSON setObject:self.lastViewedPosition forKey:@"last_viewed_position"];
    } else {
        [JSON setObject:[NSNull null] forKey:@"last_viewed_position"];
    }
    
    return JSON;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.organizationTitle forKey:@"organizationTitle"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.cardId forKey:@"cardId"];
    [encoder encodeObject:self.shortDescription forKey:@"shortDescription"];
    [encoder encodeObject:self.longDescription forKey:@"longDescription"];
    [encoder encodeObject:self.imageURL forKey:@"imageURL"];
    [encoder encodeObject:self.primaryBackgroundColor forKey:@"primaryBackgroundColor"];
    [encoder encodeObject:self.primaryFontColor forKey:@"primaryFontColor"];
    [encoder encodeObject:self.secondaryBackgroundColor forKey:@"secondaryBackgroundColor"];
    [encoder encodeObject:self.secondaryFontColor forKey:@"secondaryFontColor"];
    [encoder encodeObject:self.viewedAt forKey:@"viewedAt"];
    [encoder encodeObject:self.likedAt forKey:@"likedAt"];
    [encoder encodeObject:self.barcode forKey:@"barcode"];
    [encoder encodeObject:self.barcodeType forKey:@"barcodeType"];
    [encoder encodeObject:self.barcodeInstructions forKey:@"barcodeInstructions"];
    [encoder encodeObject:self.tags forKey:@"tags"];
    [encoder encodeObject:self.terms forKey:@"terms"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isUnread] forKey:@"isUnread"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.organizationTitle = [decoder decodeObjectForKey:@"organizationTitle"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.cardId = [decoder decodeObjectForKey:@"cardId"];
        self.shortDescription = [decoder decodeObjectForKey:@"shortDescription"];
        self.longDescription = [decoder decodeObjectForKey:@"longDescription"];
        self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
        self.primaryBackgroundColor = [decoder decodeObjectForKey:@"primaryBackgroundColor"];
        self.primaryFontColor = [decoder decodeObjectForKey:@"primaryFontColor"];
        self.secondaryBackgroundColor = [decoder decodeObjectForKey:@"secondaryBackgroundColor"];
        self.secondaryFontColor = [decoder decodeObjectForKey:@"secondaryFontColor"];
        self.viewedAt = [decoder decodeObjectForKey:@"viewedAt"];
        self.likedAt = [decoder decodeObjectForKey:@"likedAt"];
        self.barcode = [decoder decodeObjectForKey:@"barcode"];
        self.barcodeType = [decoder decodeObjectForKey:@"barcodeType"];
        self.barcodeInstructions = [decoder decodeObjectForKey:@"barcodeInstructions"];
        self.tags = [decoder decodeObjectForKey:@"tags"];
        self.terms = [decoder decodeObjectForKey:@"terms"];
        self.isUnread = [[decoder decodeObjectForKey:@"isUnread"] boolValue];
    }
    return self;
}
@end
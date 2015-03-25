//
//  RVVisit.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-26.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVModelProject.h"
#import "RVVisit.h"
#import "RVCardProject.h"
#import "RVLocation.h"
#import "RVTouchpoint.h"
#import "RVViewDefinition.h"
#import "RVCustomer.h"

#import "RVBlock.h"
#import "RVImageBlock.h"

#import "RVNetworkingManager.h"

#pragma mark - SystemCalls

#include <sys/sysctl.h>
NSString * getSysInfoByName(char *typeSpecifier)
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

NSString * platform()
{
    return getSysInfoByName("hw.machine");
}


@interface RVVisit ()

@property (nonatomic, strong) NSMutableArray *mVisitedTouchpoints;
@property (nonatomic, strong) NSSet *wildcardTouchpoints;

@end

@implementation RVVisit

#pragma mark - Overridden Properties

- (NSString *)modelName {
    return @"visit";
}

#pragma mark - Properties

- (BOOL)isAlive {
    NSDate *now = [NSDate date];
    NSTimeInterval elapsed = [now timeIntervalSinceDate:self.beaconLastDetectedAt];
    return elapsed < self.keepAlive;
}

- (NSArray *)allImageUrls {
    NSMutableArray *array = [NSMutableArray array];
    [self.touchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, NSUInteger idx, BOOL *stop) {
        [touchpoint.cards enumerateObjectsUsingBlock:^(RVCard *card, NSUInteger idx, BOOL *stop) {
            [card.viewDefinitions enumerateObjectsUsingBlock:^(RVViewDefinition *viewDefintion, NSUInteger idx, BOOL *stop) {
                [viewDefintion.blocks enumerateObjectsUsingBlock:^(RVBlock *block, NSUInteger idx, BOOL *stop) {
                    if ([block isKindOfClass:[RVImageBlock class]]) {
                        [array insertObject:((RVImageBlock *)block).imageURL atIndex:array.count];
                    }
                    
                    // add background images
                }];
                // add background image
            }];
        }];
    }];
    return [NSArray arrayWithArray:array];
}

- (void)setTimestamp:(NSDate *)timestamp
{
    self.beaconLastDetectedAt = timestamp;
    _timestamp = timestamp;
}

- (BOOL)isInLocationRegion:(CLBeaconRegion *)beaconRegion
{
    return [self.UUID.UUIDString isEqualToString:beaconRegion.proximityUUID.UUIDString]
        && [self.majorNumber isEqualToNumber:beaconRegion.major];
}

- (BOOL)isInTouchpointRegion:(CLBeaconRegion *)beaconRegion {
    for (RVTouchpoint *touchpoint in self.currentTouchpoints) {
        if ([touchpoint.minorNumber isEqualToNumber:beaconRegion.minor]) {
            return YES;
        }
    }
    return NO;
}

- (RVTouchpoint *)touchpointForRegion:(CLBeaconRegion *)beaconRegion
{
    return [self touchpointForMinor:beaconRegion.minor];
}

- (RVTouchpoint *)touchpointForMinor:(NSNumber *)minor
{
    __block RVTouchpoint *touchpoint = nil;
    [self.touchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *tp, NSUInteger idx, BOOL *stop) {
        if ([tp.minorNumber isEqualToNumber:minor]) {
            touchpoint = tp;
            *stop = YES;
        }
    }];
    return touchpoint;
}

- (NSSet *)wildcardTouchpoints {
    if (_wildcardTouchpoints) {
        return _wildcardTouchpoints;
    }
    
    _wildcardTouchpoints = [NSSet setWithArray:[self.touchpoints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RVTouchpoint *touchpoint, NSDictionary *bindings) {
        return touchpoint.trigger == RVTouchpointTriggerAnyBeacon;
    }]]];
    return _wildcardTouchpoints;
}

- (NSArray *)visitedTouchpoints
{
    return _mVisitedTouchpoints;
}

- (NSArray *)observableRegions {
    NSMutableArray *touchpointsWithNotification = [NSMutableArray array];
    [self.touchpoints enumerateObjectsUsingBlock:^(RVTouchpoint *touchpoint, NSUInteger idx, BOOL *stop) {
        if (touchpoint.trigger != RVTouchpointTriggerAnyBeacon && touchpoint.notification && ![touchpoint.notification isEqualToString:@""]) {
            [touchpointsWithNotification addObject:[[CLBeaconRegion alloc] initWithProximityUUID:self.UUID major:self.majorNumber.integerValue minor:touchpoint.minorNumber.integerValue identifier:[NSString stringWithFormat:@"%@-%@-%@", self.UUID.UUIDString, self.majorNumber, touchpoint.minorNumber]]];
        }
    }];
    return touchpointsWithNotification;
}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        _mVisitedTouchpoints = [NSMutableArray array];
        _currentTouchpoints = [NSMutableSet set];
    }
    return self;
}

- (void)updateWithJSON:(NSDictionary *)JSON {
    [super updateWithJSON:JSON];

    // TODO: investigate this (how does this impact [Rover shared].custome)
    // customer
//    NSString *customerID = [JSON objectForKey:@"customer"];
//    if (customerID && customerID != (id)[NSNull null] && [customerID length] > 0) {
//        self.customer = customerID;
//    }
    
    // keepAlive
    NSNumber *keepAlive = [JSON objectForKey:@"keepAlive"];
    if (keepAlive && keepAlive != (id)[NSNull null]) {
        self.keepAlive = [keepAlive doubleValue] * 60;
    }
    
    //location
    NSDictionary *locationData = [JSON objectForKey:@"location"];
    if (locationData) {
        RVLocation *location = [[RVLocation alloc] initWithJSON:locationData];
        self.location = location;
    }
    
    //touchpoints
    NSArray *touchpointsData = [JSON objectForKey:@"touchpoints"];
    if (touchpointsData && touchpointsData != (id)[NSNull null]) {
        NSMutableArray *touchpoints = [NSMutableArray arrayWithCapacity:[touchpointsData count]];
        [touchpointsData enumerateObjectsUsingBlock:^(NSDictionary *touchpointData, NSUInteger idx, BOOL *stop) {
            RVTouchpoint *touchpoint = [[RVTouchpoint alloc] initWithJSON:touchpointData];
            [touchpoints addObject:touchpoint];
        }];
        self.touchpoints = [touchpoints copy];
    }
    
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *JSON = [NSMutableDictionary dictionary];
    
    // UUID
    [JSON setObject:RVNullSafeValueFromObject(self.UUID.UUIDString) forKey:@"uuid"];

    // major
    [JSON setObject:RVNullSafeValueFromObject(self.majorNumber) forKey:@"majorNumber"];

    // customer
    [JSON setObject:RVNullSafeValueFromObject([self.customer toJSON]) forKey:@"customer"];
    
    // device
    [JSON setObject:platform() forKey:@"device"];
    
    // operatingSystem
    [JSON setObject:[[UIDevice currentDevice] systemName] forKey:@"operatingSystem"];
    
    // operatingSystemVersion
    [JSON setObject:[[UIDevice currentDevice] systemVersion] forKey:@"osVersion"];
    
    // timestamp
    [JSON setObject:[[self dateFormatter] stringFromDate:self.timestamp] forKey:@"timestamp"];
    
    // version (SDK)
    // TODO: setup a compiler constant to handle this
    [JSON setObject:@"0.3.0" forKey:@"sdkVersion"];
    
    
    // TODO: REMOVE THIS AND MAKE IT PART OF DEBUG
    //[JSON setObject:@YES forKey:@"simulate"];
    
    return JSON;
}


- (void)save:(void (^)(void))success failure:(void (^)(NSString *))failure
{
    [super save:^{
        [self persistToDefaults];
        if (success) {
            success();
        }
    } failure:failure];
}

- (void)persistToDefaults
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self] forKey:@"_roverLatestVisit"];
    [standardDefaults synchronize];
}

- (void)trackEvent:(NSString *)event params:(NSDictionary *)params {
    NSLog(@"Tracking (%@)", event);
    
    NSArray *eventComponents = [event componentsSeparatedByString:@"."];
    
    NSMutableDictionary *eventParams = [NSMutableDictionary dictionaryWithDictionary:@{@"object": eventComponents[0],
                                                                                       @"action": eventComponents[1],
                                                                                       @"timestamp": [[self dateFormatter] stringFromDate:[NSDate date]]}];
    
    [eventParams addEntriesFromDictionary:params];
    
    NSString *path = [NSString stringWithFormat:@"%@/events", [self updatePath]];
    
    [[RVNetworkingManager sharedManager] sendRequestWithMethod:@"POST" path:path parameters:eventParams success:^(NSDictionary *data) {
        NSLog(@"%@ tracked successfully", event);
    } failure:^(NSError *error) {
        NSLog(@"%@ failed: %@",event, error);
    }];
}

#pragma mark - Touchpoint Tracking

- (void)addToCurrentTouchpoints:(RVTouchpoint *)touchpoint {
    [self.currentTouchpoints addObject:touchpoint];
    if (!touchpoint.isVisited/*![_mVisitedTouchpoints containsObject:touchpoint]*/) {
        [self willChangeValueForKey:@"visitedTouchpoints"];
        touchpoint.isVisited = YES;
        [_mVisitedTouchpoints insertObject:touchpoint atIndex:0];
        [self didChangeValueForKey:@"visitedTouchpoints"];
    }
}

- (void)removeFromCurrentTouchpoints:(RVTouchpoint *)touchpoint {
    [self.currentTouchpoints removeObject:touchpoint];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.UUID forKey:@"UUID"];
    [encoder encodeObject:self.majorNumber forKey:@"majorNumber"];
    [encoder encodeObject:[NSNumber numberWithDouble:self.keepAlive] forKey:@"keepAlive"];
    [encoder encodeObject:self.timestamp forKey:@"timestamp"];
    [encoder encodeObject:self.organization forKey:@"organization"];
    [encoder encodeObject:self.location forKey:@"location"];
    // TODO: do we need customer? its already in [[Rover shared] customer]
    [encoder encodeObject:self.beaconLastDetectedAt forKey:@"beaconLastDetecedAt"];
    [encoder encodeObject:self.touchpoints forKey:@"touchpoints"];
    // TODO: do something about visitedTouchpoints (this will by default create duplicate RVTouchpoint objects)
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        self.UUID = [decoder decodeObjectForKey:@"UUID"];
        self.majorNumber = [decoder decodeObjectForKey:@"majorNumber"];
        self.keepAlive = [[decoder decodeObjectForKey:@"keepAlive"] doubleValue];
        self.timestamp = [decoder decodeObjectForKey:@"timestamp"];
        self.organization = [decoder decodeObjectForKey:@"organization"];
        self.location = [decoder decodeObjectForKey:@"location"];
        // TODO: customer?
        self.beaconLastDetectedAt = [decoder decodeObjectForKey:@"beaconLastDetecedAt"];
        self.touchpoints = [decoder decodeObjectForKey:@"touchpoints"];
        
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<RVVisit: UUID: %@, Major: %@, enteredAt: %@, beaconLastDetectedAt: %@, keepAlive: %f>",
            self.UUID, self.majorNumber, self.timestamp, self.beaconLastDetectedAt, self.keepAlive];
}

@end
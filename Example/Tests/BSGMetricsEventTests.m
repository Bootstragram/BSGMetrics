//
//  BSGMetricsEventTests.m
//  BSGMetrics
//
//  Created by Mickaël Floc'hlay on 14/06/2016.
//  Copyright © 2016 Mickaël Floc’hlay. All rights reserved.
//

#import <XCTest/XCTest.h>

@import BSGMetrics;
#import <BSGMetrics/BSGMetricsService.h>

@interface BSGMetricsEventTests : XCTestCase

@property(strong, nonatomic) BSGMetricsEvent *event;
@property(strong, nonatomic) BSGMetricsService *service;

@end

@interface BSGMetricsService (BSGMetricsEventTests)

- (NSDictionary *)activityDictionaryFromEvent:(BSGMetricsEvent *)event;

@end

@interface BSGMetricsEvent (BSGMetricsEventTests)

- (void)testOnlySetCreatedAt:(NSDate *)date;
+ (BSGMetricsEvent *)eventWithUserInfo:(NSDictionary *)userInfo;

@end

@implementation BSGMetricsEventTests

- (void)setUp {
    [super setUp];

    self.event = [BSGMetricsEvent eventWithUserInfo:@{ @"myUnitTestKey": @"myUnitTestValue" }];
    self.service = [[BSGMetricsService alloc] initWithConfig:nil];
}

- (void)tearDown {
    self.event = nil;

    [super tearDown];
}

- (void)testDatesAreUTCFormatted {
    // 1465917627.123 is June 14th 2016 - 17:20:27 Paris time
    // ie June 14th 2016 - 15:20:27 UTC
    [_event testOnlySetCreatedAt:[NSDate dateWithTimeIntervalSince1970:1465917627.123]];
    XCTAssertTrue([_event save]);

    NSDictionary *activity = [_service activityDictionaryFromEvent:_event];
    NSString *createdAtString = [activity objectForKey:@"createdAt"];
    XCTAssertTrue([createdAtString isEqualToString:@"2016-06-14T15:20:27.123Z"], @"%@ is not UTC.", createdAtString);
}

@end

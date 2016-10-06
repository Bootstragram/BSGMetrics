//
//  BSGMetricsEvent.m
//  Pods
//
//  Created by Mickaël Floc'hlay on 01/06/2016.
//
//

#import "BSGMetricsEvent.h"

@interface BSGMetricsEvent ()

@property(nonatomic) int64_t id;

// Redeclare as readwrite
@property(strong, readwrite, nonatomic) NSDate *createdAt;
@property(strong, readwrite, nonatomic) NSString *version;
@property(strong, readwrite, nonatomic) NSDictionary *userInfo;

@end

@implementation BSGMetricsEvent

- (void)setValuesWithUserInfo:(NSDictionary *)userInfo {
    _userInfo = userInfo;
    _createdAt = [NSDate date];
    _status = BSGMetricsEventStatusCreated;
    _retryCount = 0;
    _version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}


+ (BSGMetricsEvent *)eventWithUserInfo:(NSDictionary *)userInfo {
    BSGMetricsEvent *newEvent = [BSGMetricsEvent new];
    [newEvent setValuesWithUserInfo:userInfo];
    FCModelSaveResult saveResult = [newEvent save];

    switch (saveResult) {
        case FCModelSaveFailed: {
            return nil;
        }
        case FCModelSaveRefused: {
            return nil;
        }
        case FCModelSaveNoChanges: {
            return newEvent;
        }
        case FCModelSaveSucceeded: {
            return newEvent;
        }
        default: {
            return nil;
        }
    }
}


- (void)testOnlySetCreatedAt:(NSDate *)date {
    _createdAt = date;
}


@end

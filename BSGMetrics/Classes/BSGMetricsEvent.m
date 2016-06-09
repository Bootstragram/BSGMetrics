//
//  BSGMetricsEvent.m
//  Pods
//
//  Created by Mickaël Floc'hlay on 01/06/2016.
//
//

#import "BSGMetricsEvent.h"

@implementation BSGMetricsEvent

- (void)setValuesWithUserInfo:(NSDictionary *)userInfo {
    _userInfo = userInfo;
    _createdAt = [NSDate date];
    _status = BSGMetricsEventStatusCreated;
    _retryCount = 0;
    _version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}


+ (BOOL)eventWithUserInfo:(NSDictionary *)userInfo {
    BSGMetricsEvent *newEvent = [BSGMetricsEvent new];
    [newEvent setValuesWithUserInfo:userInfo];
    FCModelSaveResult saveResult = [newEvent save];

    switch (saveResult) {
        case FCModelSaveFailed: {
            return NO;
        }
        case FCModelSaveRefused: {
            return NO;
        }
        case FCModelSaveNoChanges: {
            return YES;
        }
        case FCModelSaveSucceeded: {
            return YES;
        }
        default: {
            return NO;
        }
    }
}


@end

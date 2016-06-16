//
//  BSGMetricsEvent.h
//  Pods
//
//  Created by Mickaël Floc'hlay on 01/06/2016.
//
//

#import <Foundation/Foundation.h>
#import "FCModel.h"

typedef NS_ENUM(NSInteger, BSGMetricsEventStatus) {
    BSGMetricsEventStatusCreated = 1,
    BSGMetricsEventStatusSentWithSuccess = 2,
    BSGMetricsEventStatusSentWithError = 3
};

@interface BSGMetricsEvent : FCModel

@property(nonatomic) int64_t id;
@property(strong, nonatomic) NSDictionary *userInfo;
@property(strong, nonatomic) NSDate *createdAt;
@property(nonatomic) BSGMetricsEventStatus status;
@property(nonatomic) NSString *version;
@property(nonatomic) NSInteger retryCount;


- (instancetype)init NS_UNAVAILABLE;

+ (BSGMetricsEvent *)eventWithUserInfo:(NSDictionary *)userInfo;

@end

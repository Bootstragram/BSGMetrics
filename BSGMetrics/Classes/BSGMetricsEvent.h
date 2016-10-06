//
//  BSGMetricsEvent.h
//  Pods
//
//  Created by Mickaël Floc'hlay on 01/06/2016.
//
//

#import <Foundation/Foundation.h>
#import <FCModel/FCModel.h>


typedef NS_ENUM(NSInteger, BSGMetricsEventStatus) {
    BSGMetricsEventStatusCreated = 1,
    BSGMetricsEventStatusSentWithSuccess = 2,
    BSGMetricsEventStatusSentWithError = 3
};

@interface BSGMetricsEvent : FCModel

@property(strong, readonly, nonatomic) NSDate *createdAt;
@property(strong, readonly, nonatomic) NSString *version;
@property(strong, readonly, nonatomic) NSDictionary *userInfo;
@property(nonatomic) BSGMetricsEventStatus status;
@property(nonatomic) NSInteger retryCount;

- (instancetype)init NS_UNAVAILABLE;

+ (BSGMetricsEvent *)eventWithUserInfo:(NSDictionary *)userInfo;

@end

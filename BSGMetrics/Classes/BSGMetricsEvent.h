//
//  BSGMetricsEvent.h
//  Pods
//
//  Created by Mickaël Floc'hlay on 01/06/2016.
//
//

#import <Foundation/Foundation.h>
#import "FCModel.h"

typedef NS_ENUM(NSInteger, BSGEventStatus) {
    /**
     *  Team 1 won.
     */
    BSGEventStatusCreated = 1,
    BSGEventStatusSentWithSuccess = 2,
    BSGEventStatusSentWithError = 3
};

@interface BSGMetricsEvent : FCModel

@property(nonatomic) int64_t id;
@property(strong, nonatomic) NSDictionary *userInfo;
@property(strong, nonatomic) NSDate *createdAt;
@property(nonatomic) BSGEventStatus status;

- (instancetype)init NS_UNAVAILABLE;

+ (BOOL)eventWithUserInfo:(NSDictionary *)userInfo;

@end

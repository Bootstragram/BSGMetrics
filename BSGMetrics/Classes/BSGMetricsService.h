//
//  BSGMetricsService.h
//  Pods
//
//  Created by Mickaël Floc'hlay on 01/06/2016.
//
//

#import <Foundation/Foundation.h>
#import "BSGMetricsEvent.h"
#import "BSGMetricsConfiguration.h"

@import AFNetworking;

typedef NS_ENUM(NSInteger, BSGMetricsServiceResponseStatusCode) {
    BSGMetricsServiceResponseStatusCodeOK = 200,
    BSGMetricsServiceResponseStatusCodePartialOK = 202,
    BSGMetricsServiceResponseStatusCodeMalformed = 400,
    BSGMetricsServiceResponseStatusCodeSystemError = 500,
};

@interface BSGMetricsService : NSObject

@property(strong, nonatomic) AFHTTPSessionManager *manager;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConfig:(BSGMetricsConfiguration *)configuration;

- (void)postEventsWithStatus:(BSGMetricsEventStatus)status limit:(NSInteger)limit completion:(void (^)(BOOL success))callback;

@end

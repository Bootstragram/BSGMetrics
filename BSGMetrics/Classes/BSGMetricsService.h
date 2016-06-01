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

@interface BSGMetricsService : NSObject

@property(strong, nonatomic) AFHTTPSessionManager *manager;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConfig:(BSGMetricsConfiguration *)configuration;

- (void)postEventsWithStatus:(BSGEventStatus)status limit:(NSInteger)limit;

@end

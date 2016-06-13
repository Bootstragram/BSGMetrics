//
//  BSGMetrics.h
//  Pods
//
//  Created by Mickaël Floc'hlay on 01/06/2016.
//
//

#import <Foundation/Foundation.h>
#import "BSGMetricsEvent.h"
#import "BSGMetricsConfiguration.h"
#import "BSGMetricsService.h"


@interface BSGMetrics : NSObject

@property(strong, nonatomic) BSGMetricsService *service;
@property(strong, nonatomic) BSGMetricsConfiguration *configuration;
@property(copy, nonatomic) void(^sendCompletion) (BOOL);
@property(nonatomic) BOOL started;

+ (BSGMetrics *)openWithConfiguration:(BSGMetricsConfiguration *)configuration;

- (void)startSendingWithCompletion:(void (^)(BOOL success))callback;
- (void)startSending;

- (void)stopSending;

- (void)pruneMessagesKO;

@end

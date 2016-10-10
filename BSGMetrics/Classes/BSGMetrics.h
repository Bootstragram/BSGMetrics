//
//  BSGMetrics.h
//  Pods
//
//  Created by Mickaël Floc'hlay on 01/06/2016.
//
//

#import <Foundation/Foundation.h>
#import "BSGMetricsConfiguration.h"


@interface BSGMetrics : NSObject

+ (BSGMetrics *)openWithConfiguration:(BSGMetricsConfiguration *)configuration;

- (id)init NS_UNAVAILABLE;
- (id)initWithConfiguration:(BSGMetricsConfiguration *)configuration;

- (void)startSendingWithCompletion:(void (^)(BOOL success))callback;
- (void)stopSending;
- (void)pruneMessagesKO;

- (void)eventWithUserInfo:(NSDictionary *)userInfo;

@end

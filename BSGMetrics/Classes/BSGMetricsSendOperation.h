//
//  BSGMetricsSendOperation.h
//  Pods
//
//  Created by Mickaël Floc'hlay on 10/10/2016.
//
//

#import <Foundation/Foundation.h>
#import "BSGMetricsService.h"


/**
 The operation for sending events to the server.
 */
@interface BSGMetricsSendOperation : NSOperation


/**
 DO NOT USE init
 */
- (id)init NS_UNAVAILABLE;


/**
 Creates a new operation instance

 @param service  the service to use to send the operation
 @param callback the completion block to call

 @return a newly allocated instance
 */
- (id)initWithService:(BSGMetricsService *)service andCompletion:(void (^)(BOOL success))callback;

@end

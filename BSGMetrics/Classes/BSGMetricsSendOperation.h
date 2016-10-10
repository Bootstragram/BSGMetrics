//
//  BSGMetricsSendOperation.h
//  Pods
//
//  Created by Mickaël Floc'hlay on 10/10/2016.
//
//

#import <Foundation/Foundation.h>
#import "BSGMetricsService.h"


@interface BSGMetricsSendOperation : NSOperation

- (id)init NS_UNAVAILABLE;
- (id)initWithService:(BSGMetricsService *)service andCompletion:(void (^)(BOOL success))callback;

@end

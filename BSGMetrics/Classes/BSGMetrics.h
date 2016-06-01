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

+ (BSGMetrics *)open;

- (void)startSending;
- (void)prune;
- (void)redo;

@end

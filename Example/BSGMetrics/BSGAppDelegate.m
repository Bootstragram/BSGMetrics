//
//  BSGAppDelegate.m
//  BSGMetrics
//
//  Created by Mickaël Floc’hlay on 06/01/2016.
//  Copyright (c) 2016 Mickaël Floc’hlay. All rights reserved.
//

#import "BSGAppDelegate.h"



@implementation BSGAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BSGMetricsConfiguration *configuration = [[BSGMetricsConfiguration alloc] init];
    configuration.baseURL = @"http://localhost:4567";
    configuration.path = @"/";
    configuration.limit = 10;
    configuration.frequency = 5;
    configuration.maxRetries = 5;

    self.metrics = [BSGMetrics openWithConfiguration:configuration];

    return YES;
}


@end

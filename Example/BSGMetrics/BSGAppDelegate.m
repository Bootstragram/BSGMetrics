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
    configuration.baseURL = @"https://dev.bootstragram.com:4567";
    configuration.path = @"/";
    configuration.limit = 10;
    configuration.frequency = 5;
    configuration.maxRetries = 5;

    _metrics = [BSGMetrics openWithConfiguration:configuration];

    return YES;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
#ifdef DEBUG
    NSString *buildConfiguration = [[NSProcessInfo processInfo] environment][@"TEST"];
    if (buildConfiguration != nil) {
        NSLog(@"Test mode");
        return;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(collectMetricsEvent:)
                                                 name:@"BSGMetricsNotification"
                                               object:nil];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *firstLaunch = [userDefaults objectForKey:@"SMIFirstLaunch"];
    if (!firstLaunch) {
        firstLaunch = [NSDate date];
        [userDefaults setObject:firstLaunch forKey:@"SMIFirstLaunch"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BSGMetricsNotification"
                                                        object:self
                                                      userInfo:@{ @"event": @"launch" }];
    [_metrics startSendingWithCompletion:^(BOOL success) {
        NSLog(@"[Delegate] Sent metrics? %@", success ? @"YES" : @"NO");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BSGMetricsRefreshRequired"
                                                            object:nil];
    }];
#endif
}


- (void)applicationWillResignActive:(UIApplication *)application {
    [_metrics stopSending];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"BSGMetricsNotification"
                                                  object:nil];
}


- (void)collectMetricsEvent:(NSNotification *)notification {
    [_metrics eventWithUserInfo:notification.userInfo];
}


@end

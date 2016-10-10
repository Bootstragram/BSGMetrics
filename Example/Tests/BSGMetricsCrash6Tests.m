//
//  BSGMetricsCrash6Tests.m
//  BSGMetrics
//
//  Created by Mickaël Floc'hlay on 10/10/2016.
//  Copyright © 2016 Mickaël Floc’hlay. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BSGAppDelegate.h"
#import "BSGMetrics.h"


@interface BSGMetricsCrash6Tests : XCTestCase

@end

@implementation BSGMetricsCrash6Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.

    BSGAppDelegate *appDelegate = (BSGAppDelegate *)[[UIApplication sharedApplication] delegate];

    // 2. Create a messaging queue
    NSOperationQueue *sendingOperationQueue = [[NSOperationQueue alloc] init];
    NSLog(@"Concurrency: %ld", (long)sendingOperationQueue.maxConcurrentOperationCount);
    for (NSInteger j = 0; j < 10; j++) {
        NSBlockOperation *theOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"Start operation");
            for (NSInteger k = 0; k < 10; k++) {
                [appDelegate.metrics eventWithUserInfo:@{ @"key": @"send0" }];
            }
            NSLog(@"End operation");
        }];
        [sendingOperationQueue addOperation:theOperation];
    }

    // 1. Create an operation queue
    NSOperationQueue *startStopOperationQueue = [[NSOperationQueue alloc] init];
    NSLog(@"Concurrency: %ld", (long)startStopOperationQueue.maxConcurrentOperationCount);
    for (NSInteger i = 0; i < 50; i++) {
        NSBlockOperation *theOperation = [NSBlockOperation blockOperationWithBlock:^{
            if (i % 2 == 0) {
                if (arc4random_uniform(10) < 2) {
                    // Noise
                    [appDelegate.metrics stopSending];
                } else {
                    // Regular operation
                    [appDelegate.metrics startSendingWithCompletion:^(BOOL success) {
                        NSLog(@"[Delegate] Sent metrics? %@", success ? @"YES" : @"NO");
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"BSGMetricsRefreshRequired"
                                                                            object:nil];
                    }];
                }
            } else {
                if (arc4random_uniform(10) < 2) {
                    // Noise
                    [appDelegate.metrics startSendingWithCompletion:^(BOOL success) {
                        NSLog(@"[Delegate] Sent metrics? %@", success ? @"YES" : @"NO");
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"BSGMetricsRefreshRequired"
                                                                            object:nil];
                    }];
                } else {
                    // Regular operation
                    [appDelegate.metrics stopSending];
                }
            }
        }];
        [startStopOperationQueue addOperation:theOperation];
    }

    NSLog(@"Waiting");
    [startStopOperationQueue waitUntilAllOperationsAreFinished];
    [sendingOperationQueue waitUntilAllOperationsAreFinished];
    NSLog(@"Done");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

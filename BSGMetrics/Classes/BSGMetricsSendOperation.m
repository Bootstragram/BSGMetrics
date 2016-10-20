//
//  BSGMetricsSendOperation.m
//  Pods
//
//  Created by Mickaël Floc'hlay on 10/10/2016.
//
//

#import "BSGMetricsSendOperation.h"

@interface BSGMetricsSendOperation ()

@property(atomic, assign, getter=isFinished) BOOL privateFinished;
@property(atomic, assign, getter=isExecuting) BOOL privateExecuting;
@property(atomic, weak) BSGMetricsService *service;
@property(copy, nonatomic) void(^sendCompletion) (BOOL);

@end


@implementation BSGMetricsSendOperation

- (id)initWithService:(BSGMetricsService *)service andCompletion:(void (^)(BOOL success))callback {
    self = [super init];
    if (self) {
        _privateExecuting = NO;
        _privateFinished = NO;

        self.service = service;
        self.sendCompletion = callback;
    }

    return self;
}


- (BOOL)isAsynchronous {
    return YES;
}


- (void)start {
    if (self.isCancelled) {
        [self willChangeValueForKey:@"isFinished"];
        _privateFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main)
                             toTarget:self
                           withObject:nil];
    _privateExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
}


- (void)main {
    if ([self isCancelled]) {
        return;
    }

    [self.service postEventsWithCompletion:^(BOOL success) {
        _sendCompletion(success);
        [self completeOperation];
    }];
}


- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];

    _privateExecuting = NO;
    _privateFinished = YES;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end

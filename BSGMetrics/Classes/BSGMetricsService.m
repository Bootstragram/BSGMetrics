//
//  BSGMetricsService.m
//  Pods
//
//  Created by Mickaël Floc'hlay on 01/06/2016.
//
//

#import "BSGMetricsService.h"
#import "BSGMetricsConfiguration.h"


@interface BSGMetricsService ()

@property(strong) NSDateFormatter *dateFormatter;

@end


@implementation BSGMetricsService


- (instancetype)initWithConfig:(BSGMetricsConfiguration *)configuration {
    self = [super init];
    if (self) {
        _configuration = configuration;

        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_configuration.baseURL]];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];

        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    }
    return self;
}


- (NSDictionary *)activityDictionaryFromEvent:(BSGMetricsEvent *)event {
    return @{
            @"createdAt": [_dateFormatter stringFromDate:event.createdAt],
            @"appVersion": event.version,
            @"localeID": [NSLocale currentLocale].localeIdentifier,
            @"os": @{
                @"name": [[UIDevice currentDevice] systemName],
                @"version": [[UIDevice currentDevice] systemVersion]
            },
            @"deviceModel": [[UIDevice currentDevice] model],
            @"info": event.userInfo
            };
}


- (void)postEventsWithCompletion:(void (^)(BOOL success))callback {
    NSArray *events = [BSGMetricsEvent instancesWhere:@"(status = ?) OR (status = ? AND retryCount < ?) ORDER BY createdAt LIMIT ?",
                       [NSNumber numberWithInteger:BSGMetricsEventStatusCreated],
                       [NSNumber numberWithInteger:BSGMetricsEventStatusSentWithError],
                       [NSNumber numberWithInteger:_configuration.maxRetries],
                       [NSNumber numberWithInteger:_configuration.limit]];

    if ([events count] == 0) {
        callback(YES);
    } else {
        NSMutableArray *activities = [NSMutableArray arrayWithCapacity:events.count];

        [events enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [activities addObject:[self activityDictionaryFromEvent:(BSGMetricsEvent *)obj]];
        }];

#ifdef DEBUG
        NSLog(@"[BSGMetrics][%@] Posting...", [NSThread currentThread]);
#endif
        [_manager POST:_configuration.path
            parameters:@{
                         @"userID": [UIDevice currentDevice].identifierForVendor.UUIDString,
                         @"appID": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"],
                         @"activities": activities
                         }
              progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#ifdef DEBUG
                  NSLog(@"[BSGMetrics][%@] Got success response…", [NSThread currentThread]);
#endif

                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                  [self manageSuccessForEvents:events
                                      response:responseObject
                                    statusCode:httpResponse.statusCode];
                  callback(TRUE);
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#ifdef DEBUG
                  NSLog(@"[BSGMetrics][%@] Got failure response…", [NSThread currentThread]);
#endif

                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                  [self manageErrorsForEvents:events
                                   statusCode:httpResponse.statusCode];
                  callback(FALSE);
              }];
    }
}


- (void)updateEvents:(NSArray *)eventsArray withStatus:(BSGMetricsEventStatus)status {
    [eventsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BSGMetricsEvent *event = (BSGMetricsEvent *)obj;
        event.status = status;
        [event save];
    }];
}


- (void)updateEvents:(NSArray *)eventsArray withErrorStatus:(BSGMetricsEventStatus)status {
    [eventsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BSGMetricsEvent *event = (BSGMetricsEvent *)obj;
        event.status = status;
#ifdef DEBUG
        NSLog(@"[BSGMetrics] DEBUG RetryCount bumped from... %li", (long)event.retryCount);
#endif
        event.retryCount += 1;
#ifdef DEBUG
        NSLog(@"[BSGMetrics] DEBUG to... %li", (long)event.retryCount);
#endif
        [event save];
    }];
}


- (void)manageSuccessForEvents:(NSArray *)events response:(id)responseObject statusCode:(BSGMetricsServiceResponseStatusCode)statusCode {
    NSMutableArray *messagesOK = [NSMutableArray array];
    NSMutableArray *messagesNOK = [NSMutableArray array];

    switch(statusCode) {
        case BSGMetricsServiceResponseStatusCodeOK: {
            // Everything is OK.
            [messagesOK addObjectsFromArray:events];
            break;
        }

        case BSGMetricsServiceResponseStatusCodePartialOK: {
            // Sort between OK and NOK messages
            NSArray *reportsPerEvent = (NSArray *)[((NSDictionary *)responseObject) objectForKey:@"report"];
            [reportsPerEvent enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *eventReport = (NSDictionary *)obj;
                NSNumber *recorded = [eventReport objectForKey:@"recorded"];
                if ([recorded boolValue]) {
                    [messagesOK addObject:[events objectAtIndex:idx]];
                } else {
                    NSLog(@"[BSGMetrics] WARN Event not recorded: %@", [eventReport objectForKey:@"message"]);
                    [messagesNOK addObject:[events objectAtIndex:idx]];
                }
            }];
            break;
        }

        default: {
            NSLog(@"[BSGMetrics] ERROR Unexpected status code %li", (long)statusCode);
        }
    }

    [self updateEvents:messagesOK withStatus:BSGMetricsEventStatusSentWithSuccess];
    [self updateEvents:messagesNOK withErrorStatus:BSGMetricsEventStatusSentWithError];
}


- (void)manageErrorsForEvents:(NSArray *)events statusCode:(BSGMetricsServiceResponseStatusCode)statusCode {
    switch(statusCode) {
        case BSGMetricsServiceResponseStatusCodeMalformed: {
            NSLog(@"[BSGMetrics] WARN Malformed messages");
            break;
        }
        case BSGMetricsServiceResponseStatusCodeSystemError: {
            NSLog(@"[BSGMetrics] WARN System errors");
            break;
        }

        default: {
            NSLog(@"[BSGMetrics] ERROR Unexpected status code %li", (long)statusCode);
        }
    }

    [self updateEvents:events withErrorStatus:BSGMetricsEventStatusSentWithError];
}


@end

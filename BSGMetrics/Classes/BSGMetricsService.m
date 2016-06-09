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
        [_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
    }
    return self;
}


- (void)postEventsWithLimit:(NSInteger)limit completion:(void (^)(BOOL success))callback {
    NSArray *events = [BSGMetricsEvent instancesWhere:@"(status = ?) OR (status = ? AND retryCount < ?) ORDER BY createdAt LIMIT ?",
                       [NSNumber numberWithInteger:BSGMetricsEventStatusCreated],
                       [NSNumber numberWithInteger:BSGMetricsEventStatusSentWithError],
                       [NSNumber numberWithInteger:_configuration.maxRetries],
                       [NSNumber numberWithInteger:limit]];

    if ([events count] == 0) {
        callback(YES);
    } else {
        NSMutableArray *activities = [NSMutableArray arrayWithCapacity:events.count];

        [activities enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BSGMetricsEvent *event = (BSGMetricsEvent *)obj;

            [activities addObject:@{
                                    @"createdAt": [_dateFormatter stringFromDate:event.createdAt],
                                    @"version": event.version,
                                    @"info": event.userInfo
                                    }];
        }];

        [_manager POST:_configuration.path
            parameters:@{
                         @"user": [UIDevice currentDevice].identifierForVendor.UUIDString,
                         @"appID": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"],
                         @"activities": activities
                         }
              progress:^(NSProgress * _Nonnull uploadProgress) {
                  NSLog(@"Progress: %qi/%qi", uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
              } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                  [self manageSuccessForEvents:events
                                      response:responseObject
                                    statusCode:httpResponse.statusCode];
                  callback(TRUE);
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
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
        NSLog(@"RetryCount bumped from... %li", event.retryCount);
        event.retryCount += 1;
        NSLog(@"to... %li", event.retryCount);
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
                    NSLog(@"Event not recorded: %@", [eventReport objectForKey:@"message"]);
                    [messagesNOK addObject:[events objectAtIndex:idx]];
                }
            }];
            break;
        }

        default: {
            NSLog(@"Error: unexpected status code %li", statusCode);
        }
    }

    [self updateEvents:messagesOK withStatus:BSGMetricsEventStatusSentWithSuccess];
    [self updateEvents:messagesNOK withErrorStatus:BSGMetricsEventStatusSentWithError];
}


- (void)manageErrorsForEvents:(NSArray *)events statusCode:(BSGMetricsServiceResponseStatusCode)statusCode {
    switch(statusCode) {
        case BSGMetricsServiceResponseStatusCodeMalformed: {
            NSLog(@"Malformed messages");
            break;
        }
        case BSGMetricsServiceResponseStatusCodeSystemError: {
            NSLog(@"System errors");
            break;
        }

        default: {
            NSLog(@"Error: unexpected status code %li", statusCode);
        }
    }
    
    [self updateEvents:events withErrorStatus:BSGMetricsEventStatusSentWithError];
}


@end

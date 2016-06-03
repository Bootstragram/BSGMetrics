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
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[configuration baseURL]];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];

        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];

    }
    return self;
}


- (void)postEventsWithStatus:(BSGMetricsEventStatus)status limit:(NSInteger)limit completion:(void (^)(BOOL success))callback {
    NSArray *events = [BSGMetricsEvent instancesWhere:@"status = ? ORDER BY createdAt LIMIT ?", [NSNumber numberWithInteger:status], [NSNumber numberWithInteger:limit]];

    NSMutableArray *objectsToSend = [NSMutableArray arrayWithCapacity:events.count];
    [events enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BSGMetricsEvent *event = (BSGMetricsEvent *)obj;

        [objectsToSend addObject:@{
                                   @"createdAt": [_dateFormatter stringFromDate:event.createdAt],
                                   @"user": @"43B9E464-EDE1-48E9-9430-66507D3B1534",
                                   @"app": @{
                                           @"version": event.version,
                                           @"bundleID": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
                                           },
                                   @"info": event.userInfo
                                   }];
    }];

    [_manager POST:@"activities"
//     [_manager POST:@""
        parameters:objectsToSend
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


- (void)updateEvents:(NSArray *)eventsArray withStatus:(BSGMetricsEventStatus)status {
    [eventsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BSGMetricsEvent *event = (BSGMetricsEvent *)obj;
        event.status = status;
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
    [self updateEvents:messagesNOK withStatus:BSGMetricsEventStatusSentWithError];
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

    [self updateEvents:events withStatus:BSGMetricsEventStatusSentWithError];
}


@end

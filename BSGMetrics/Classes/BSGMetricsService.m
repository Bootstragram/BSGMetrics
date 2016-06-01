//
//  BSGMetricsService.m
//  Pods
//
//  Created by Mickaël Floc'hlay on 01/06/2016.
//
//

#import "BSGMetricsService.h"
#import "BSGMetricsConfiguration.h"


@implementation BSGMetricsService


- (instancetype)initWithConfig:(BSGMetricsConfiguration *)configuration {
    self = [super init];
    if (self) {
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[configuration baseURL]];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

- (void)postEventsWithStatus:(BSGEventStatus)status limit:(NSInteger)limit {
    NSArray *events = [BSGMetricsEvent instancesWhere:@"status = ? ORDER BY createdAt LIMIT ?", [NSNumber numberWithInteger:status], [NSNumber numberWithInteger:limit]];
    NSMutableArray *objectsToSend = [NSMutableArray arrayWithCapacity:events.count];
    [events enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BSGMetricsEvent *event = (BSGMetricsEvent *)obj;
        [objectsToSend addObject:event.userInfo];
    }];

    [_manager POST:@""
        parameters:objectsToSend
          progress:^(NSProgress * _Nonnull uploadProgress) {
              NSLog(@"Progress: %qi/%qi", uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
          } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              [self updateEvents:events withStatus:BSGEventStatusSentWithSuccess];
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Error: %@", error);
              [self updateEvents:events withStatus:BSGEventStatusSentWithError];
          }];
}


- (void)updateEvents:(NSArray *)eventsArray withStatus:(BSGEventStatus)status {
    [eventsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BSGMetricsEvent *event = (BSGMetricsEvent *)obj;
        event.status = status;
        [event save];
    }];
}

- (NSString *)stringOfIDsOfEvents:(NSArray *)eventsArray {
    NSMutableString *result = [NSMutableString string];
    [eventsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (result.length > 0) {
            [result appendString:@","];
        }

        BSGMetricsEvent *event = (BSGMetricsEvent *)obj;
        [result appendString:[NSString stringWithFormat:@"%@", [NSNumber numberWithInt:event.id]]];
    }];
    return result;
}

@end

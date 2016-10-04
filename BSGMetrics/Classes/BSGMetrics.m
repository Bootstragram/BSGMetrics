//
//  BSGMetrics.m
//  Pods
//
//  Created by Mickaël Floc'hlay on 01/06/2016.
//
//

#import "BSGMetrics.h"
#import "FCModel.h"


@implementation BSGMetrics


# pragma mark - Public methods


+ (BSGMetrics *)openWithConfiguration:(BSGMetricsConfiguration *)configuration {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [documentsPath stringByAppendingPathComponent:@"BSGMetrics.sqlite3"];

    [FCModel openDatabaseAtPath:dbPath withSchemaBuilder:^(FMDatabase *db, int *schemaVersion) {
        [db beginTransaction];

        // My custom failure handling. Yours may vary.
        void (^failedAt)(int statement) = ^(int statement){
            int lastErrorCode = db.lastErrorCode;
            NSString *lastErrorMessage = db.lastErrorMessage;
            [db rollback];
            NSAssert3(0, @"Migration statement %d failed, code %d: %@", statement, lastErrorCode, lastErrorMessage);
        };

        if (*schemaVersion < 1) {
            if (! [db executeUpdate:
                   @"CREATE TABLE BSGMetricsEvent ("
                   @"    id           INTEGER PRIMARY KEY,"
                   @"    status       INTEGER NOT NULL DEFAULT 0,"
                   @"    userInfo     BLOB NOT NULL,"
                   @"    createdAt    REAL NOT NULL,"
                   @"    version      TEXT NOT NULL,"
                   @"    retryCount   INTEGER NOT NULL DEFAULT 0"
                   @");"
                   ]) failedAt(1);

            *schemaVersion = 1;
        }

        // If you wanted to change the schema in a later app version, you'd add something like this here:
        /*
         if (*schemaVersion < 2) {
         if (! [db executeUpdate:@"ALTER TABLE Person ADD COLUMN title TEXT NOT NULL DEFAULT ''"]) failedAt(3);
         *schemaVersion = 2;
         //if (! [db executeUpdate:@"CREATE INDEX IF NOT EXISTS status ON Person (name);"]) failedAt(2);
         }

         // And so on...
         if (*schemaVersion < 3) {
         if (! [db executeUpdate:@"CREATE TABLE..."]) failedAt(4);
         *schemaVersion = 3;
         }

         */

        NSLog(@"[BSGMetrics] DEBUG Committing with version %d", (* schemaVersion));

        [db commit];
    }];

    BSGMetrics *metrics = [[BSGMetrics alloc] init];
    metrics.configuration = configuration;
    metrics.service = [[BSGMetricsService alloc] initWithConfig:metrics.configuration];
    metrics.started = NO;

    return metrics;
}


- (void)startSendingWithCompletion:(void (^)(BOOL success))callback {
    if (_started) {
        NSLog(@"[BSGMetrics] WARN Already started");
        return;
    } else {
        NSLog(@"[BSGMetrics] INFO Start sending");
        _started = YES;
        [self privateStartSendingWithCompletion:callback];
    }
}


- (void)stopSending {
    NSLog(@"[BSGMetrics] INFO Stop sending...");
    _started = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


# pragma mark - Private stuff


- (void)privateStartSendingWithCompletion:(void (^)(BOOL success))callback {
    if (_started) {
        NSLog(@"[BSGMetrics] DEBUG Internal start sending...");
        _sendCompletion = callback;

        [_service postEventsWithLimit:_configuration.frequency completion:^(BOOL success) {
            NSLog(@"[BSGMetrics] DEBUG Pruning...");
            [self pruneMessagesOK];

            if (_started) {
                NSLog(@"[BSGMetrics] DEBUG Rescheduling in %f.", _configuration.frequency);
                [self performSelector:@selector(privateStartSendingWithCompletion:)
                           withObject:callback
                           afterDelay:_configuration.frequency];
            }

            _sendCompletion(success);
        }];
    }
}


- (void)pruneMessagesOK {
    [BSGMetricsEvent executeUpdateQuery:@"DELETE FROM $T WHERE status = ?", [NSNumber numberWithInteger:BSGMetricsEventStatusSentWithSuccess]];
}


- (void)pruneMessagesKO {
    [BSGMetricsEvent executeUpdateQuery:@"DELETE FROM $T WHERE status = ? AND retryCount >= ?", [NSNumber numberWithInteger:BSGMetricsEventStatusSentWithError], [NSNumber numberWithInteger:_configuration.maxRetries]];
}


- (NSUInteger)countMessagesWithTooManyErrors {
    return [BSGMetricsEvent numberOfInstancesWhere:@"status = ? AND retryCount >= ?", [NSNumber numberWithInteger:BSGMetricsEventStatusSentWithError], [NSNumber numberWithInteger:_configuration.maxRetries]];
}


@end

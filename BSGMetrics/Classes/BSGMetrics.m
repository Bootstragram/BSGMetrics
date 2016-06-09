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

        NSLog(@"Committing with version %d", (* schemaVersion));
        
        [db commit];
    }];

    BSGMetrics *metrics = [[BSGMetrics alloc] init];
    metrics.configuration = configuration;

    BSGMetricsService *service = [[BSGMetricsService alloc] initWithConfig:metrics.configuration];
    metrics.service = service;

    return metrics;
}


- (void)startSendingWithCompletion:(void (^)(BOOL success))callback {
    _sendCompletion = callback;

    [_service postEventsWithLimit:_configuration.frequency completion:^(BOOL success) {
        NSLog(@"Rescheduling...");
        [self prune];
        [self performSelector:@selector(startSendingWithCompletion:)
                   withObject:callback
                   afterDelay:_configuration.frequency];
        _sendCompletion(success);
    }];
}


- (void)prune {
    [BSGMetricsEvent executeUpdateQuery:@"DELETE FROM $T WHERE status = ?", [NSNumber numberWithInteger:BSGMetricsEventStatusSentWithSuccess]];
}


- (void)startSending {
    [self startSendingWithCompletion:^(BOOL success) {
        // Do nothing
    }];
}

- (void)stopSending {
    NSLog(@"Cancelled scheduling...");
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startSendingWithCompletion:) object:_sendCompletion];
}

@end

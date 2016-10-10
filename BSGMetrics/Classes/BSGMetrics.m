//
//  BSGMetrics.m
//  Pods
//
//  Created by Mickaël Floc'hlay on 01/06/2016.
//
//

#import "BSGMetrics.h"
#import "BSGMetricsService.h"
#import "FCModel.h"
#import "BSGMetricsSendOperation.h"


@interface BSGMetrics ()

@property(strong, nonatomic) NSTimer *launcherTimer;
@property(strong, nonatomic) NSOperationQueue *networkOperationQueue;
@property(strong, nonatomic) NSOperationQueue *databaseOperationQueue;
@property(strong, nonatomic) BSGMetricsService *service;
@property(strong, nonatomic) BSGMetricsConfiguration *configuration;
@property(copy, nonatomic) void(^sendCompletion) (BOOL);
@property(readonly) NSUInteger maxNumberOfOperationsInQueue;

@end


@interface BSGMetricsEvent (BSGMetrics)

+ (BSGMetricsEvent *)eventWithUserInfo:(NSDictionary *)userInfo;

@end


@implementation BSGMetrics


# pragma mark - Public methods


+ (BSGMetrics *)openWithConfiguration:(BSGMetricsConfiguration *)configuration {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [documentsPath stringByAppendingPathComponent:@"BSGMetrics.sqlite3"];

    [FCModel openDatabaseAtPath:dbPath withSchemaBuilder:^(FMDatabase *db, int *schemaVersion) {
        [db beginTransaction];

        // My custom failure handling. Yours may vary.
        void (^failedAt)(int statement) = ^(int statement){
            NSLog(@"[ERROR] Schema update failed");
            //int lastErrorCode = db.lastErrorCode;
            //NSString *lastErrorMessage = db.lastErrorMessage;
            [db rollback];
            //NSAssert3(0, @"Migration statement %d failed, code %d: %@", statement, lastErrorCode, lastErrorMessage);
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

#ifdef DEBUG
        NSLog(@"[BSGMetrics] DEBUG Committing with version %d", (* schemaVersion));
#endif

        [db commit];
    }];

    return [[BSGMetrics alloc] initWithConfiguration:configuration];
}


- (id)initWithConfiguration:(BSGMetricsConfiguration *)configuration {
    self = [super init];
    if (self) {
        self.configuration = configuration;
        self.service = [[BSGMetricsService alloc] initWithConfig:configuration];

        self.networkOperationQueue = [[NSOperationQueue alloc] init];
        self.networkOperationQueue.maxConcurrentOperationCount = 1;
        self.networkOperationQueue.qualityOfService = NSOperationQualityOfServiceBackground;
        self.networkOperationQueue.suspended = YES;

        self.databaseOperationQueue = [[NSOperationQueue alloc] init];
        self.databaseOperationQueue.qualityOfService = NSOperationQualityOfServiceUtility;

        self.launcherTimer = [NSTimer scheduledTimerWithTimeInterval:configuration.frequency
                                                              target:self
                                                            selector:@selector(addSendOperationIfOperatingSmoothly)
                                                            userInfo:nil
                                                             repeats:YES];
        _maxNumberOfOperationsInQueue = 2;
    }
    return self;
}


- (void)startSendingWithCompletion:(void (^)(BOOL success))callback {
    @synchronized (self) {
        if (self.networkOperationQueue.isSuspended) {
            self.sendCompletion = callback;
            self.networkOperationQueue.suspended = NO;
        } else {
            NSLog(@"[BSGMetrics] WARN Already started");
        }
    }
}


- (void)stopSending {
    @synchronized (self) {
        NSLog(@"[BSGMetrics] INFO Suspending operations...");
        self.networkOperationQueue.suspended = YES;
        [self.networkOperationQueue cancelAllOperations];
        [self.networkOperationQueue waitUntilAllOperationsAreFinished];
        NSLog(@"[BSGMetrics] INFO Operations were suspended...");
    }
}


# pragma mark - Private stuff


- (void)addSendOperationIfOperatingSmoothly {
    if (self.networkOperationQueue.isSuspended) {
        NSLog(@"[BSGMetrics] DEBUG Not adding operation (the queue ie suspended)");
        return;
    }

    if (self.networkOperationQueue.operationCount > self.maxNumberOfOperationsInQueue) {
        NSLog(@"[BSGMetrics] DEBUG Not adding operation (the queue is too busy)");
        return;
    }

    BSGMetricsSendOperation *newOperation = [[BSGMetricsSendOperation alloc] initWithService:self.service
                                                                               andCompletion:self.sendCompletion];
    [self.networkOperationQueue addOperation:newOperation];

    NSBlockOperation* theOp = [NSBlockOperation blockOperationWithBlock: ^{
        [self pruneMessagesOK];
    }];

    [self.networkOperationQueue addOperation:theOp];
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


- (void)eventWithUserInfo:(NSDictionary *)userInfo {
    NSBlockOperation* theOp = [NSBlockOperation blockOperationWithBlock: ^{
        BSGMetricsEvent *newEvent = [BSGMetricsEvent eventWithUserInfo:userInfo];
        FCModelSaveResult saveResult = [newEvent save];

        switch (saveResult) {
            case FCModelSaveFailed: {
                NSLog(@"[BSGMetrics] ERROR FCModelSaveFailed");
                return;
            }
            case FCModelSaveRefused: {
                NSLog(@"[BSGMetrics] ERROR FCModelSaveRefused");
                return;
            }
            case FCModelSaveNoChanges: {
#ifdef DEBUG
                NSLog(@"[BSGMetrics] DEBUG FCModelSaveNoChanges");
#endif
                return;
            }
            case FCModelSaveSucceeded: {
#ifdef DEBUG
                NSLog(@"[BSGMetrics] DEBUG FCModelSaveSucceeded");
#endif
                return;
            }
            default: {
                NSLog(@"[BSGMetrics] WARN Unknown return status");
                return;
            }
        }
    }];

    [self.databaseOperationQueue addOperation:theOp];
}


@end

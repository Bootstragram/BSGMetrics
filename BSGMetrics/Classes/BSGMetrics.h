//
//  BSGMetrics.h
//  Pods
//
//  Created by Mickaël Floc'hlay on 01/06/2016.
//
//

#import <Foundation/Foundation.h>
#import "BSGMetricsConfiguration.h"


/**
 * The main entry point to the library
 */
@interface BSGMetrics : NSObject


/**
 * Opens the events database. Must be called only once in the app lifecycle.
 *
 * @param configuration  the configuration bean
 */
+ (BSGMetrics *)openWithConfiguration:(BSGMetricsConfiguration *)configuration;

/**
 DO NOT USE init
 */
- (id)init NS_UNAVAILABLE;

/**
 * Starts sending events to the server.
 *
 * @param callback  the completion block to call after completion
 */
- (void)startSendingWithCompletion:(void (^)(BOOL success))callback;

/**
 * Stop sending events to the server.
 */
- (void)stopSending;

/**
 * Removes messages that have run out of attempts to be successfully sent to the server
 * from the events database.
 */
- (void)pruneMessagesKO;

/**
 * Adds an event with the given data in the events database
 *
 * @param userInfo  the dictionary of data to attach to the event
 */
- (void)eventWithUserInfo:(NSDictionary *)userInfo;

@end

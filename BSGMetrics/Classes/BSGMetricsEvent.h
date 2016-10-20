//
//  BSGMetricsEvent.h
//  Pods
//
//  Created by Mickaël Floc'hlay on 01/06/2016.
//
//

#import <Foundation/Foundation.h>
#import <FCModel/FCModel.h>



/**
 The status of an event
 */
typedef NS_ENUM(NSInteger, BSGMetricsEventStatus) {
    /**
     created but not sent
     */
    BSGMetricsEventStatusCreated = 1,
    /**
     created and sent successfully
     */
    BSGMetricsEventStatusSentWithSuccess = 2,
    /**
     created and sent unsuccessfully
     */
    BSGMetricsEventStatusSentWithError = 3
};


/**
 * Events sent to the server
 */
@interface BSGMetricsEvent : FCModel


/**
 The creation date of the event.
 */
@property(strong, readonly, nonatomic) NSDate *createdAt;

/**
 The application version for which the event was created.
 */
@property(strong, readonly, nonatomic) NSString *version;

/**
 The dictionary of data provided by the user
 */
@property(strong, readonly, nonatomic) NSDictionary *userInfo;

/**
 UUID for the event
 */
@property(strong, readonly, nonatomic) NSString *uuid;

/**
 The status of the event
 */
@property(nonatomic) BSGMetricsEventStatus status;

/**
 The number of times the message has been sent unsuccessfully.
 */
@property(nonatomic) NSInteger retryCount;

/**
 DO NOT USE init
 */
- (instancetype)init NS_UNAVAILABLE;

@end

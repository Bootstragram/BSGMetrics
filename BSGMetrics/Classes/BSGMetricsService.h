//
//  BSGMetricsService.h
//  Pods
//
//  Created by Mickaël Floc'hlay on 01/06/2016.
//
//

#import <Foundation/Foundation.h>
#import "BSGMetricsEvent.h"
#import "BSGMetricsConfiguration.h"

@import AFNetworking;

/**
 The server response status code
 */
typedef NS_ENUM(NSInteger, BSGMetricsServiceResponseStatusCode) {
    /**
     Everything OK
     */
    BSGMetricsServiceResponseStatusCodeOK = 200,
    /**
     Some messages were OK, some were KO
     */
    BSGMetricsServiceResponseStatusCodePartialOK = 202,
    /**
     The server didn't parse our message successfully
     */
    BSGMetricsServiceResponseStatusCodeMalformed = 400,
    /**
     The server met an unexpected error while processing our message
     */
    BSGMetricsServiceResponseStatusCodeSystemError = 500,
};

/**
 * The service in charge of sending events to the server.
 */
@interface BSGMetricsService : NSObject

/**
 The session manager of the service.
 */
@property(strong, nonatomic) AFHTTPSessionManager *manager;

/**
 The configuration of the service.
 */
@property(strong, nonatomic) BSGMetricsConfiguration *configuration;


/**
 @deprecated
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 Inits a new instance with the given configuration

 @param configuration configuration

 @return a newly created instance
 */
- (instancetype)initWithConfig:(BSGMetricsConfiguration *)configuration;

/**
 Post events.

 @param callback  the completion callback
 */
- (void)postEventsWithCompletion:(void (^)(BOOL success))callback;

@end

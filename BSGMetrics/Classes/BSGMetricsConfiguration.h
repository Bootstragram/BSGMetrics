//
//  BSGMetricsConfiguration.h
//  Pods
//
//  Created by Mickaël Floc'hlay on 01/06/2016.
//
//

#import <Foundation/Foundation.h>

/**
 
 The configuration object for BSGMetrics.

 */
@interface BSGMetricsConfiguration : NSObject


/**
 The base URL for the BSGMetrics server you intend to use or that was assigned to you.
 Example: `https://example.com`
 */
@property(strong, nonatomic) NSString *baseURL;

/**
 The path for the BSGMetrics service you intend to use or that was assigned to you.
 Example: `/` or `/foo`
 */
@property(strong, nonatomic) NSString *path;

/**
 The frequency in seconds at which events are sent to your BSGMetrics server.
 Example: `5` for one request every five seconds.
 */
@property NSTimeInterval frequency;

/**
 The maximum numbers of events that are sent for each request.
 Example: `10` for 1 to 10 events sent for every request
 */
@property NSInteger limit;

/**
 The maximum number of attempts to send an event to the server.
 Example: `5` for trying to send the event 5 times before stop trying.
 */
@property NSInteger maxRetries;

@end

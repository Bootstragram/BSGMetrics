//
//  BSGMetricsConfiguration.h
//  Pods
//
//  Created by Mickaël Floc'hlay on 01/06/2016.
//
//

#import <Foundation/Foundation.h>

@interface BSGMetricsConfiguration : NSObject

@property(strong, nonatomic) NSString *baseURL;
@property(strong, nonatomic) NSString *path;
@property NSTimeInterval frequency;
@property NSInteger limit;
@property NSInteger maxRetries;

@end

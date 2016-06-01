//
//  NSDictionary+BSGJSONUtils.m
//  BSGUtilities
//
//  Created by Mickaël Floc'hlay on 30/10/2014.
//  Copyright (c) 2014 Mickaël Floc'hlay. All rights reserved.
//

#import "NSDictionary+BSGJSONUtils.h"

@implementation NSDictionary (BSGJSONUtils)

- (NSInteger)integerForKey:(NSString *)key {
    id integerObject = [self objectForKey:key];
    if (integerObject == [NSNull null]) {
        return 0;
    } else {
        return [integerObject integerValue];
    }
}

- (BOOL)booleanForKey:(NSString *)key {
    id booleanObject = [self objectForKey:key];
    return [booleanObject boolValue];
}

- (NSDate *)dateForKey:(NSString *)key {
    id stringObject = [self objectForKey:key];
    if (stringObject == [NSNull null]) {
        return nil;
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterMediumStyle;
        formatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSZ";
        formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        NSDate *result = [formatter dateFromString:stringObject];

        if (result == nil) {
            NSLog(@"ERROR converting");
        }

        return result;
    }
}

@end

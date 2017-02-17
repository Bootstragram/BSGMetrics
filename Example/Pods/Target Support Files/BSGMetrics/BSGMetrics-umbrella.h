#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BSGMetrics.h"
#import "BSGMetricsConfiguration.h"
#import "BSGMetricsEvent.h"
#import "BSGMetricsService.h"

FOUNDATION_EXPORT double BSGMetricsVersionNumber;
FOUNDATION_EXPORT const unsigned char BSGMetricsVersionString[];


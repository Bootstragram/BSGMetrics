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

#import "FCModel.h"
#import "FCModelCachedObject.h"
#import "FCModelDatabaseQueue.h"

FOUNDATION_EXPORT double FCModelVersionNumber;
FOUNDATION_EXPORT const unsigned char FCModelVersionString[];


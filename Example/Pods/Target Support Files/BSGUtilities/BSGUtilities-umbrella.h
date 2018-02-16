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

#import "BSGCommonDataSource.h"
#import "BSGEntitiesTableViewController.h"
#import "BSGManagedObjectDetailTableViewController.h"
#import "BSGManagedObjectsTableViewController.h"
#import "BSGFileSystemExplorer.h"
#import "NSDictionary+BSGJSONUtils.h"
#import "BSGArrayDataSource.h"
#import "BSGFetchedResultsControllerDataSource.h"
#import "BSGMultiSectionsArrayDataSource.h"
#import "BSGWebViewController.h"
#import "BSGWebViewDelegate.h"

FOUNDATION_EXPORT double BSGUtilitiesVersionNumber;
FOUNDATION_EXPORT const unsigned char BSGUtilitiesVersionString[];


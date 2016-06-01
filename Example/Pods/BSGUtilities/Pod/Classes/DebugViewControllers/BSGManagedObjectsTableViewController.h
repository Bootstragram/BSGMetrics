//
//  BSGManagedObjectsTableViewController.h
//  Pods
//
//  Created by Mickaël Floc'hlay on 04/02/2015.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BSGEntitiesTableViewController.h"

/**
 *  This table view controller is intended to be fed with a `NSEntityDescription`
 *  so that it displays all the fetched objects of this entity as its rows.
 *
 *  This table view controller is made for debug purpose only.
 */
@interface BSGManagedObjectsTableViewController : UITableViewController

/**
 *  The Core Data context used to fetch data.
 */
@property (strong, nonatomic) NSManagedObjectContext *context;

/**
 *  The entity description used to fetch objects.
 */
@property (strong, nonatomic) NSEntityDescription *entityDescription;

/**
 *  The delegate object that is used to describe objects.
 *  cf. `BSGEntitiesTableViewDelegate` for implementation details.
 */
@property (weak, nonatomic) id<BSGEntitiesTableViewDelegate> delegate;

@end

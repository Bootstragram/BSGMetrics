//
//  BSGManagedObjectDetailTableViewController.h
//  Pods
//
//  Created by Mickaël Floc'hlay on 24/02/2015.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


/**
 *  This table view controller is intended to be fed with a `NSManagedObject`
 *  so that it displays all the CoreData attributes of this entity as its rows.
 *
 *  This table view controller is made for debug purpose only.
 */
@interface BSGManagedObjectDetailTableViewController : UITableViewController

/**
 *  The managed object to describe in the table view.
 */
@property (strong, nonatomic) NSManagedObject *managedObject;

@end

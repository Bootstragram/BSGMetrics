//
//  BSGFetchedResultsControllerDataSource.h
//  Pods
//
//  Created by Mickaël Floc'hlay on 04/02/2015.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BSGCommonDataSource.h"


/**
 A `UITableViewDataSource` implementation using an `NSFetchedResultsController` as a base.
 */
@interface BSGFetchedResultsControllerDataSource : NSObject<UITableViewDataSource>

@property(nonatomic) BOOL reselectsAfterUpdates;


/**
 *  Initializer.
 *
 *  @param fetchedResultsController the `NSFetchedResultsController` instance to use
 *  @param aCellIdentifier          the cell identifier
 *  @param aConfigureCellBlock      the block to configure cells
 *  @param tableView                the table view being sourced
 *
 *  @return a newly created instance
 */
- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                        cellIdentifier:(NSString *)aCellIdentifier
                    configureCellBlock:(BSGTableViewCellConfigureBlock)aConfigureCellBlock
                             tableView:(UITableView *)tableView;

/**
 *  Returns the item at the given indexPath.
 *
 *  @param indexPath indexPath of the object to return (section is ignored, only
 *                   row is used)
 *
 *  @return the item at the given indexPath.
 */
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end

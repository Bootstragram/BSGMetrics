//
//  BSGEntitiesTableViewController.h
//  Pods
//
//  Created by Mickaël Floc'hlay on 30/10/2014.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

/**
 *  The protocol to implement to provide ways to describe managed objects precisely.
 */
@protocol BSGEntitiesTableViewDelegate <NSObject>

/**
 *  This method MUST be implemented. It is used to tell what attribute should be used
 *  by default to sort entities in the views.
 *
 *  @param entityDescription the Entity Description that is being displayed/sorted
 *
 *  @return the main Core Data attribute that should be used for sorting entities in the view.
 */
- (NSString *)mainAttributeKeyForEntityDescription:(NSEntityDescription *)entityDescription;


/**
 *  This method MUST be implemented. It is used to return a string that described the managed
 *  object by default in the views.
 *
 *  @param managedObject the object being displayed
 *
 *  @return a `toString()` or `to_s` like `NSString` for `managedObject`
 */
- (NSString *)stringForManagedObject:(NSManagedObject *)managedObject;

@end


/**
 *  This table view controller is intended to be fed with a `NSManagedObjectModel`
 *  so that it displays the entities described in the model as its rows.
 *
 *  This table view controller is made for debug purpose only.
 */
@interface BSGEntitiesTableViewController : UITableViewController<UITableViewDelegate>

/**
 *  The model for which entities should be listed. 
 */
@property (strong, nonatomic) NSManagedObjectModel *model;

/**
 *  The Core Data context used to fetch data.
 */
@property (strong, nonatomic) NSManagedObjectContext *context;

/**
 *  The delegate object that is used to describe objects.
 *  cf. `BSGEntitiesTableViewDelegate` for implementation details.
 */
@property (weak, nonatomic) id<BSGEntitiesTableViewDelegate> delegate;

@end

//
//  BSGMultiSectionsArrayDataSource.h
//  BSGUtilities
//
//  Created by Mickaël Floc'hlay on 26/05/2016.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BSGCommonDataSource.h"

@interface BSGMultiSectionsArrayDataSource : NSObject<UITableViewDataSource>

/**
 *  Initializer
 *
 *  @param anItems             the array of data
 *  @param aCellIdentifier     the cell identifier
 *  @param aConfigureCellBlock the block to configure cells
 *
 *  @return
 */
- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(BSGTableViewCellConfigureBlock)aConfigureCellBlock;


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

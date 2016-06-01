//
//  BSGFetchedResultsControllerDataSource.m
//  Pods
//
//  Created by Mickaël Floc'hlay on 04/02/2015.
//
//

#import "BSGFetchedResultsControllerDataSource.h"

@interface BSGFetchedResultsControllerDataSource () <NSFetchedResultsControllerDelegate>

@property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic, copy) NSString *cellIdentifier;
@property(nonatomic, copy) BSGTableViewCellConfigureBlock configureCellBlock;
@property(weak, nonatomic) UITableView *tableView;

@property(strong, nonatomic) NSIndexPath *indexPathToSelectWhenUpdatesEnd;

@end


@implementation BSGFetchedResultsControllerDataSource

- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                        cellIdentifier:(NSString *)aCellIdentifier
                    configureCellBlock:(BSGTableViewCellConfigureBlock)aConfigureCellBlock
                             tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        // Selection preservation code.
        self.reselectsAfterUpdates = NO;
        self.indexPathToSelectWhenUpdatesEnd = NO;
        
        self.fetchedResultsController = fetchedResultsController;
        self.cellIdentifier = aCellIdentifier;
        self.configureCellBlock = [aConfigureCellBlock copy];
        self.tableView = tableView;
        
        // Perform the fetch!
        self.fetchedResultsController.delegate = self;
        NSError *error = nil;
        if (![self.fetchedResultsController performFetch:&error]) {
            NSLog(@"An error happened while performing performFetch.");
            if (error) {
                NSLog(@"Error: %@", error);
            }
        }
    }
    return self;
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return self.fetchedResultsController.sections.count;
}


- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    id<NSFetchedResultsSectionInfo> section = self.fetchedResultsController.sections[sectionIndex];
    return section.numberOfObjects;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                            forIndexPath:indexPath];
    id item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.configureCellBlock(cell, item);
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex {
    id<NSFetchedResultsSectionInfo> section = self.fetchedResultsController.sections[sectionIndex];
    return section.name;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.indexPathToSelectWhenUpdatesEnd = nil;
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeUpdate:
            NSLog(@"NSFetchedResultsChangeUpdate is not supported yet");
            break;
        case NSFetchedResultsChangeMove:
            NSLog(@"NSFetchedResultsChangeMove is not supported yet");
            break;
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
            
        case NSFetchedResultsChangeDelete: {
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
            
        case NSFetchedResultsChangeUpdate: {
            if ([indexPath isEqual:tableView.indexPathForSelectedRow]) {
                self.indexPathToSelectWhenUpdatesEnd = newIndexPath;
            }
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            NSManagedObject *item = [self itemAtIndexPath:indexPath];
            self.configureCellBlock(cell, item);
            break;
        }
            
        case NSFetchedResultsChangeMove: {
            if ([indexPath isEqual:tableView.indexPathForSelectedRow]) {
                self.indexPathToSelectWhenUpdatesEnd = newIndexPath;
            }
            
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    
    if (_reselectsAfterUpdates && _indexPathToSelectWhenUpdatesEnd) {
        NSLog(@"Restoring selection");
        [self.tableView beginUpdates];
        [self.tableView selectRowAtIndexPath:_indexPathToSelectWhenUpdatesEnd
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
        [self.tableView endUpdates];
    }
    
    self.indexPathToSelectWhenUpdatesEnd = nil;
}

#pragma mark - Utils

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

@end

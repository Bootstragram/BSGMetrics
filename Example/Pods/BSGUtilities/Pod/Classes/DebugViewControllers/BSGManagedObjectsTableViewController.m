//
//  BSGManagedObjectsTableViewController.m
//  Pods
//
//  Created by Mickaël Floc'hlay on 04/02/2015.
//
//

#import "BSGManagedObjectsTableViewController.h"
#import "BSGFetchedResultsControllerDataSource.h"
#import "BSGManagedObjectDetailTableViewController.h"


@interface BSGManagedObjectsTableViewController ()

@property (strong, nonatomic) BSGFetchedResultsControllerDataSource *dataSource;

@end


@implementation BSGManagedObjectsTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [NSException raise:@"Invalid data source"
                format:@"This class is designed to use an external data source"];
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [NSException raise:@"Invalid data source"
                format:@"This class is designed to use an external data source"];
    return 0;
}


- (void)setEntityDescription:(NSEntityDescription *)entityDescription {
    _entityDescription = entityDescription;

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityDescription.name];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[self.delegate mainAttributeKeyForEntityDescription:entityDescription] ascending:YES];
    fetchRequest.sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSLog(@"Main attribute key is: %@", sortDescriptor.key);
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    
    self.dataSource = [[BSGFetchedResultsControllerDataSource alloc] initWithFetchedResultsController:frc cellIdentifier:@"BSGManagedObjectsViewControllerCell" configureCellBlock:^(id cell, id item) {
        NSManagedObject *object = item;
        UITableViewCell *myCell = cell;
        myCell.textLabel.text = [self.delegate stringForManagedObject:object];
    } tableView:self.tableView];

    self.tableView.dataSource = self.dataSource;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"BSGManagedObjectDetailTableViewController"]) {
        NSManagedObject *managedObject = [self.dataSource itemAtIndexPath:[self.tableView indexPathForCell:sender]];
        BSGManagedObjectDetailTableViewController *vc = segue.destinationViewController;
        vc.managedObject = managedObject;
    }
}


@end

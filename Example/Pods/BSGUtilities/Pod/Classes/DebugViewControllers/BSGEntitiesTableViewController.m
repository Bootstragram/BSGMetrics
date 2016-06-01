//
//  BSGEntitiesTableViewController.m
//  Pods
//
//  Created by Mickaël Floc'hlay on 30/10/2014.
//
//

#import "BSGEntitiesTableViewController.h"
#import "BSGManagedObjectsTableViewController.h"

#import "BSGArrayDataSource.h"
#import <CoreData/CoreData.h>


@interface BSGEntitiesTableViewController ()

@property (nonatomic, strong) BSGArrayDataSource *dataSource;

@end

@implementation BSGEntitiesTableViewController

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


- (NSUInteger)countEntities:(NSEntityDescription *)entityDescription inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityDescription.name];
    request.resultType = NSCountResultType;
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    if (count == NSNotFound) {
        [NSException raise:@"Couldn't count"
                    format:@"An error happened: %@", error];
    }

    return count;
}


- (void)setModel:(NSManagedObjectModel *)model {
    _model = model;
    NSArray *entities = [model entities];

    self.dataSource = [[BSGArrayDataSource alloc] initWithItems:entities
                                                 cellIdentifier:@"BSGEntitiesViewControllerCell"
                                             configureCellBlock:^(id cell, id item) {
                                                 NSEntityDescription *entityDescription = item;
                                                 UITableViewCell *myCell = cell;
                                                 myCell.textLabel.text = entityDescription.name;
                                                 myCell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[self countEntities:entityDescription inContext:self.context]];
    }];
    self.tableView.dataSource = self.dataSource;
    [self.tableView reloadData];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"BSGManagedObjectsTableViewController"]) {
        NSEntityDescription *entityDescription = [self.dataSource itemAtIndexPath:[self.tableView indexPathForCell:sender]];
        BSGManagedObjectsTableViewController *vc = segue.destinationViewController;
        vc.delegate = self.delegate;
        vc.context = self.context;
        vc.entityDescription = entityDescription;
    }
}

@end

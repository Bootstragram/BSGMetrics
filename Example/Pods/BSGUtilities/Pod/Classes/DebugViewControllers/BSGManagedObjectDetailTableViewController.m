//
//  BSGManagedObjectDetailTableViewController.m
//  Pods
//
//  Created by Mickaël Floc'hlay on 24/02/2015.
//
//

#import "BSGManagedObjectDetailTableViewController.h"
#import "BSGArrayDataSource.h"

@interface BSGManagedObjectDetailTableViewController ()

@property (strong, nonatomic) BSGArrayDataSource *dataSource;
@property (strong, nonatomic) NSDictionary *managedObjectAttributesByName;

@end

@implementation BSGManagedObjectDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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


- (void)setManagedObject:(NSManagedObject *)managedObject {
    _managedObject = managedObject;

    self.dataSource = [[BSGArrayDataSource alloc] initWithItems:[[[managedObject entity] attributesByName] allKeys]
                                                 cellIdentifier:@"BSGManagedObjectDetailViewControllerCell"
                                             configureCellBlock:^(id cell, id item) {
                                                 NSString *attributeKey = item;
                                                 UITableViewCell *myCell = cell;
                                                 myCell.textLabel.text = attributeKey;
                                                 myCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [managedObject valueForKey:attributeKey]];
                                             }];
    self.tableView.dataSource = self.dataSource;
}

@end

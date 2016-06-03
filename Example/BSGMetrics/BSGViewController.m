//
//  BSGViewController.m
//  BSGMetrics
//
//  Created by Mickaël Floc’hlay on 06/01/2016.
//  Copyright (c) 2016 Mickaël Floc’hlay. All rights reserved.
//

#import "BSGViewController.h"
#import "BSGArrayDataSource.h"
#import "BSGMetrics.h"
#import "BSGAppDelegate.h"


@interface BSGViewController ()

@property(strong) BSGArrayDataSource *dataSource;
@property(strong) NSDateFormatter *dateFormatter;
@property(weak) BSGAppDelegate *appDelegate;

@end

@implementation BSGViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44.0)];

    UIBarButtonItem *startButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startSending:)];
    UIBarButtonItem *reloadButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
    UIBarButtonItem *trashButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(purge)];
    UIBarButtonItem *retryButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRedo target:self action:@selector(redo)];

    toolbar.items = @[ startButtonItem, retryButtonItem, trashButtonItem, reloadButtonItem ];

    self.tableView.tableHeaderView = toolbar;

    self.appDelegate = [[UIApplication sharedApplication] delegate];

    [self reload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)reload {
    if (!_dateFormatter) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterNoStyle;
        _dateFormatter.timeStyle = NSDateFormatterLongStyle;
    }
    NSArray *allEvents = [BSGMetricsEvent allInstances];
    NSLog(@"Reloading with %d events", [allEvents count]);
    _dataSource = [[BSGArrayDataSource alloc] initWithItems:allEvents
                                             cellIdentifier:@"BSGEventCell" configureCellBlock:^(id cell, id item) {
                                                 UITableViewCell *myCell = (UITableViewCell *)cell;
                                                 BSGMetricsEvent *event = (BSGMetricsEvent *)item;

                                                 myCell.textLabel.text = [_dateFormatter stringFromDate:event.createdAt];
                                                 myCell.detailTextLabel.text = [NSString stringWithFormat:@"%d", event.status];
                                             }];
    self.tableView.dataSource = _dataSource;
    [self.tableView reloadData];
}

- (IBAction)addEvent:(id)sender {
    BOOL result = [BSGMetricsEvent eventWithUserInfo:@{ @"key": @"value" }];
    if (result) {
        NSLog(@"addedEvent OK");
    } else {
        NSLog(@"addedEvent NOK");
    }
    [self reload];
}


- (IBAction)startSending:(id)sender {
    [_appDelegate.metrics startSendingWithCompletion:^(BOOL success) {
        [self reload];
    }];
}

- (void)purge {
    [_appDelegate.metrics prune];
    [self reload];
}

- (void)redo {
    [_appDelegate.metrics redoWithCompletion:^(BOOL success) {
        [self reload];
    }];
}

@end

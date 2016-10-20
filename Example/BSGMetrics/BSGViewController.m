//
//  BSGViewController.m
//  BSGMetrics
//
//  Created by Mickaël Floc’hlay on 06/01/2016.
//  Copyright (c) 2016 Mickaël Floc’hlay. All rights reserved.
//

#import "BSGViewController.h"
#import "BSGArrayDataSource.h"
#import "BSGAppDelegate.h"
@import BSGMetrics;


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
    UIBarButtonItem *stopButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(stopSending:)];
    UIBarButtonItem *trashButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashItems:)];

    toolbar.items = @[ startButtonItem, stopButtonItem, trashButtonItem ];

    self.tableView.tableHeaderView = toolbar;

    self.appDelegate = (BSGAppDelegate *)[[UIApplication sharedApplication] delegate];

    [self reload];
}


- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reload)
                                                 name:@"BSGMetricsRefreshRequired"
                                               object:nil];
}


- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"BSGMetricsRefreshRequired"
                                                  object:nil];
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
    _dataSource = [[BSGArrayDataSource alloc] initWithItems:allEvents
                                             cellIdentifier:@"BSGEventCell" configureCellBlock:^(id cell, id item) {
                                                 UITableViewCell *myCell = (UITableViewCell *)cell;
                                                 BSGMetricsEvent *event = (BSGMetricsEvent *)item;

                                                 myCell.textLabel.text = [_dateFormatter stringFromDate:event.createdAt];
                                                 myCell.detailTextLabel.text = [NSString stringWithFormat:@"Status: %ld - Retry: %ld", (long)event.status, (long)event.retryCount];
                                             }];
    self.tableView.dataSource = _dataSource;
    [self.tableView reloadData];
}

- (IBAction)addEvent:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BSGMetricsNotification"
                                                        object:self
                                                      userInfo:@{ @"event": @"userGeneratedEvent" }];
    [self reload];
}


- (IBAction)startSending:(id)sender {
    [_appDelegate.metrics startSendingWithCompletion:^(BOOL success) {
        NSLog(@"[Delegate] Sent metrics? %@", success ? @"YES" : @"NO");
        [self reload];
    }];
}

- (IBAction)stopSending:(id)sender {
    [_appDelegate.metrics stopSending];
}

- (IBAction)trashItems:(id)sender {
    [_appDelegate.metrics pruneMessagesKO];
    [self reload];
}

@end

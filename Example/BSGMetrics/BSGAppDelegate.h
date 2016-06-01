//
//  BSGAppDelegate.h
//  BSGMetrics
//
//  Created by Mickaël Floc’hlay on 06/01/2016.
//  Copyright (c) 2016 Mickaël Floc’hlay. All rights reserved.
//

@import UIKit;
#import "BSGMetrics.h"

@interface BSGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BSGMetrics *metrics;

- (void)startSendingMetrics;

@end

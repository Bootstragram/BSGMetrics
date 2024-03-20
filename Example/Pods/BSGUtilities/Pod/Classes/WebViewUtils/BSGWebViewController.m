//
//  BSGWebViewController.m
//  BSGUtilities
//
//  Created by Mickaël Floc'hlay on 15/10/2014.
//  Copyright (c) 2014 Bootstragram. All rights reserved.
//

#import "BSGWebViewController.h"
#import "BSGWebViewDelegate.h"

@interface BSGWebViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) BSGWebViewDelegate *webViewDelegate;

@end

@implementation BSGWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Configure the delegate
    self.webViewDelegate = [[BSGWebViewDelegate alloc] init];
    self.webViewDelegate.spinner = self.spinner;
    self.webViewDelegate.errorAlertDelegate = self;
    self.webView.delegate = self.webViewDelegate;

    // Configure the close Button
    if (self.closeButton) {
        [self.closeButton setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshContent];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)refreshContent {
    // Load the content of the view
    if (self.rawText) {
        NSError *error = nil;
        NSURL *bundleBaseURL = [[NSBundle mainBundle] resourceURL];
        
        NSString *htmlTemplate = @"<!doctype html>\n"
            "<html class=\"no-js\" lang=\"\">\n"
            "<head>\n"
            "  <meta charset=\"utf-8\">\n"
            "  <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\n"
            "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n"
            "</head>\n"
            "<body><pre>\n"
            "  %@\n" // This is a placeholder for dynamic content
            "</pre></body>\n"
            "</html>";

        [self.webView loadHTMLString:[NSString stringWithFormat:htmlTemplate, self.rawText]
                                baseURL:bundleBaseURL];
        if (error) {
            NSLog(@"MMMarkdown Error: %@", error);
        }
    } else if (self.urlString) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
    } else {
        NSLog(@"ERROR: at least urlString or rawText must be set");
    }
}

- (void)setRawText:(NSString *)rawText {
    _rawText = rawText;
    _urlString = nil;
    [self refreshContent];
}

- (void)setUrlString:(NSString *)urlString {
    _rawText = nil;
    _urlString = urlString;
    [self refreshContent];
}

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)dismiss:(id)sender {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:^{ /* ... do nothing... */ }];
    } else if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"loading"]) {
        NSLog(@"Dictionary: %@", change);
        NSLog(@"Main thread? %@ %@", [NSThread isMainThread] ? @"yes" : @"no", self.webView.loading ? @"yes" : @"no");
        if (self.webView.loading) {
            [self.spinner startAnimating];
        } else {
            [self.spinner stopAnimating];
        }
    }
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self dismiss:self];
}

@end

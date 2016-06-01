//
//  BSGWebViewController.h
//  BSGUtilities
//
//  Created by Mickaël Floc'hlay on 15/10/2014.
//  Copyright (c) 2014 Bootstragram. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 
 Embeddable web browser.
 
 Two options to load content:
 
 1. Set the `raMarkdownContent` property with raw Markdown like `@"## Toto *Italic*`
 2. Set the `urlString` property with a URL string like `http://www.google.fr`

 TODO: eventually, this class should be moved in a private POD.
 TODO: what would be cool also would be to have a protocol delegate to load the content.
 */
@interface BSGWebViewController : UIViewController<UIWebViewDelegate>

/**
 *  Raw Markdown content. 
 *
 *  If this property is set, then `urlString` will be ignored.
 */
@property (copy, nonatomic) NSString *rawMarkdownContent;

/**
 *  A URL string to load in the web view.
 *
 *  This property will be ignored unless `rawMarkdownContent` is `nil`.
 */
@property (copy, nonatomic) NSString *urlString;

/**
 *  The web view where the content should be displayed.
 */
@property (weak, nonatomic) IBOutlet UIWebView *webView;

/**
 *  A close button with the following behavior: 
 *
 *  - It calls `dismiss:` when actioned.
 *  - Its label is set to `NSLocalizedString(@"Close", nil)`
 */
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

/**
 *  *Buggy behavior*, should not be used. `UIWebView` doesn't seem KVO-compliant.
 *  You should use `BSGWebViewDelegate`'s spinner instead.
 */
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

/**
 *  Calls `dismissViewControllerAnimated` on the receiver.
 *
 *  @param sender the responsible sender.
 */
- (IBAction)dismiss:(id)sender;

/**
 *  Force reloading contents. 
 *
 *  This method should only be called by subclasses.
 */
- (void)refreshContent;

@end

//
//  SUMDetailViewController.m
//  SUM1
//
//  Created by Abdullah Farah on 12/2/12.
//  Copyright (c) 2012 Satnford, CA. All rights reserved.
//

#import "SUMDetailViewController.h"
#import "SKPSMTPMessage.h"
#import "SUMAppDelegate.h"
#import "SUMCommon.h"

#define URL_SUFFIX @"http://supost.com/uploads/post/"

@interface SUMDetailViewController ()
- (void)configureView;
@end

@implementation SUMDetailViewController

- (void)dealloc
{
    [_detailItem release];
    [_currentPostsArray release];
    [name release];
    [interval release];
    [timePosted release];
    [imageView1 release];
    [imageView2 release];
    [imageView3 release];
    [imageView4 release];
    [spinner1 release];
    [spinner2 release];
    [spinner3 release];
    [spinner4 release];
    [details release];
    [breadcrumb release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    UIButton *button;
    UIBarButtonItem *buttonItem;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 24, 34);
    [button setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(nextPost:) forControlEvents:UIControlEventTouchUpInside];
    buttonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    [buttons addObject:buttonItem];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(24, 0, 24, 34);
    [button setImage:[UIImage imageNamed:@"previous.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(previousPost:) forControlEvents:UIControlEventTouchUpInside];
    buttonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    [buttons addObject:buttonItem];
    
    self.navigationItem.rightBarButtonItems = buttons;
    [self setButtonPermission];
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Stanford, CA", @"Detail");
    }
    return self;
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];

        // Update the view.
        [self configureView];
    }
}

- (void)gotoView:(id)sender
{
    UIButton *button = (UIButton*)sender;
    //    UIBarButtonItem *button = (UIBarButtonItem*)sender;
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    [self.navigationController popToViewController:[viewControllers objectAtIndex:button.tag] animated:YES];
}

- (UILabel *)getLabelWith:(NSString *)text font:(UIFont*)font lines:(int)lineNumber frame:(CGRect)frame
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.numberOfLines = lineNumber;
    if (lineNumber > 1)
        label.lineBreakMode = NSLineBreakByWordWrapping;
    label.backgroundColor = [UIColor clearColor];
    label.text = text;
    label.font = font;
    CGSize size = [label.text sizeWithFont:label.font constrainedToSize:label.frame.size lineBreakMode:label.lineBreakMode];
    label.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
    
    return label;
}

- (UIImageView *)getImageView:(NSString*)imageName withFrame:(CGRect)frame
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = [UIImage imageNamed:@"placeholder.png"];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.color = [UIColor blackColor];
    spinner.center = CGPointMake(CGRectGetMidX(imageView.bounds), CGRectGetMidY(imageView.bounds));
    [imageView addSubview:spinner];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        [spinner startAnimating];
        NSData * data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[URL_SUFFIX stringByAppendingString:imageName]]];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            // WARNING: is the cell still using the same data by this point??
            imageView.image = [UIImage imageWithData: data];
            [spinner stopAnimating];
            [spinner removeFromSuperview];
        });
    });
    
    return imageView;
}

- (void)configureView1
{
    [[scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    int contentHeight = 0;
    int defaultX = 20;
    int defaultY = 3;
    int defaultWidth = 280;
    int defaultHeight = 21;
    
    UILabel *label = [self getLabelWith:[self.detailItem objectForKey:@"name"] font:[UIFont boldSystemFontOfSize:14] lines:2 frame:CGRectMake(defaultX, defaultY, defaultWidth, defaultHeight*2)];
    [scrollView addSubview:label];
    contentHeight = defaultY + label.frame.size.height;
    
    defaultY = contentHeight + 3;
    defaultWidth = 180;
    NSNumber *timeNumber = [self.detailItem objectForKey:@"time_posted"];
    label = [self getLabelWith:[SUMCommon getDurationFromNow:timeNumber] font:[UIFont systemFontOfSize:10] lines:1 frame:CGRectMake(defaultX, defaultY, defaultWidth, defaultHeight)];
    [scrollView addSubview:label];
    contentHeight = defaultY + label.frame.size.height;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(defaultX+defaultWidth+5, defaultY, scrollView.frame.size.width-(defaultX+defaultWidth+5+20), 50);
    button.backgroundColor = [UIColor greenColor];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [button setTitle:@"Reply" forState:UIControlStateNormal];
//    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 10;
    button.clipsToBounds = YES;
    [button addTarget:self action:@selector(replyTapped:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:button];
    
    defaultY = contentHeight + 3;
    NSString *str = [NSString stringWithFormat:@"%@ (%@)", [SUMCommon getSubcategoryString:[self.detailItem objectForKey:@"subcategory_id"]], [SUMCommon getCategoryString:[self.detailItem objectForKey:@"category_id"]]];
    label = [self getLabelWith:str font:[UIFont systemFontOfSize:10] lines:2 frame:CGRectMake(defaultX, defaultY, defaultWidth, defaultHeight*2)];
    [scrollView addSubview:label];
    contentHeight = defaultY + label.frame.size.height;
    
    defaultY = contentHeight + 3;
    str = @"Location: Stanford, CA";
    label = [self getLabelWith:str font:[UIFont systemFontOfSize:10] lines:2 frame:CGRectMake(defaultX, defaultY, defaultWidth, defaultHeight*2)];
    [scrollView addSubview:label];
    contentHeight = defaultY + label.frame.size.height;
    
    defaultY = contentHeight + 3;
    str = @"Networks: Stanford University";
    label = [self getLabelWith:str font:[UIFont systemFontOfSize:10] lines:2 frame:CGRectMake(defaultX, defaultY, defaultWidth, defaultHeight*2)];
    [scrollView addSubview:label];
    contentHeight = defaultY + label.frame.size.height;
    
    defaultY = contentHeight + 3;
    str = [NSString stringWithFormat:@"Date: %@", [SUMCommon getTimeString:timeNumber]];
    label = [self getLabelWith:str font:[UIFont systemFontOfSize:10] lines:2 frame:CGRectMake(defaultX, defaultY, defaultWidth, defaultHeight*2)];
    [scrollView addSubview:label];
    contentHeight = defaultY + label.frame.size.height;
    
    defaultWidth = 280;
    defaultHeight = 220;
    NSString *imageName = [self.detailItem objectForKey:@"image_source1"];
    if ([imageName length] > 0 && ![imageName isEqualToString:@"NULL"])
    {
        defaultY = contentHeight + 3;
        [scrollView addSubview:[self getImageView:imageName withFrame:CGRectMake(defaultX, defaultY, defaultWidth, defaultHeight)]];
        contentHeight = defaultY + defaultHeight;
    }
    
    imageName = [self.detailItem objectForKey:@"image_source2"];
    if ([imageName length] > 0 && ![imageName isEqualToString:@"NULL"])
    {
        defaultY = contentHeight + 3;
        [scrollView addSubview:[self getImageView:imageName withFrame:CGRectMake(defaultX, defaultY, defaultWidth, defaultHeight)]];
        contentHeight = defaultY + defaultHeight;
    }
    
    imageName = [self.detailItem objectForKey:@"image_source3"];
    if ([imageName length] > 0 && ![imageName isEqualToString:@"NULL"])
    {
        defaultY = contentHeight + 3;
        [scrollView addSubview:[self getImageView:imageName withFrame:CGRectMake(defaultX, defaultY, defaultWidth, defaultHeight)]];
        contentHeight = defaultY + defaultHeight;
    }
    
    imageName = [self.detailItem objectForKey:@"image_source4"];
    if ([imageName length] > 0 && ![imageName isEqualToString:@"NULL"])
    {
        defaultY = contentHeight + 3;
        [scrollView addSubview:[self getImageView:imageName withFrame:CGRectMake(defaultX, defaultY, defaultWidth, defaultHeight)]];
        contentHeight = defaultY + defaultHeight;
    }
    
    defaultX = 10;
    defaultWidth = 300;
    defaultY = contentHeight + 10;
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(defaultX, defaultY, defaultWidth, defaultHeight)];
    textView.text = [self.detailItem objectForKey:@"body"];
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont systemFontOfSize:12];
    [scrollView addSubview:textView];
    CGRect frame = textView.frame;
    frame.size.height = textView.contentSize.height;
    textView.frame = frame;
    contentHeight = defaultY + textView.frame.size.height;
    
    defaultY = contentHeight + 10;
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(124, defaultY, 73, 44);
    [button setTitle:@"Report" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(report:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:button];
    contentHeight = defaultY + button.frame.size.height;
    
    scrollView.contentSize = CGSizeMake(320, contentHeight+10);
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.title = NSLocalizedString([self.detailItem objectForKey:@"name"], @"Details");
        [breadcrumb setItems:[SUMCommon getBreadcrumbItemsFor:self]];
        [self configureView1];
    }
}

- (SKPSMTPMessage*)configureSMTPMessage
{
    SKPSMTPMessage *message = [[SKPSMTPMessage alloc] init];
    message.relayHost = @"smtp.sendgrid.net";
    message.requiresAuth = YES;
    message.login = @"wientjes";
    message.pass = @"asf4565a";
    message.wantsSecure = YES;
    
    return message;
}

- (void)sendEmail:(UIAlertView *)alertView
{
    NSString *userMessage = [alertView textFieldAtIndex:0].text;
    NSString *fromEmail = [alertView textFieldAtIndex:1].text;
    NSString *postTitle = [self.detailItem objectForKey:@"name"];
    NSNumber *timeNumber = [self.detailItem objectForKey:@"time_posted"];
    NSNumber *postId = [self.detailItem objectForKey:@"post_id"];
    NSNumber *securityId = [self.detailItem objectForKey:@"security_id"];
    
    SKPSMTPMessage *message = [self configureSMTPMessage];
    
    message.fromEmail = @"noreply@supost.com";
    message.toEmail = [self.detailItem objectForKey:@"email"]; /*@"abdullah.shawon@gmail.com";*/
    message.bccEmail = @"supost.com@gmail.com";
    message.replyTo = fromEmail;
    message.subject = [NSString stringWithFormat:@"SUpost - %@ response: %@", fromEmail, postTitle];
    
    message.delegate = self;
    
    NSString *messageBody = [NSString stringWithFormat:@"%@ \n\n", userMessage];
    messageBody = [messageBody stringByAppendingFormat:@"From: %@ \n\n", fromEmail];
    messageBody = [messageBody stringByAppendingFormat:@"%@ - Posted: %@ \n", postTitle, [SUMCommon getTimeString:timeNumber]];
    messageBody = [messageBody stringByAppendingString:@"----------------------------------------------------------------------------------------------------\n"];
    messageBody = [messageBody stringByAppendingString:@"To delete your post, use this link and click 'Delete your post.'\n"];
    messageBody = [messageBody stringByAppendingFormat:@"http://www.supost.com/add/publish/%@?security_id=%@ \n", postId, securityId];
    messageBody = [messageBody stringByAppendingString:@"----------------------------------------------------------------------------------------------------\n"];
    messageBody = [messageBody stringByAppendingString:@"Safety: Never wire transfer money and be careful of fake checks.\nProtect yourself from scams and fraud: http://supost.com/safety.html\nCaution: This message may not be from this email address. This person's identity is not verified.\nIf you received this message in error, please email contact@supost.com"];
        
    NSMutableArray *parts_to_send = [NSMutableArray array];
    
    NSDictionary *plain_text_part = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"text/plain", kSKPSMTPPartContentTypeKey,
                                     [messageBody stringByAppendingString:@"\n"], kSKPSMTPPartMessageKey,
                                     @"8bit", kSKPSMTPPartContentTransferEncodingKey,
                                     nil];
    [parts_to_send addObject:plain_text_part];
    
    message.parts = parts_to_send;
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    
    hud.delegate = self;
    hud.labelText = @"Sending..";
    [hud show:YES];
    
    [message send];
}

- (void)sendReport:(NSString*)reason
{
    NSString *postTitle = [self.detailItem objectForKey:@"name"];
    NSNumber *timeNumber = [self.detailItem objectForKey:@"time_posted"];
    NSNumber *postId = [self.detailItem objectForKey:@"post_id"];
    NSNumber *securityId = [self.detailItem objectForKey:@"security_id"];
    
    SKPSMTPMessage *message = [self configureSMTPMessage];
    
    message.toEmail = @"supost.com@gmail.com"; /*@"abdullah.shawon@gmail.com";*/
    message.fromEmail = @"noreply@supost.com";
    message.subject = [NSString stringWithFormat:@"SUpost - Report: %@", postTitle];
    message.delegate = self;
    
    NSString *messageBody = [NSString stringWithFormat:@"%@ \n\n", reason];
    messageBody = [messageBody stringByAppendingFormat:@"%@ - Posted: %@ \n", postTitle, [SUMCommon getTimeString:timeNumber]];
    messageBody = [messageBody stringByAppendingString:@"----------------------------------------------------------------------------------------------------\n"];
    messageBody = [messageBody stringByAppendingString:@"To delete this post, use following link and click 'Delete your post.'\n"];
    messageBody = [messageBody stringByAppendingFormat:@"http://www.supost.com/add/publish/%@?security_id=%@ \n", postId, securityId];
    
    NSMutableArray *parts_to_send = [NSMutableArray array];
    
    NSDictionary *plain_text_part = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"text/plain", kSKPSMTPPartContentTypeKey,
                                     [messageBody stringByAppendingString:@"\n"], kSKPSMTPPartMessageKey,
                                     @"8bit", kSKPSMTPPartContentTransferEncodingKey,
                                     nil];
    [parts_to_send addObject:plain_text_part];
    
    message.parts = parts_to_send;
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    
    hud.delegate = self;
    hud.labelText = @"Sending..";
    [hud show:YES];
    
    [message send];
}

- (IBAction)replyTapped:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reply to this Post" message:@" " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
    alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    alertView.tag = 99;
    
    [[alertView textFieldAtIndex:1] setSecureTextEntry:NO];
    [[alertView textFieldAtIndex:0] setPlaceholder:@"Your Message"];
    [[alertView textFieldAtIndex:1] setPlaceholder:@"Your Email"];
    
    [alertView show];
}

- (IBAction)report:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Report this Post" message:@" " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = 98;
    [[alertView textFieldAtIndex:0] setPlaceholder:@"Reason"];
    
    [alertView show];
    [alertView release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self sendEmail:alertView];
        }
    } else if (alertView.tag == 98) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            NSString *reason = [alertView textFieldAtIndex:0].text;
            [self sendReport:reason];
        }
    }
}

- (void)messageSent:(SKPSMTPMessage *)SMTPmessage
{
    [SMTPmessage release];
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Sent!"
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

- (void)messageFailed:(SKPSMTPMessage *)SMTPmessage error:(NSError *)error
{
    [SMTPmessage release];
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription]
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

- (IBAction)nextPost:(id)sender
{
    self.currentIndex++;
    [UIView beginAnimations:@"transition" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:NO];
    self.detailItem = [self.currentPostsArray objectAtIndex:self.currentIndex];
    [self configureView];
    [UIView commitAnimations];
    
    [self setButtonPermission];
}

- (IBAction)previousPost:(id)sender
{
    self.currentIndex--;
    [UIView beginAnimations:@"transition" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:NO];
    self.detailItem = [self.currentPostsArray objectAtIndex:self.currentIndex];
    [self configureView];
    [UIView commitAnimations];
    
    [self setButtonPermission];
}

- (void) setButtonPermission
{
    NSArray *buttons = self.navigationItem.rightBarButtonItems;
    if (self.currentIndex <= 0) {
        [(UIBarButtonItem*)[buttons objectAtIndex:0] setEnabled:YES];
        [(UIBarButtonItem*)[buttons objectAtIndex:1] setEnabled:NO];
    } else if (self.currentIndex >= [self.currentPostsArray count]) {
        [(UIBarButtonItem*)[buttons objectAtIndex:0] setEnabled:NO];
        [(UIBarButtonItem*)[buttons objectAtIndex:1] setEnabled:YES];
    } else {
        [(UIBarButtonItem*)[buttons objectAtIndex:0] setEnabled:YES];
        [(UIBarButtonItem*)[buttons objectAtIndex:1] setEnabled:YES];
    }
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[hud removeFromSuperview];
	[hud release];
}

							
@end

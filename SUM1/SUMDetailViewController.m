//
//  SUMDetailViewController.m
//  SUM1
//
//  Created by Abdullah Farah on 12/2/12.
//  Copyright (c) 2012 Satnford, CA. All rights reserved.
//

#import "SUMDetailViewController.h"
#import "SKPSMTPMessage.h"

@interface SUMDetailViewController ()
- (void)configureView;
@end

@implementation SUMDetailViewController

- (void)dealloc
{
    [_detailItem release];
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
    [super dealloc];
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

- (NSString *)getLastUpdateTimeInterval:(NSNumber *)time
{
    NSDate *convertedDate = [NSDate dateWithTimeIntervalSince1970:[time doubleValue]];
    NSLog(@"%@", convertedDate);
    
    double timeInterval = [convertedDate timeIntervalSinceDate:[NSDate date]];
    
    timeInterval = timeInterval * -1;
    
    if (timeInterval < 1) {
        return @"";
    } else if (timeInterval < 60) {
        return @"Less than a minute ago";
    } else if (timeInterval < 3600) {
        int diff = round(timeInterval / 60);
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (timeInterval < 86400) {
    	int diff = round(timeInterval / 60 / 60);
    	return[NSString stringWithFormat:@"%d hours ago", diff];
    } else if (timeInterval < 2629743) {
    	int diff = round(timeInterval / 60 / 60 / 24);
    	return[NSString stringWithFormat:@"%d days ago", diff];
    } else {
    	return @"More than a month ago";
    }
    
}

- (NSString *)getTimeString:(NSNumber *)timeNumber
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeNumber doubleValue]];
    NSDateFormatter *dtf = [[NSDateFormatter alloc] init];
    [dtf setDateFormat:@"hh:mmaa EEEE, MMMM dd, yyyy"];
    
    return [dtf stringFromDate:date];
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        name.text = [self.detailItem objectForKey:@"name"];
        
        NSNumber *timeNumber = [self.detailItem objectForKey:@"time_posted"];
        interval.text = [self getLastUpdateTimeInterval:timeNumber];
        
        timePosted.text = [self getTimeString:timeNumber];
        
        NSString *urlSuffix = @"http://supost.com/uploads/post/";
        
        NSString *imageName = [self.detailItem objectForKey:@"image_source1"];
        if ([imageName length] > 0 && ![imageName isEqualToString:@"NULL"])
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                [spinner1 startAnimating];
                NSData * data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[urlSuffix stringByAppendingString:imageName]]];
                if ( data == nil )
                    return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    // WARNING: is the cell still using the same data by this point??
                    imageView1.image = [UIImage imageWithData: data];
                    [spinner1 stopAnimating];
                    [spinner1 removeFromSuperview];
                });
            });
        else
            [spinner1 removeFromSuperview];
        
        imageName = [self.detailItem objectForKey:@"image_source2"];
        if ([imageName length] > 0 && ![imageName isEqualToString:@"NULL"])
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                [spinner2 startAnimating];
                NSData * data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[urlSuffix stringByAppendingString:imageName]]];
                if ( data == nil )
                    return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    // WARNING: is the cell still using the same data by this point??
                    imageView2.image = [UIImage imageWithData: data];
                    [spinner2 stopAnimating];
                    [spinner2 removeFromSuperview];
                });
            });
        else
            [spinner2 removeFromSuperview];
        
        imageName = [self.detailItem objectForKey:@"image_source3"];
        if ([imageName length] > 0 && ![imageName isEqualToString:@"NULL"])
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                [spinner3 startAnimating];
                NSData * data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[urlSuffix stringByAppendingString:imageName]]];
                if ( data == nil )
                    return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    // WARNING: is the cell still using the same data by this point??
                    imageView3.image = [UIImage imageWithData: data];
                    [spinner3 stopAnimating];
                    [spinner3 removeFromSuperview];
                });
            });
        else
            [spinner3 removeFromSuperview];
        
        imageName = [self.detailItem objectForKey:@"image_source4"];
        if ([imageName length] > 0 && ![imageName isEqualToString:@"NULL"])
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                [spinner4 startAnimating];
                NSData * data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[urlSuffix stringByAppendingString:imageName]]];
                if ( data == nil )
                    return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    // WARNING: is the cell still using the same data by this point??
                    imageView4.image = [UIImage imageWithData: data];
                    [spinner4 stopAnimating];
                    [spinner4 removeFromSuperview];
                });
            });
        else
            [spinner4 removeFromSuperview];
        
        details.text = [self.detailItem objectForKey:@"body"];
    }
    
    scrollView.contentSize = CGSizeMake(320, 548);
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
    message.toEmail = /*[self.detailItem objectForKey:@"email"];*/ @"abdullah.shawon@gmail.com";
    message.subject = [NSString stringWithFormat:@"SUpost - %@ response: %@", fromEmail, postTitle];
    
    message.delegate = self;
    
    NSString *messageBody = [NSString stringWithFormat:@"%@ \n\n", userMessage];
    messageBody = [messageBody stringByAppendingFormat:@"From: %@ \n\n", fromEmail];
    messageBody = [messageBody stringByAppendingFormat:@"%@ - Posted: %@ \n", postTitle, [self getTimeString:timeNumber]];
    messageBody = [messageBody stringByAppendingString:@"----------------------------------------------------------------------------------------------------\n"];
    messageBody = [messageBody stringByAppendingString:@"To delete your post, use this link and click 'Delete your post.'\n"];
    messageBody = [messageBody stringByAppendingFormat:@"http://www.supost.com/add/publish/%@?security_id=%@ \n", postId, securityId];
    messageBody = [messageBody stringByAppendingString:@"----------------------------------------------------------------------------------------------------\n"];
    messageBody = [messageBody stringByAppendingString:@"Safety: Never wire transfer money and be careful of fake checks.\nProtect yourself from scams and fraud: http://supost.com/safety.html\nCaution: This message may not be from this email address. This person's identity is not verified.\nIf you received this message in error, please email contact@supost.com"];
    
    NSLog(@"%@", [self.detailItem objectForKey:@"email"]);
    
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
    
    message.toEmail = /*@"supost.com@gmail.com";*/ @"abdullah.shawon@gmail.com";
    message.fromEmail = @"noreply@supost.com";
    message.subject = [NSString stringWithFormat:@"SUpost - Report: %@", postTitle];
    message.delegate = self;
    
    NSString *messageBody = [NSString stringWithFormat:@"%@ \n\n", reason];
    messageBody = [messageBody stringByAppendingFormat:@"%@ - Posted: %@ \n", postTitle, [self getTimeString:timeNumber]];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reply" style:UIBarButtonSystemItemAction target:self action:@selector(replyTapped:)];
    
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

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[hud removeFromSuperview];
	[hud release];
}

							
@end

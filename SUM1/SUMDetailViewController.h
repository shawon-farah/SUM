//
//  SUMDetailViewController.h
//  SUM1
//
//  Created by Abdullah Farah on 12/2/12.
//  Copyright (c) 2012 Satnford, CA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SKPSMTPMessage.h"
#import "MBProgressHUD.h"

#define FROM_EMAIL_PREF_KEY @"kFromEmailPreferenceKey"
#define TO_EMAIL_PREF_KEY @"kToEmailPreferenceKey"
#define RELAY_HOST_PREF_KEY @"kRelayHostPreferenceKey"
#define USE_SSL_BOOL_PREF_KEY @"kUseSSLBoolPreferenceKey"
#define USE_AUTH_BOOL_PREF_KEY @"kUseAuthBoolPreferenceKey"
#define AUTH_USERNAME_PREF_KEY @"kAuthUsernamePreferenceKey"
#define AUTH_PASSWORD_PREF_KEY @"kAuthPasswordPreferenceKey"
#define MESSAGE_SUBJECT_PREF_KEY @"kMessageSubjectPreferenceKey"
#define MESSAGE_BODY_PREF_KEY @"kMessageBodyPreferenceKey"
#define MESSAGE_SIG_PREF_KEY @"kMessageSigPreferenceKey"
#define SEND_IMAGE_BOOL_PREF_KEY @"kSendImageBoolPreferenceKey"
#define SEND_VCARD_BOOL_PREF_KEY @"kSendVcardBoolPreferenceKey"

@interface SUMDetailViewController : UIViewController <UIAlertViewDelegate, SKPSMTPMessageDelegate, MBProgressHUDDelegate>
{
    IBOutlet UILabel *name;
    IBOutlet UILabel *interval;
    IBOutlet UILabel *timePosted;
    IBOutlet UITextView *attributes;
    IBOutlet UIImageView *imageView1;
    IBOutlet UIImageView *imageView2;
    IBOutlet UIImageView *imageView3;
    IBOutlet UIImageView *imageView4;
    IBOutlet UIActivityIndicatorView *spinner1;
    IBOutlet UIActivityIndicatorView *spinner2;
    IBOutlet UIActivityIndicatorView *spinner3;
    IBOutlet UIActivityIndicatorView *spinner4; 
//    IBOutlet UIActivityIndicatorView *Spinner;
    IBOutlet UITextView *details;
    
    IBOutlet UIScrollView *scrollView;
}

@property (strong, nonatomic) PFObject *detailItem;
@property (assign, nonatomic) int currentIndex;
@property (strong, nonatomic) NSMutableArray *currentPostsArray;

@end

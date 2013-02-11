//
//  SUMMasterViewController.h
//  SUM1
//
//  Created by Abdullah Farah on 12/2/12.
//  Copyright (c) 2012 Satnford, CA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "PullToRefreshView.h"
#import "SUMAppDelegate.h"

@class SUMDetailViewController;

@interface SUMMasterViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate, PullToRefreshViewDelegate>
{
    UITableViewCell *nibLoadedTableCell;
    
    SUMAppDelegate *appDelegate;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIToolbar *breadcrumb;

@property (nonatomic, retain) IBOutlet UITableViewCell *nibLoadedTableCell;

@property (strong, nonatomic) NSMutableArray *postsList;

@property (strong, nonatomic) NSMutableDictionary *filterDictionary;

@property (strong, nonatomic) SUMDetailViewController *detailViewController;
@property (nonatomic, assign) BOOL isUpdating;

- (void)foregroundRefresh:(NSNotification *)notification;

@end

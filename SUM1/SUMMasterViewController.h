//
//  SUMMasterViewController.h
//  SUM1
//
//  Created by Abdullah Farah on 12/2/12.
//  Copyright (c) 2012 Satnford, CA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class SUMDetailViewController;

@interface SUMMasterViewController : UITableViewController<MBProgressHUDDelegate>
{
    UITableViewCell *nibLoadedTableCell;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *nibLoadedTableCell;

@property (strong, nonatomic) NSMutableArray *postsList;

@property (strong, nonatomic) NSMutableDictionary *filterDictionary;

@property (strong, nonatomic) SUMDetailViewController *detailViewController;

@end

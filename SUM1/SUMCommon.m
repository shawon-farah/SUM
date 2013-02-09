//
//  SUMCommon.m
//  SUM
//
//  Created by Abdullah Farah on 1/28/13.
//  Copyright (c) 2013 Satnford, CA. All rights reserved.
//

#import "SUMCommon.h"
#import "SUMAppDelegate.h"
#import "SUMMasterViewController.h"
#import "SUMFilterViewController.h"

@implementation SUMCommon

+ (void)getPosts:(SUMMasterViewController*)view withFilter:(NSMutableDictionary*)filterDict withRefreshView:(id)refreshView
{
    PFObject *category = [filterDict objectForKey:@"category"];
    PFObject *subcategory = [filterDict objectForKey:@"subcategory"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"testsupostimport"];
    [query orderByDescending:@"time_posted"];
    [query whereKey:@"category_id" equalTo:[category objectForKey:@"category_id"]];
    [query whereKey:@"subcategory_id" equalTo:[subcategory objectForKey:@"subcategory_id"]];
    query.limit = 100;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            view.postsList = [[NSMutableArray alloc] initWithArray:objects];
            [view.tableView reloadData];
            SUMAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            appDelegate.postsList = view.postsList;
        } else {
            // Log details of the failure
            NSLog(@"Error: %@", error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not connect to server." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
//        [MBProgressHUD hideHUDForView:view.navigationController.view animated:YES];
        [refreshView finishedLoading];
    }];
}

+ (PFObject*)getCategory:(NSString*)categoryId {
    SUMAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category_id == %@", categoryId];
    NSArray *array = [appDelegate.categoryList filteredArrayUsingPredicate:predicate];
    
    return [array objectAtIndex:0];
}

+ (PFObject*)getSubcategory:(NSString*)subcategoryId {
    SUMAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subcategory_id == %@", subcategoryId];
    NSArray *array = [appDelegate.subcategoryList filteredArrayUsingPredicate:predicate];
    
    return [array objectAtIndex:0];
}

+ (NSString*)getCategoryString:(NSString*)categoryId {
    PFObject *category = [self getCategory:categoryId];
    
    return [category objectForKey:@"short_name"];
}

+ (NSString *)getCategoryStringFrom:(PFObject *)category {
    return [category objectForKey:@"short_name"];
}

+ (NSString*)getSubcategoryString:(NSString*)subcategoryId {
    PFObject *subCategory = [self getSubcategory:subcategoryId];
    
    return [subCategory objectForKey:@"name"];
}

+ (NSString*)getSubcategoryStringFrom:(PFObject*)subcategory {
    return [subcategory objectForKey:@"name"];
}

+ (NSString*)getDurationFromNow:(NSNumber*)timePosted {
    NSDate *convertedDate = [NSDate dateWithTimeIntervalSince1970:[timePosted doubleValue]];
//    NSLog(@"%@", convertedDate);
    
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
    	int diff = round(timeInterval / 3600);
    	return[NSString stringWithFormat:@"%d hours ago", diff];
    } else /*if (timeInterval < 2592000)*/ {
    	int diff = round(timeInterval / 86400);
    	return[NSString stringWithFormat:@"%d days ago", diff];
    }
}

+ (NSString *)getTimeString:(NSNumber *)timeNumber
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeNumber doubleValue]];
    NSDateFormatter *dtf = [[NSDateFormatter alloc] init];
    [dtf setDateFormat:@"EEE, MMM dd, yyyy hh:mm aa"];
    
    return [dtf stringFromDate:date];
}

+ (UIBarButtonItem *)getBreadcrumbLabelWith:(NSString*)string constrainedToSize:(CGSize)maxSize
{
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(0, 0, maxSize.width, maxSize.height);
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 2;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.font = [UIFont systemFontOfSize:10];
    label.text = string;
    CGSize size = [string sizeWithFont:label.font constrainedToSize:label.frame.size lineBreakMode:label.lineBreakMode];
    label.frame = CGRectMake(0, 0, size.width, maxSize.height);
    
    return [[UIBarButtonItem alloc] initWithCustomView:label];
}

+ (UIBarButtonItem *)getBreadcrumbButtonWith:(NSString*)string tag:(int)i delegate:(UIViewController*)viewController
{
    CGSize maxSize = CGSizeMake(70, 40);
    string = [NSString stringWithFormat:@" %@ ", string];
    CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:10] constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, size.width, 40);
    button.tag = i;
//    button.layer.borderColor = [c];
    button.layer.borderWidth = 1.0;
    button.layer.cornerRadius = 5.0;
    [button addTarget:viewController action:@selector(gotoView:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:string forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:10];
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [buttonItem setStyle:UIBarButtonItemStyleDone];
//    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:aViewController.title style:UIBarButtonItemStyleBordered target:viewController action:@selector(gotoView:)];
//    buttonItem.tag = i;
    
    return buttonItem;
}

+ (NSMutableArray *)getBreadcrumbItemsFor:(UIViewController *)viewController
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSArray *viewControllers = viewController.navigationController.viewControllers;
    CGSize size = CGSizeMake(60, 40);
    
    if (viewControllers.count == 1) {
        [items addObject:[SUMCommon getBreadcrumbLabelWith:viewController.title constrainedToSize:size]];
    }
    else
    {
        int count = viewControllers.count;
        for (int i = 0; i < count; i++) {
            UIViewController *aViewController = [viewControllers objectAtIndex:i];
            
            if (![aViewController isKindOfClass:[SUMFilterViewController class]])
            {
                if ([aViewController isKindOfClass:[SUMMasterViewController class]])
                {
                    SUMMasterViewController *masterView = (SUMMasterViewController*)aViewController;
                    if (masterView.filterDictionary != NULL)
                    {
                        if (aViewController == viewController)
                        {
                            NSString *str = [SUMCommon getCategoryStringFrom:[masterView.filterDictionary objectForKey:@"category"]];
                            str = [str stringByAppendingFormat:@" > %@", [SUMCommon getSubcategoryStringFrom:[masterView.filterDictionary objectForKey:@"subcategory"]]];
                            size = CGSizeMake(200, 40);
                            [items addObject:[SUMCommon getBreadcrumbLabelWith:str constrainedToSize:size]];
                        }
                        else
                        {
                            NSString *str = [NSString stringWithFormat:@"%@ >", [SUMCommon getCategoryStringFrom:[masterView.filterDictionary objectForKey:@"category"]]];
                            [items addObject:[SUMCommon getBreadcrumbLabelWith:str constrainedToSize:size]];
                            str = [SUMCommon getSubcategoryStringFrom:[masterView.filterDictionary objectForKey:@"subcategory"]];
                            [items addObject:[SUMCommon getBreadcrumbButtonWith:str tag:i delegate:viewController]];
                        }
                    }
                    else
                    {
                        [items addObject:[SUMCommon getBreadcrumbButtonWith:aViewController.title tag:i delegate:viewController]];
                    }
                }
                else
                {
                    if (count < 3) {
                        size = CGSizeMake(210, 40);
                    }
                    [items addObject:[SUMCommon getBreadcrumbLabelWith:aViewController.title constrainedToSize:size]];
                }
                
                if (i < count-1) {
                    [items addObject:[SUMCommon getBreadcrumbLabelWith:@">" constrainedToSize:size]];
                }
            }
        }
    }
    
    return items;
}

@end

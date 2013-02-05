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

@implementation SUMCommon

+ (void)getPosts:(SUMMasterViewController*)view withFilter:(NSMutableDictionary*)filterDict
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
        [MBProgressHUD hideHUDForView:view.navigationController.view animated:YES];
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

@end

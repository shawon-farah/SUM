//
//  SUMCommon.h
//  SUM
//
//  Created by Abdullah Farah on 1/28/13.
//  Copyright (c) 2013 Satnford, CA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "SUMMasterViewController.h"
#import "SUMDetailViewController.h"
#import "PullToRefreshView.h"

@interface SUMCommon : NSObject

+ (void)getPosts:(SUMMasterViewController*)view withLimit:(int)limit withFilter:(NSMutableDictionary*)filterDict withRefreshView:(id)refreshView;
+ (PFObject*)getCategory:(NSString*)categoryId;
+ (PFObject*)getSubcategory:(NSString*)subcategoryId;
+ (NSString*)getCategoryString:(NSString*)categoryId;
+ (NSString*)getCategoryStringFrom:(PFObject*)category;
+ (NSString*)getSubcategoryString:(NSString*)subcategoryId;
+ (NSString*)getSubcategoryStringFrom:(PFObject*)subcategory;
+ (NSString*)getDurationFromNow:(NSNumber*)timePosted;
+ (NSString *)getTimeString:(NSNumber *)timeNumber;
+ (NSMutableArray*)getBreadcrumbItemsFor:(UIViewController*)viewController;

@end

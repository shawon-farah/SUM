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

@interface SUMCommon : NSObject

+ (void)getPosts:(SUMMasterViewController*)view withFilter:(NSMutableDictionary*)filterDict;
+ (PFObject*)getCategory:(NSString*)categoryId;
+ (PFObject*)getSubcategory:(NSString*)subcategoryId;
+ (NSString*)getCategoryString:(NSString*)categoryId;
+ (NSString*)getSubcategoryString:(NSString*)subcategoryId;
+ (NSString*)getSubcategoryStringFrom:(PFObject*)subcategory;
+ (NSString*)getDurationFromNow:(NSNumber*)timePosted;
+ (NSString *)getTimeString:(NSNumber *)timeNumber;

@end

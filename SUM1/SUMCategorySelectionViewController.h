//
//  SUMCategorySelectionViewController.h
//  SUM
//
//  Created by Abdullah Farah on 1/9/13.
//  Copyright (c) 2013 Satnford, CA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol CategorySelectionDelegate

- (void)categorySelected:(id)category withSubcategory:(id)subcategory;

@end

@interface SUMCategorySelectionViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) NSMutableArray *subcategories;
@property (strong, nonatomic) NSArray *indexTitles;
@property (assign, nonatomic) id<CategorySelectionDelegate> categorySelectionDelegate;

@end

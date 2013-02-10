//
//  SUMFilterViewController.h
//  SUM
//
//  Created by Abdullah Farah on 1/8/13.
//  Copyright (c) 2013 Satnford, CA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SUMCategorySelectionViewController.h"

@interface SUMFilterViewController : UIViewController <CategorySelectionDelegate>

@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UIButton *categorySelectionButton;
@property (strong, nonatomic) IBOutlet UIButton *locationSelectionButton;
@property (strong, nonatomic) IBOutlet UIButton *browseButton;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;

@property (strong, nonatomic) NSMutableDictionary *filterDictionary;

@end

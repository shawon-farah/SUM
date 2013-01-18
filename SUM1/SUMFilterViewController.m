//
//  SUMFilterViewController.m
//  SUM
//
//  Created by Abdullah Farah on 1/8/13.
//  Copyright (c) 2013 Satnford, CA. All rights reserved.
//

#import "SUMFilterViewController.h"
#import "SUMCategorySelectionViewController.h"
#import "SUMMasterViewController.h"

@interface SUMFilterViewController ()

@end

@implementation SUMFilterViewController

- (void)dealloc
{
    [_searchTextField release];
    [_categorySelectionButton release];
    [_locationSelectionButton release];
    [_filterDictionary release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Filter", @"Title");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.filterDictionary = [[NSMutableDictionary alloc] init];
    
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
//    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
//    self.navigationItem.leftBarButtonItem = buttonItem;
//    self.navigationItem.leftItemsSupplementBackButton = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.searchTextField resignFirstResponder];
}

- (IBAction)selectCategory:(id)sender
{
    SUMCategorySelectionViewController *viewController = [[SUMCategorySelectionViewController alloc] initWithNibName:@"SUMCategorySelectionViewController" bundle:nil];
    viewController.categorySelectionDelegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)browseAll:(id)sender
{
    [self.filterDictionary setObject:self.searchTextField.text forKey:@"searchText"];
    SUMMasterViewController *viewController = [[SUMMasterViewController alloc] initWithNibName:@"SUMMasterViewController" bundle:nil];
    viewController.filterDictionary = self.filterDictionary;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)categorySelected:(id)category withSubcategory:(id)subcategory
{
    [self.categorySelectionButton setTitle:[NSString stringWithFormat:@"%@, %@", [subcategory objectForKey:@"name"], [category objectForKey:@"short_name"]] forState:UIControlStateNormal];
    [self.filterDictionary setObject:category forKey:@"category"];
    [self.filterDictionary setObject:subcategory forKey:@"subcategory"];
}

@end

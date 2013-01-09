//
//  SUMCategorySelectionViewController.m
//  SUM
//
//  Created by Abdullah Farah on 1/9/13.
//  Copyright (c) 2013 Satnford, CA. All rights reserved.
//

#import "SUMCategorySelectionViewController.h"
#import "SUMAppDelegate.h"
#import <Parse/Parse.h>

@interface SUMCategorySelectionViewController ()

@end

@implementation SUMCategorySelectionViewController

- (void)dealloc
{
    [_categories release];
    [_subcategories release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    SUMAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.categories = appDelegate.categoryList;
    self.subcategories = appDelegate.subcategoryList;
    self.indexTitles = [self getIndexTitles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)getIndexTitles
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (PFObject *object in self.categories) {
        [array addObject:[object objectForKey:@"short_name"]];
    }
    
    return array;
}

- (NSArray *)getSubcategoriesOfCategoryIndex:(NSInteger)index
{
    PFObject *aCategory = (PFObject*)[self.categories objectAtIndex:index];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category_id == %@", [aCategory objectForKey:@"category_id"]];
    
    return [self.subcategories filteredArrayUsingPredicate:predicate];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.categories count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray *array = [self getSubcategoriesOfCategoryIndex:section];
    return [array count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.indexTitles;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    PFObject *aCategory = (PFObject *)[self.categories objectAtIndex:section];
    
    return [aCategory objectForKey:@"short_name"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSArray *array = [self getSubcategoriesOfCategoryIndex:indexPath.section];
    PFObject *aSubcategory = (PFObject *)[array objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [aSubcategory objectForKey:@"name"];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    NSArray *array = [self getSubcategoriesOfCategoryIndex:indexPath.section];
    [self.categorySelectionDelegate categorySelected:[self.categories objectAtIndex:indexPath.section] withSubcategory:[array objectAtIndex:indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

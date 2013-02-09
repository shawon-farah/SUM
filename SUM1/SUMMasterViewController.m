//
//  SUMMasterViewController.m
//  SUM1
//
//  Created by Abdullah Farah on 12/2/12.
//  Copyright (c) 2012 Satnford, CA. All rights reserved.
//

#import "SUMMasterViewController.h"
#import <Parse/Parse.h>
#import "SUMDetailViewController.h"
#import "SUMImageWithTwoSubtitleCell.h"
#import "MBProgressHUD.h"
#import "SUMAppDelegate.h"
#import "SUMFilterViewController.h"
#import "SUMCommon.h"

#define IMAGE_URL_SUFFIX @"http://supost.com/uploads/post/"

@interface SUMMasterViewController () {
//    NSMutableArray *_postsList;
}

//@property (nonatomic, retain) NSMutableArray *_postsList;

@end

@implementation SUMMasterViewController
{
    PullToRefreshView *pull;
}

@synthesize nibLoadedTableCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Stanford, CA", @"Master");
    }
    return self;
}
							
- (void)dealloc
{
    [_tableView release];
    [_breadcrumb release];
    [_detailViewController release];
    [_postsList release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    if (!self.filterDictionary) {
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStyleBordered target:self action:@selector(filterTapped:)];
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
    
    pull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView*)self.tableView];
    [pull setDelegate:self];
    [self.tableView addSubview:pull];
    
    if (self.filterDictionary) {
        [self filterPosts];
    } else {
        self.tableView.contentOffset = CGPointMake(0, -65);
        [pull setState:PullToRefreshViewStateLoading];
        [self loadPostData];
    }
    appDelegate = [UIApplication sharedApplication].delegate;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(foregroundRefresh:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.breadcrumb setItems:[SUMCommon getBreadcrumbItemsFor:self]];
}

- (void)foregroundRefresh:(NSNotification *)notification
{
    self.tableView.contentOffset = CGPointMake(0, -65);
    [pull setState:PullToRefreshViewStateLoading];
    if (self.filterDictionary)
        [self performSelectorInBackground:@selector(filterPosts) withObject:nil];
    else
        [self performSelectorInBackground:@selector(loadPostData) withObject:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)gotoView:(id)sender
{
    UIButton *button = (UIButton*)sender;
//    UIBarButtonItem *button = (UIBarButtonItem*)sender;
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    [self.navigationController popToViewController:[viewControllers objectAtIndex:button.tag] animated:YES];
}

- (IBAction)filterTapped:(id)sender
{
    SUMFilterViewController *viewController = [[SUMFilterViewController alloc] initWithNibName:@"SUMFilterViewController" bundle:nil];
    [appDelegate pushViewControllerWithFlipTransition:viewController];
}

- (void)filterPosts
{
    NSLog(@"%@, %@, %@", [self.filterDictionary objectForKey:@"searchText"], [self.filterDictionary objectForKey:@"category"], [self.filterDictionary objectForKey:@"subcategory"]);
    self.tableView.contentOffset = CGPointMake(0, -65);
    [pull setState:PullToRefreshViewStateLoading];
    /*  if wanna run filter on last fetched posts from parse
     *  this operation will run the filter on last fetched 100 posts 
     */
//    PFObject *category = [self.filterDictionary objectForKey:@"category"];
//    PFObject *subcategory = [self.filterDictionary objectForKey:@"subcategory"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category_id == %@ AND subcategory_id == %@", [category objectForKey:@"category_id"], [subcategory objectForKey:@"subcategory_id"]];
//    
//    self.title = NSLocalizedString([subcategory objectForKey:@"name"], @"Master");
//    SUMAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//    self.postsList = (NSMutableArray*)[appDelegate.postsList filteredArrayUsingPredicate:predicate];
//    [self.tableView reloadData];
    
    /*  if wanna run filter on parse and fetch filtered data from parse 
     *  this will run the filter on whole parse db will get the most recent 100 filtered posts
     */
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
//    [self.navigationController.view addSubview:hud];
//    
//    hud.delegate = self;
//    hud.labelText = @"Loading";
//    [hud show:YES];
    NSString *titleText = [SUMCommon getSubcategoryStringFrom:[self.filterDictionary objectForKey:@"subcategory"]];
    self.title = NSLocalizedString(titleText, @"Filter");
    [self.breadcrumb setItems:[SUMCommon getBreadcrumbItemsFor:self]];
    [SUMCommon getPosts:self withFilter:self.filterDictionary withRefreshView:pull];
    
}

- (void)loadPostData
{
    PFQuery *query = [PFQuery queryWithClassName:@"testsupostimport"];
    [query orderByDescending:@"time_posted"];
    [query whereKey:@"status" equalTo:[NSNumber numberWithInt:1]];
    query.limit = 100;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.postsList = [[NSMutableArray alloc] initWithArray:objects];
            [self.tableView reloadData];
            appDelegate.postsList = self.postsList;
        } else {
            // Log details of the failure
            NSLog(@"Error: %@", error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not connect to server." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
        [pull finishedLoading];
    }];
}

- (NSString *)getTimeString:(NSNumber *)timeNumber
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeNumber doubleValue]];
    NSDateFormatter *dtf = [[NSDateFormatter alloc] init];
    [dtf setDateFormat:@"MMM dd"];
    
    return [dtf stringFromDate:date];
}

- (NSString *)getSubcategoryName:(NSNumber*)subcategoryId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subcategory_id == %@", subcategoryId];
    NSArray *array = [appDelegate.subcategoryList filteredArrayUsingPredicate:predicate];
    PFObject *object = (PFObject *)[array objectAtIndex:0];
    
    return [object objectForKey:@"name"];
}

- (NSString *)getCategoryName:(NSNumber*)categoryId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category_id == %@", categoryId];
    NSArray *array = [appDelegate.categoryList filteredArrayUsingPredicate:predicate];
    PFObject *object = (PFObject *)[array objectAtIndex:0];
    
    return [object objectForKey:@"short_name"];
}

- (NSString *)getDetailsText:(NSString*)detailsText
{
    detailsText = [detailsText stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    detailsText = [detailsText stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    detailsText = [detailsText stringByReplacingOccurrencesOfString:@"\\n" withString:@" "];
    detailsText = [detailsText stringByReplacingOccurrencesOfString:@"<br />" withString:@" "];
    detailsText = [detailsText stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
    detailsText = [detailsText stringByReplacingOccurrencesOfString:@"<br/>" withString:@" "];
    
    return detailsText;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.postsList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 98.0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PostsListCell";
    
    SUMImageWithTwoSubtitleCell *cell = (SUMImageWithTwoSubtitleCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SUMImageWithTwoSubtitleCell" owner:self options:NULL];
        cell = (SUMImageWithTwoSubtitleCell*)nibLoadedTableCell;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    PFObject *object = (PFObject *)[self.postsList objectAtIndex:indexPath.row];
    
    NSString *imageName = [object objectForKey:@"image_source1"];
    if ([imageName length] > 0 && ![imageName isEqualToString:@"NULL"]) {
        [cell.spinner startAnimating];
        [cell bringSubviewToFront:cell.spinner];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGE_URL_SUFFIX, imageName]];
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData * data = [[NSData alloc] initWithContentsOfURL:url];
            if ( data == nil )
                return;
            dispatch_async(dispatch_get_main_queue(), ^{
                // WARNING: is the cell still using the same data by this point??
                cell.imageView.image = [UIImage imageWithData: data];
                cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
                [cell.spinner stopAnimating];
                [cell.spinner removeFromSuperview];
            });
        });
    } else
        [cell.spinner removeFromSuperview];
    
    cell.titleTextLabel.text = [object objectForKey:@"name"];
    cell.detailsTextLabel.text = [self getDetailsText:[object objectForKey:@"body"]];
    cell.intervalTextLabel.text = [SUMCommon getDurationFromNow:[object objectForKey:@"time_posted"]];
    
    NSString *str = [self getTimeString:[object objectForKey:@"time_posted"]];
    str = [str stringByAppendingString:@" * Stanford, CA"];
    str = [str stringByAppendingFormat:@" * %@ (%@)", [self getSubcategoryName:[object objectForKey:@"subcategory_id"]], [self getCategoryName:[object objectForKey:@"category_id"]]];
    cell.subtitleTextLabel.text = str;
    
    return cell;
}

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_postsList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.detailViewController = [[[SUMDetailViewController alloc] initWithNibName:@"SUMDetailViewController" bundle:nil] autorelease];
    
    PFObject *object = _postsList[indexPath.row];
    self.detailViewController.detailItem = object;
    self.detailViewController.currentIndex = indexPath.row;
    self.detailViewController.currentPostsArray = self.postsList;
    [appDelegate pushViewControllerAnimated:self.detailViewController];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[hud removeFromSuperview];
	[hud release];
}

#pragma mark -
#pragma mark PullToRefreshViewDelegate methods

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    if (self.filterDictionary) 
        [self performSelectorInBackground:@selector(filterPosts) withObject:nil];
    else
        [self performSelectorInBackground:@selector(loadPostData) withObject:nil];
}

@end

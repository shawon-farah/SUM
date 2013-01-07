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

#define IMAGE_URL_SUFFIX @"http://supost.com/uploads/post/"

@interface SUMMasterViewController () {
    NSMutableArray *_postsList;
}

@property (nonatomic, retain) NSMutableArray *_postsList;

@end

@implementation SUMMasterViewController

@synthesize nibLoadedTableCell, _postsList;

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
    [_detailViewController release];
    [_postsList release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadPostData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPostData
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    
    hud.delegate = self;
    hud.labelText = @"Loading";
    [hud show:YES];
    
    PFQuery *query = [PFQuery queryWithClassName:@"testsupostimport"];
    [query orderByDescending:@"time_posted"];
    query.limit = 100;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self._postsList = [[NSMutableArray alloc] initWithArray:objects];
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@", error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not connect to server." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    }];
}

- (NSString *)getLastUpdateTimeInterval:(NSNumber *)timePosted
{
    NSDate *convertedDate = [NSDate dateWithTimeIntervalSince1970:[timePosted doubleValue]];
    NSLog(@"%@", convertedDate);
    
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
    	int diff = round(timeInterval / 60 / 60);
    	return[NSString stringWithFormat:@"%d hours ago", diff];
    } else if (timeInterval < 2629743) {
    	int diff = round(timeInterval / 60 / 60 / 24);
    	return[NSString stringWithFormat:@"%d days ago", diff];
    } else {
    	return @"never";
    }
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self._postsList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 102.0;
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

    PFObject *object = (PFObject *)[self._postsList objectAtIndex:indexPath.row];
    
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
                [cell.spinner stopAnimating];
                [cell.spinner removeFromSuperview];
            });
        });
    } else
        [cell.spinner removeFromSuperview];
    
    cell.titleTextLabel.text = [object objectForKey:@"name"];
    cell.detailsTextLabel.text = [object objectForKey:@"body"];
    cell.intervalTextLabel.text = [self getLastUpdateTimeInterval:[object objectForKey:@"time_posted"]];
    
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
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[hud removeFromSuperview];
	[hud release];
}

@end

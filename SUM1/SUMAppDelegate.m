//
//  SUMAppDelegate.m
//  SUM1
//
//  Created by Abdullah Farah on 12/2/12.
//  Copyright (c) 2012 Satnford, CA. All rights reserved.
//

#import "SUMAppDelegate.h"
#import <Parse/Parse.h>
#import "SUMMasterViewController.h"

@implementation SUMAppDelegate

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [_categoryList release];
    [_subcategoryList release];
    [_postsList release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"RpdufmbOLoCCFkUJ9lUHESu6Xb8pYJT8EJXpJ60v"
                  clientKey:@"uDe5rnD4rbjMVP76BmyJ9M8BmjHi4vdKZqPR4KII"];
    
    PFQuery *queryCategory = [PFQuery queryWithClassName:@"category"];
    [queryCategory orderByAscending:@"category_id"];
    self.categoryList = (NSMutableArray*)[queryCategory findObjects];
    /*[queryCategory findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.categoryList = [[NSMutableArray alloc] initWithArray:objects];
        }
    }];*/
    PFQuery *querySubcategory = [PFQuery queryWithClassName:@"subcategory"];
    [querySubcategory orderByAscending:@"category_id"];
    self.subcategoryList = (NSMutableArray*)[querySubcategory findObjects];
    /*[querySubcategory findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.subcategoryList = [[NSMutableArray alloc] initWithArray:objects];
        }
    }];*/
    NSLog(@"Category: %d, Subcategory: %d", [self.categoryList count], [self.subcategoryList count]);
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.

    SUMMasterViewController *masterViewController = [[[SUMMasterViewController alloc] initWithNibName:@"SUMMasterViewController" bundle:nil] autorelease];
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

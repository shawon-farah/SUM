//
//  SUMAppDelegate.h
//  SUM1
//
//  Created by Abdullah Farah on 12/2/12.
//  Copyright (c) 2012 Satnford, CA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SUMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) NSMutableArray *categoryList;
@property (strong, nonatomic) NSMutableArray *subcategoryList;
@property (strong, nonatomic) NSMutableArray *postsList;

- (void)pushViewControllerAnimated:(UIViewController*)viewController;
- (void)pushViewControllerWithFlipTransition:(UIViewController*)viewController;
- (void)popViewControllerAnimated:(UIViewController*)viewController;
- (void)gotoViewController:(id)sender;

@end

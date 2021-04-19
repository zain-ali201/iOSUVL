//
//  UVLAppglobals.m
//  UVL
//
//  Created by Osama on 25/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "UVLAppglobals.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@implementation UVLAppglobals
#pragma mark -
#pragma mark Class Methods
+ (UVLAppglobals *)sharedAppGlobals {
    static UVLAppglobals *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark - ************ Object Encode/Decoder Methods ***********
- (void)saveObjectWithKey:(id)object key:(NSString *)key {
    //    [[NMParser sharedNMParser] saveObjectWithKey:object key:key];
}

- (id )parseObjectForKey:(NSString *)key {
    return nil;//[[NMParser sharedNMParser] parseObjectForKey:key];
}


#pragma mark - ************ Load Storyboards ***********
- (void)loadLoginStoryboard
{
    // rootViewController
    UIViewController* rootController;
    rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:rootController];
    navigationController.navigationBar.hidden = YES;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    delegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    delegate.window.rootViewController = navigationController;
    [delegate.window makeKeyAndVisible];
}
- (void)loadDashboard
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    delegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    delegate.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    UITabBarController *tabBar = (UITabBarController *)delegate.window.rootViewController;
    [tabBar setSelectedIndex:0];
    [delegate.window makeKeyAndVisible];
    
//
    
    //    UIViewController* rootController;
    //    rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    //    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:rootController];
    //    navigationController.navigationBar.hidden = YES;
    
//    UIViewController* rootController;
//    rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"HomeViewController"];
//    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:rootController];
//    navigationController.navigationBar.hidden = NO;
//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    delegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    delegate.window.rootViewController = navigationController;
//
//    [delegate.window makeKeyAndVisible];
    
    
}

@end

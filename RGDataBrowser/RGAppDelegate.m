//
//  RGAppDelegate.m
//  RGDataBrowser
//
//  Created by Roland on 01/06/2013.
//  Copyright (c) 2013 RG. All rights reserved.
//

#import "RGAppDelegate.h"
#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import "RGFeedManager.h"
#import "DDLog.h"


#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_INFO;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif


@implementation RGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    // setup Core Data stack
#warning that doesn't work - why?
    //#ifdef KIWITESTING
    //        [MagicalRecord setupCoreDataStackWithInMemoryStore];
    //#else
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"RGRSS.sqlite"];
    
    //#endif
    
//    [[RGFeedManager sharedRGFeedManager] loadDataURLString:@"0Apmsn6hlyPHudHUxSHJ1YzhPVjV4VEJTTkl6aGhnclE/od6/public/values?alt=json"];
//    [[RGFeedManager sharedRGFeedManager] loadConfigDataURLString:@"0Apmsn6hlyPHudHUxSHJ1YzhPVjV4VEJTTkl6aGhnclE/od7/public/values?alt=json"];
//    [[RGFeedManager sharedRGFeedManager] loadDataFileString:@"CountriesFlags" extension:@"json"];

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
    [MagicalRecord cleanUp];
}

@end

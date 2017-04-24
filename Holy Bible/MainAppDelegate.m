//
//  MainAppDelegate.m
//  Holy Bible
//
//  Created by Will Lien on 12/1/27.
//  Copyright (c) 2012年 fishgold. All rights reserved.
//

#import "MainAppDelegate.h"

@implementation MainAppDelegate

@synthesize navigationController, window;

- (void)dealloc
{
	[navigationController release];
	[window release];
	
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ( [prefs valueForKey:@"hasVerseNumber"] == nil ) {
        [prefs setValue:@"true" forKey:@"hasVerseNumber"];
        [prefs synchronize];
    }
	// add the navigation controller's view to the window
	//[window addSubview:navigationController.view];
    [window setRootViewController:navigationController];
	[window makeKeyAndVisible];
}

@end

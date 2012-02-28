//
//  MainAppDelegate.h
//  Holy Bible
//
//  Created by Will Lien on 12/1/27.
//  Copyright (c) 2012年 fishgold. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainAppDelegate : UIResponder <UIApplicationDelegate>
{
    UIWindow *window;
	UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

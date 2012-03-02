//
//  MainViewController.h
//  Holy Bible
//
//  Created by Will Lien on 12/1/27.
//  Copyright (c) 2012年 fishgold. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
	UITableView	*myTableView;
	NSMutableArray *menuList;
    NSMutableArray *oldList;
    NSMutableArray *newList;
}

@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *menuList;
@property (nonatomic, retain) NSMutableArray *oList;
@property (nonatomic, retain) NSMutableArray *nList;


@end

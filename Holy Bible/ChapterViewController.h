//
//  PageOneViewController.h
//  Holy Bible
//
//  Created by Will Lien on 12/1/27.
//  Copyright (c) 2012年 fishgold. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChapterViewController : UIViewController <UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
    
    UITableView	*myTableView;
    NSMutableArray *menuList;
    NSInteger versesAmount;
    NSString *booksName;
    NSInteger currentIndex;

}

@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *menuList;

- (id)init:(NSString *)title andVersesAmount:(NSInteger)num;
- (void)swipeNotify:(NSNotification *)notification;
@end

//
//  PageTwoViewController.h
//  Holy Bible
//
//  Created by Will Lien on 12/1/27.
//  Copyright (c) 2012年 fishgold. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentViewController : UIViewController
{
    UITextView *myTextView;
    NSString *chapter;
    NSString *booksName;
    bool hasVerse;
    CGFloat oldVelocity;
    
}

@property (nonatomic, retain) IBOutlet UITextView *myTextView;

- (id)init:(NSString *)title andChapter:(NSString *)num;
- (void)test;
- (void)pinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer;

@end

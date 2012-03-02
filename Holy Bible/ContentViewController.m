//
//  ContentViewController.m
//  Holy Bible
//
//  Created by Will Lien on 12/1/27.
//  Copyright (c) 2012年 fishgold. All rights reserved.
//

#import "ContentViewController.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "BIG5toGB.h"

@implementation ContentViewController
@synthesize myTextView;

- (void)dealloc
{
    [booksName release];
    [chapter release];
    [super dealloc];
}

- (id)init:(NSString *)title andChapter:(NSString *)num;
{
    self = [super initWithNibName:@"Content" bundle:nil];
    if (self) {
        // Custom initialization
        booksName = title;
        chapter = num;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        if ( [(NSString *)[prefs valueForKey:@"hasVerseNumber"] isEqualToString:@"false"] )
            hasVerse = false;
        else
            hasVerse = true;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSString *dbpath = [[NSBundle mainBundle] pathForResource:@"cunp.sqlite3" ofType:nil]; 
    
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];    

    // Do any additional setup after loading the view from its nib.
    if ([booksName isEqualToString:@"詩篇"] || [booksName isEqualToString:@"诗篇"])
        self.title = [NSString stringWithFormat:@"第 %@ 篇", chapter];
    else
        self.title = [NSString stringWithFormat:@"第 %@ 章", chapter];

    
    FMDatabase* db = [FMDatabase databaseWithPath:dbpath];
    if (![db open]) {
        NSLog(@"Ooops");
        return;
    }
    
    NSString *rs;
    if ([language isEqualToString:@"zh-Hans"]) 
        rs = [db stringForQuery:@"select osis from books_simpl where human = ?", booksName];
    else
        rs = [db stringForQuery:@"select osis from books where human = ?", booksName];
    
    NSString *search_text = [[NSString alloc] initWithFormat:@"%@.%%", chapter];
    
    FMResultSet *rs2 = [db executeQuery:@"select * from verses where book=? and verse like ?", rs, search_text];
    [search_text release];
    
    NSMutableString *content = [[NSMutableString alloc] initWithString:@""];
    NSString *trimText;
    NSInteger versesNum = 1;
    while ([rs2 next]) {
        
        trimText = [[rs2 stringForColumn:@"unformatted"] stringByReplacingOccurrencesOfString:@" +" withString:@""
                                                            options:NSRegularExpressionSearch
                                                              range:NSMakeRange(0, [rs2 stringForColumn:@"unformatted"].length)];
        
        if ([trimText rangeOfString:@"\n"].location == 0  && versesNum != 1) {
            [content appendString:@"\n\n"];
        }
        
        trimText = [trimText stringByReplacingOccurrencesOfString:@"\n+" withString:@"" 
                                                            options:NSRegularExpressionSearch 
                                                            range:NSMakeRange(0, trimText.length)];
        if ([language isEqualToString:@"zh-Hans"])
             trimText = [trimText stringByReplacingOccurrencesOfString:@"裏" withString:@"裡" 
                                                          options:NSRegularExpressionSearch 
                                                            range:NSMakeRange(0, trimText.length)];
        
        if (hasVerse)
            [content appendString:[NSString stringWithFormat:@"%d ", versesNum]];
        
        [content appendString:trimText];
        versesNum++;
    }
   
    if ([language isEqualToString:@"zh-Hans"]) {
        UInt32 big5 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *big5EncStr = [content stringByReplacingPercentEscapesUsingEncoding:big5];
        Big5ToGB *big5togb = [[Big5ToGB alloc] init];
        NSString *gbEncStr = [big5togb big5ToGB:big5EncStr];
        [myTextView setText:gbEncStr];
        [big5togb release];
    } 
    else
        [myTextView setText:content];
    
    [content release];
    [db close];
    
    
    UISwipeGestureRecognizer  *recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipeFrom:)];
    [recognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:recognizerLeft];
    [recognizerLeft release]; 
    
    UISwipeGestureRecognizer  *recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipeFrom:)];
    [recognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:recognizerRight];
    [recognizerRight release];
    
    // -----------------------------
    // One finger, two taps
    // -----------------------------
    
    // Create gesture recognizer
    UITapGestureRecognizer *oneFingerTwoTaps = 
    [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerTwoTaps)] autorelease];
    // Set required taps and number of touches
    [oneFingerTwoTaps setNumberOfTapsRequired:1];
    [oneFingerTwoTaps setNumberOfTouchesRequired:1];
    // Add the gesture to the view
    [[self view] addGestureRecognizer:oneFingerTwoTaps];
    
    [super viewDidLoad];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    myTextView = nil;
    booksName = nil;
    chapter = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)handleLeftSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    //NSLog(@"handleLeftSwipeFrom received: %d", recognizer.direction);
    
    NSDictionary* dict;
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
        dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:UISwipeGestureRecognizerDirectionLeft] forKey:@"direction"];

    if (dict) 
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@%@", @"swipeNotify", booksName] object:self userInfo:dict];

}

-(void)handleRightSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    //NSLog(@"handleRightSwipeFrom received: %d", recognizer.direction);
    
    NSDictionary* dict;
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight)
        dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:UISwipeGestureRecognizerDirectionRight] forKey:@"direction"];
    
    if (dict) 
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@%@", @"swipeNotify", booksName] object:self userInfo:dict];
    
}

- (void)oneFingerTwoTaps {
    //NSLog(@"Action: one fingers, two taps");
    hasVerse = !hasVerse;
    
    CGPoint p = [myTextView contentOffset];
    
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0]; 
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ( hasVerse )
        [prefs setValue:@"true" forKey:@"hasVerseNumber"];
    else 
        [prefs setValue:@"false" forKey:@"hasVerseNumber"];

    [prefs synchronize];
    
    NSString *dbpath = [[NSBundle mainBundle] pathForResource:@"cunp.sqlite3" ofType:nil]; 
    FMDatabase* db = [FMDatabase databaseWithPath:dbpath];
    if (![db open]) {
        NSLog(@"Ooops");
        return;
    }
    
    NSString *rs;
    if ([language isEqualToString:@"zh-Hans"]) 
        rs = [db stringForQuery:@"select osis from books_simpl where human = ?", booksName];
    else
        rs = [db stringForQuery:@"select osis from books where human = ?", booksName];
    
    NSString *search_text = [[NSString alloc] initWithFormat:@"%@.%%", chapter];
    
    FMResultSet *rs2 = [db executeQuery:@"select * from verses where book=? and verse like ?", rs, search_text];
    [search_text release];
    
    NSMutableString *content = [[NSMutableString alloc] initWithString:@""];
    NSString *trimText;
    NSInteger versesNum = 1;
    while ([rs2 next]) {
        trimText = [[rs2 stringForColumn:@"unformatted"] stringByReplacingOccurrencesOfString:@" +" withString:@""
                                                                                      options:NSRegularExpressionSearch
                                                                                        range:NSMakeRange(0, [rs2 stringForColumn:@"unformatted"].length)];
        if ([trimText rangeOfString:@"\n"].location == 0 && versesNum != 1) {
            [content appendString:@"\n\n"];
        }
        
        trimText = [trimText stringByReplacingOccurrencesOfString:@"\n+" withString:@"" 
                                                          options:NSRegularExpressionSearch 
                                                            range:NSMakeRange(0, trimText.length)];
        if ([language isEqualToString:@"zh-Hans"])
            trimText = [trimText stringByReplacingOccurrencesOfString:@"裏" withString:@"裡" 
                                                              options:NSRegularExpressionSearch 
                                                                range:NSMakeRange(0, trimText.length)];
        
        if (hasVerse)
            [content appendString:[NSString stringWithFormat:@"%d ", versesNum]];
        [content appendString:trimText];
        
        versesNum++;
    }
    
    [self.myTextView setScrollEnabled:NO];
    [self.myTextView setText:@""];
    
    if ([language isEqualToString:@"zh-Hans"]) {
        UInt32 big5 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *big5EncStr = [content stringByReplacingPercentEscapesUsingEncoding:big5];
        Big5ToGB *big5togb = [[Big5ToGB alloc] init];
        NSString *gbEncStr = [big5togb big5ToGB:big5EncStr];
        [self.myTextView setText:gbEncStr];
        [big5togb release];
    }
    else
        [self.myTextView setText:content];
    
    
    [self.myTextView setScrollEnabled:YES];
    [self.myTextView setContentOffset:p animated:NO];
    
    [content release];
    [db close];
} 


@end

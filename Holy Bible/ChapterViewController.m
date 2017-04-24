//
//  PageOneViewController.m
//  Holy Bible
//
//  Created by Will Lien on 12/1/27.
//  Copyright (c) 2012年 fishgold. All rights reserved.
//

#import "ChapterViewController.h"
#import "ContentViewController.h"

@implementation ChapterViewController

@synthesize myTableView, menuList;

#define kViewControllerKey		@"viewController"
#define kTitleKey				@"title"
#define kDetailKey				@"detail text"

- (void)dealloc
{
    [myTableView release];
    [menuList release];
    [booksName release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (id)init:(NSString *)title andVersesAmount:(NSInteger)num;
{
    self = [super initWithNibName:@"Chapter" bundle:nil];
    if (self) {
        // Custom initialization
        self.title = booksName = title;
        versesAmount = num;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(swipeNotify:) name:[NSString stringWithFormat:@"%@%@", @"swipeNotify", booksName] object:nil];
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
    [super viewDidLoad];
    self.title = booksName;
    self.menuList = [NSMutableArray array];
    
    if ([booksName isEqualToString:@"詩篇"] || [booksName isEqualToString:@"诗篇"])
        for (int i=1; i<=versesAmount; i++) {
            [self.menuList addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [NSString stringWithFormat: @"第 %d 篇",i], kTitleKey,
                                      [NSString stringWithFormat: @"%d",i], kDetailKey,
                                      nil]];
            
        }
    else 
        for (int i=1; i<=versesAmount; i++) {
            [self.menuList addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [NSString stringWithFormat: @"第 %d 章",i], kTitleKey,
                                      [NSString stringWithFormat: @"%d",i], kDetailKey,
                                      nil]];
             
        }
         
    
	[self.myTableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.myTableView = nil;
    self.menuList = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.myTableView deselectRowAtIndexPath:self.myTableView.indexPathForSelectedRow animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return menuList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellIdentifier = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (!cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellIdentifier] autorelease];
        
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.textLabel.opaque = NO;
		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.highlightedTextColor = [UIColor whiteColor];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
		
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.opaque = NO;
		cell.detailTextLabel.textColor = [UIColor grayColor];
		cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
		cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    }
    
	// get the view controller's info dictionary based on the indexPath's row
    NSDictionary *dataDictionary = [menuList objectAtIndex:indexPath.row];
    cell.textLabel.text = [dataDictionary valueForKey:kTitleKey];
    cell.detailTextLabel.text = @"";

	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentIndex = indexPath.row;
    
    NSMutableDictionary *rowData = [self.menuList objectAtIndex:indexPath.row];
	UIViewController *targetViewController = [rowData objectForKey:kViewControllerKey];
	if (!targetViewController) {
        targetViewController = [[ContentViewController  alloc] init:booksName andChapter:[rowData objectForKey:kDetailKey]];
        [rowData setValue:targetViewController forKey:kViewControllerKey];
        [targetViewController release];
    }
    [self.navigationController pushViewController:targetViewController animated:YES];
}

#pragma mark -
- (void)swipeNotify:(NSNotification *)notification
{
    //NSLog(@"swipeNotify: %@", notification.userInfo);
    //NSLog(@"swipeNotify: %@", [notification.userInfo objectForKey:@"direction"]);
    NSNumber *direction = [notification.userInfo objectForKey:@"direction"];
    if ([direction integerValue] == UISwipeGestureRecognizerDirectionRight) {
        if(--currentIndex <0) {
            currentIndex = 0;
            NSLog(@"currentIndex limited: %ld", (long)currentIndex);
            return;
        }
    }
    else if ([direction integerValue] == UISwipeGestureRecognizerDirectionLeft) {
        if(++currentIndex >= versesAmount) {
            currentIndex = versesAmount-1;
            NSLog(@"currentIndex limited: %ld", (long)currentIndex);
            return;
        }
    }
    
    NSMutableDictionary *rowData = [menuList objectAtIndex:currentIndex];
	UIViewController *targetViewController = [rowData objectForKey:kViewControllerKey];
	if (!targetViewController)
	{
        targetViewController = [[ContentViewController  alloc] init:booksName andChapter:[rowData objectForKey:kDetailKey]];
        [rowData setValue:targetViewController forKey:kViewControllerKey];
        [targetViewController release];
    }
    
    NSMutableArray *vcs =  [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    if ([direction integerValue] == UISwipeGestureRecognizerDirectionRight) {
        [vcs insertObject:targetViewController atIndex:[vcs count]-1];
        [self.navigationController setViewControllers:vcs animated:NO];
        [self.navigationController popViewControllerAnimated:YES]; 
    }
    else if ([direction integerValue] == UISwipeGestureRecognizerDirectionLeft) {
        [vcs replaceObjectAtIndex:[vcs count]-1 withObject:targetViewController]; 
        [self.navigationController setViewControllers:vcs animated:YES];
    }
    
}

@end

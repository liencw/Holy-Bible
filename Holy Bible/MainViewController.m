//
//  MainViewController.m
//  Holy Bible
//
//  Created by Will Lien on 12/1/27.
//  Copyright (c) 2012年 fishgold. All rights reserved.
//

#import "MainViewController.h"
#import "FMDatabase.h"
#import "ChapterViewController.h"
#import "BIG5toGB.h"

@implementation MainViewController

@synthesize myTableView, menuList, oList, nList;

#define kViewControllerKey		@"viewController"
#define kTitleKey				@"title"
#define kDetailKey				@"detail text"
#define kSimpifiedKey           @"simlified name"


- (void)dealloc
{
    [myTableView release];
    [menuList release];
    [oList release];
    [nList release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"CFBundleDisplayName",nil);
    //self.title = @"聖經和合本";
    self.menuList = [NSMutableArray array];
    self.oList = [NSMutableArray array];
    self.nList = [NSMutableArray array];
    NSString *dbpath = [[NSBundle mainBundle] pathForResource:@"cunp.sqlite3" ofType:nil]; 
    
    FMDatabase* db = [FMDatabase databaseWithPath:dbpath];
    if (![db open]) {
        NSLog(@"Ooops");
        return;
    }
    
    FMResultSet *rs;
    if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"zh-Hans"])
        rs = [db executeQuery:@"select * from books_simpl"];
    else 
        rs = [db executeQuery:@"select * from books"];
    
    while ([rs next]) {
        
        if ([[rs stringForColumn:@"number"] intValue] < 40)
            [self.oList addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [rs stringForColumn:@"human"], kTitleKey,
                                [rs stringForColumn:@"chapters"], kDetailKey,
                                [rs stringForColumn:@"simpl"], kSimpifiedKey,
                                nil]];
        else
            [self.nList addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [rs stringForColumn:@"human"], kTitleKey,
                                [rs stringForColumn:@"chapters"], kDetailKey,
                                [rs stringForColumn:@"simpl"], kSimpifiedKey,
                                nil]];
        
    }
    
    [self.menuList addObject:oList];
    [self.menuList addObject:nList];
    
    [db close];
	[self.myTableView reloadData];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.myTableView = nil;
    self.menuList = nil;
    self.oList = nil;
    self.nList = nil;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.menuList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [[self.menuList objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    
    if(section == 0)
        return NSLocalizedString(@"OLDTestment",nil);
    else
        return NSLocalizedString(@"NEWTestment",nil);
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
    NSMutableArray *sublist = [menuList objectAtIndex:indexPath.section];
    NSDictionary *dataDictionary = [sublist objectAtIndex:indexPath.row];
    cell.textLabel.text = [dataDictionary valueForKey:kTitleKey];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", 
                                     [dataDictionary valueForKey:kSimpifiedKey], 
                                     [dataDictionary valueForKey:kDetailKey]];
    
	return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *sublist = [self.menuList objectAtIndex:indexPath.section];
    NSMutableDictionary *rowData = [sublist objectAtIndex:indexPath.row];
	UIViewController *targetViewController = [rowData objectForKey:kViewControllerKey];
	if (!targetViewController)
	{
        targetViewController = [[ChapterViewController  alloc] init:[rowData objectForKey:kTitleKey] andVersesAmount:[[rowData objectForKey:kDetailKey] intValue]];
        [rowData setValue:targetViewController forKey:kViewControllerKey];
        [targetViewController release];
    }
    [self.navigationController pushViewController:targetViewController animated:YES];
}


@end

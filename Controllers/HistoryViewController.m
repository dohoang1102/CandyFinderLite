//
//  HistoryViewController.m
//  CandyFinder
//
//  Created by Devin Moss on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HistoryViewController.h"
#import "globals.h"
#import "Web.h"
#import "Candy.h"
#import "UIDevice+IdentifierAddition.h"
#import "FlurryAnalytics.h"
#import "AppDelegate.h"


@implementation HistoryViewController

@synthesize listContent;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"historyview received memory warning");
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [FlurryAnalytics logPageView];
    
    self.listContent = [(AppDelegate *)[[UIApplication sharedApplication] delegate] readHistoryPlist];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.listContent = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [listContent count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"historyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if([indexPath row] % 2 == 0) {
        cell.backgroundView = [[UIView alloc] init ]; 
        cell.backgroundView.backgroundColor = LIGHT_BLUE;
    } else {
        cell.backgroundView = [[UIView alloc] init ]; 
        cell.backgroundView.backgroundColor = DARK_BLUE;
    }
    
    Candy *candy = [self.listContent objectAtIndex:indexPath.row];
    
    cell.textLabel.text = candy.title;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.detailTextLabel.text = candy.subtitle;
    UIImage *image = [UIImage imageNamed:@"milkyway.png"];
    cell.imageView.image = image;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    /*UILabel *mapLabel = [[UILabel alloc] initWithFrame:CGRectMake(245.0, 14.0, 50.0, 15.0)];
    mapLabel.tag = 1;
    mapLabel.text = [NSDateFormatter localizedStringFromDate:candy.created_at 
                                                   dateStyle:NSDateFormatterMediumStyle 
                                                   timeStyle:NSDateFormatterMediumStyle];
    mapLabel.font = [UIFont systemFontOfSize:14.0];
    mapLabel.textAlignment = UITextAlignmentRight;
    mapLabel.textColor = [UIColor blackColor];
    mapLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:mapLabel];*/
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    Candy *candy = [self.listContent objectAtIndex:indexPath.row];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *postString = [NSString stringWithFormat:SEARCH_PARAMETERS, candy.candy_id, [[UIDevice currentDevice] uniqueDeviceIdentifier], @"FROM_HISTORY", app.authenticity_token];
    
    [[Web sharedWeb] sendPostToURL:CREATE_SEARCH withBody:postString];
    
    //Dispatch event
    [FlurryAnalytics logEvent:SEARCH_HISTORY_TOUCHED];
    
    app.currentCandy = candy;
    
    UINavigationController *navController = (UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:2];
    if([navController.viewControllers count] > 0 && [navController.topViewController isKindOfClass:[AnnotationDetails class]]) {
        [navController popViewControllerAnimated:NO];
    }
    [self.tabBarController setSelectedIndex:2];
}

#pragma mark - Custom Actions
- (IBAction)clearHistory:(id)sender {
    if([(AppDelegate *)[[UIApplication sharedApplication] delegate] clearHistoryPlist]) {
        NSLog(@"Cleared history successfully");
        self.listContent = nil;
    } else {
        NSLog(@"Error clearing history");
    }
    
    [self.tableView reloadData];
}

@end

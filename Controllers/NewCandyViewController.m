//
//  NewCandyViewController.m
//  CandyFinder
//
//  Created by Devin Moss on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewCandyViewController.h"
#import "SBJson.h"
#import "AppDelegate.h"
#import "Web.h"
#import "FlurryAnalytics.h"
#import "ScannerOverlayView.h"

@implementation NewCandyViewController

#define CANDY_SAVED 200
#define ERROR       404

@synthesize sku, title, subtitle, fromSegue, responseData, skuTextField, brandTextField, typeTextField, imageView;

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


 //Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fromSegue = YES;
    
    isScanning = NO;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_AddBody_half.png"]];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Top Bar Blank.png"] forBarMetrics:UIBarMetricsDefault];
    
    responseData = [[NSMutableData alloc] init];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    if(fromSegue){
        [self scanButtonTapped];
    }
    
    self.fromSegue = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [FlurryAnalytics logPageView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Scan delegate
- (IBAction) scanButtonTapped
{
    isScanning = YES;
    
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    [reader setCameraOverlayView:[[ScannerOverlayView alloc] initWithFrame:SCANNER_OVERLAY_FRAME]];
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentModalViewController: reader
                            animated: YES];
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    if(isScanning) {
        // ADD: get the decode results
        id<NSFastEnumeration> results =
        [info objectForKey: ZBarReaderControllerResults];
        ZBarSymbol *symbol = nil;
        for(symbol in results)
            // EXAMPLE: just grab the first barcode
            break;
        
        if(symbol) {
            // EXAMPLE: do something useful with the barcode data
            self.sku = [NSString stringWithFormat:@"%@", symbol.data];
            skuTextField.text = sku;
            
            //imageView.image = [info objectForKey: UIImagePickerControllerOriginalImage];
            
            //Using NSURL send the message
            responseData = [NSMutableData data];
            
            //So the url will be http://candyfinder.net/search/sku/123456789012
            NSString *url = [NSString stringWithFormat:SEARCH_SKU, symbol.data];
            url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setHTTPMethod:@"POST"];
            
            [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            // ADD: dismiss the controller (NB dismiss from the *reader*!)
            [reader dismissModalViewControllerAnimated: YES];
            
            isScanning = NO;
        } else {
            //Display a label on the modal view controller saying "barcode not scanned.  try again"
        }
    } else {
        //Not scanning.  User is taking a picture of the candy for us
        imageView.image = [info valueForKey:UIImagePickerControllerOriginalImage];
        imageView.tag += 1;//Increment the tag so we know the user has taken a pic
    }
    
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController*)picker {
    [picker dismissModalViewControllerAnimated:YES];
    //[self.navigationController popViewControllerAnimated:YES];
    
    isScanning = NO;
}

- (IBAction)displayCamera:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentModalViewController:imagePicker animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera Available" message:@"Your device doesn't have a camera." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        [alert show];
    }
}

#pragma mark - Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

#pragma mark JSON Request section
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [responseData setLength:0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [responseData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//resultText.text = [NSString stringWithFormat:@"Connection failed: %@", [error description]];
    NSLog(@"There was an error");
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    if(![responseString isEqualToString:@"null"]) {
        NSDictionary *candyInfo = [responseString JSONValue];
        
        NSLog(@"%@", [candyInfo description]);
        
        if([candyInfo objectForKey:@"status"]) {
            //We are attempting to save the candy and got a response
            switch ([[candyInfo objectForKey:@"status"] intValue]) {
                case CANDY_SAVED:
                    [self candyDidSave];
                    break;
                case ERROR: {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Save Candy" message:[candyInfo objectForKey:@"message"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                    [alert dismissWithClickedButtonIndex:0 animated:YES];
                    [alert show];
                    break;
                }
                    
                default:
                    break;
            }
            return;
        }else {
            //User scanned a candy and we are searching for it. 
            //This is the response
            if([candyInfo count] > 0){
                //If candy was found, populate fields
                skuTextField.text = (NSString *)[candyInfo objectForKey:@"sku"];
                brandTextField.text = (NSString *)[candyInfo objectForKey:@"title"];
                typeTextField.text = (NSString *)[candyInfo objectForKey:@"subtitle"];
                
                //Display alert: We already have this candy in our database
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"We already have this candy in our database.\n Please find a new candy for us!" 
                                                               delegate:self 
                                                      cancelButtonTitle:@"Dismiss" 
                                                      otherButtonTitles:nil];
                [alert dismissWithClickedButtonIndex:0 animated:YES];
                [alert show];
            } else {
                //Candy not found
                //Prompt user to manually enter the remaining fields
            }
        }
    } else {
        //Candy not found
        //Prompt user to manually enter the remaining fields
    }
}

#pragma mark - Create New Candy
-(IBAction)saveButtonTapped:(id)sender{
    BOOL save = YES;
    
    if(sku) {
        NSString *type = typeTextField.text;
        NSString *brand = brandTextField.text;
        
        if(type && [type length] == 0) {
            save = NO;
            [typeTextField setBackgroundColor:BRIGHT_RED];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Field" message:@"Please enter a type." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alert dismissWithClickedButtonIndex:0 animated:YES];
            [alert show];
            return;
        }
        if(type && [brand length] == 0) {
            save = NO;
            [brandTextField setBackgroundColor:BRIGHT_RED];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Field" message:@"Please enter a brand." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alert dismissWithClickedButtonIndex:0 animated:YES];
            [alert show];
            return;
        }
        if(self.imageView.tag == 0) {
            save = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Take a Picture" message:@"Would you like to take a picture of the candy?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [alert dismissWithClickedButtonIndex:0 animated:YES];
            [alert show];
            return;
        }
        if(save) {
            [self displayActionSheet:self];
        } else {
            //User hasn't entered enough info
        }
    } else {
        [skuTextField setBackgroundColor:BRIGHT_RED];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please scan the new candy's barcode." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        [alert show];
    }
}

#pragma mark - Action Sheet
- (IBAction)displayActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Add %@ %@ to our database?", brandTextField.text, typeTextField.text]
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Yes", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            NSString *postString = [NSString stringWithFormat:CANDY_PARAMETERS, self.sku, brandTextField.text, typeTextField.text, app.authenticity_token];
            
            //[[Web sharedWeb] sendPostToURL:CREATE_CANDY withBody:postString];
            
            NSString *url = [NSString stringWithFormat:@"%@%@", CREATE_CANDY, postString];
            url = [[Web sharedWeb] encodeStringForURL:url];
            
            NSMutableURLRequest *request = [NSMutableURLRequest
                                            requestWithURL:[NSURL URLWithString:url]
                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:10];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            
            [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            NSString *candyName = [NSString stringWithFormat:@"%@ %@", brandTextField.text, typeTextField.text];
            [FlurryAnalytics logEvent:NEW_CANDY withParameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:candyName, self.sku, nil] forKeys:[NSArray arrayWithObjects:@"name", @"sku", nil]]];
            
            //[self userConfirmedSave];
            
            break;
        }
        default:
            break;
    }
}

- (void)candyDidSave {
    //This alert appears when a candy is successfully added to our database.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank You!" message:@"We will review your entry and approve it shortly." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            if([alertView.title isEqualToString:@"Thank You!"]) {
                //pop to parent view controller
                [self.navigationController popViewControllerAnimated:YES];
            }else if ([alertView.title isEqualToString:@"Take a Picture"]) {
                //User doesn't want to take a picture.  Just save the candy.
                [self displayActionSheet:self];
            }
            break;
        }
        case 1: {
            if([alertView.title isEqualToString:@"Take a Picture"]) {
                //User does want to take a picture before saving.  
                //Display camera picker
                [self displayCamera:self];
            }
        }
            
        default:
            break;
    }
}

- (IBAction)tempSave:(id)sender {
    self.sku = @"1234567890123";
    [self displayActionSheet:self];
}

@end

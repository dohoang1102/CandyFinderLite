//
//  NewCandyViewController.h
//  CandyFinder
//
//  Created by Devin Moss on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**
 This is used for adding a new candy to our database.
 The user is required to scan the candy's barcode so we can have the UPC (SKU)
 If the user can't scan a valid barcode, this view controller is dismissed.
 Once the barcode is scanned, the user must enter the name (ex: Skittles) and type (ex: Wild Berry) of the candy
 A photo of the barcode which they scanned is also displayed for the user.
 Once all these fields are entered, the user can tap the "save" button at the bottom of the screen.
 **/

#import <UIKit/UIKit.h>

@interface NewCandyViewController : UIViewController < ZBarReaderDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate > {
    //Container for the barcode sku/upc
    NSString *sku;
    
    //Container for the candy title/name (pulled from brandTextField)
    NSString *title;
    
    //container for the candy type (like wild berry) pulled from the typeTextField
    NSString *subtitle;
    
    //This is used for testing only.  It allows us to add candies without having to scan.
    //It will be removed in the live version.
    BOOL fromSegue;
    
    //Container for NSURLConnection responses
    NSMutableData *responseData;
    
    //An image of the barcode that the user scanned.
    UIImageView *imageView;
    
    BOOL isScanning;
}

@property (nonatomic, strong) NSString *sku;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic) BOOL fromSegue;
@property(nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) IBOutlet UITextField *skuTextField;
@property (nonatomic, strong) IBOutlet UITextField *brandTextField;
@property (nonatomic, strong) IBOutlet UITextField *typeTextField;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

//Displays the barcode scanner modally
- (IBAction) scanButtonTapped;

//Checks to ensure the textfields are populated, then displays the action sheet
-(IBAction)saveButtonTapped:(id)sender;

//Displays confirmation form
//If user clicks ok, sends a request to add a candy then dismisses self
- (IBAction)displayActionSheet:(id)sender;

- (IBAction)displayCamera:(id)sender;

- (IBAction)tempSave:(id)sender;


@end

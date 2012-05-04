//
//  ImagePickerViewController.h
//  CandyFinder
//
//  Created by Devin Moss on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImagePickerViewControllerDelegate;

@interface ImagePickerViewController : UIViewController < UINavigationControllerDelegate, UIImagePickerControllerDelegate > {
    UIImagePickerController *imagePickerController;
    
    id <ImagePickerViewControllerDelegate> delegate;
}

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) id <ImagePickerViewControllerDelegate> delegate;
@property (nonatomic, strong) UIBarButtonItem *cameraButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;

@end

@protocol ImagePickerViewControllerDelegate

- (void)didTakePicture:(UIImage *)picture withPicker:(ImagePickerViewController *)picker;
- (void)didFinishWithCamera;

@end
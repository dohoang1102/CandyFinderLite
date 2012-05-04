//
//  ScannerOverlayView.m
//  CandyFinder
//
//  Created by Devin Moss on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScannerOverlayView.h"

@implementation ScannerOverlayView

- (void)baseInit {
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanner_overlay_gray_box.png"]];
    imageView.alpha = 0.3;
    imageView.frame = self.frame;
    [self addSubview:imageView];
    
    label = [[UILabel alloc] init];
    label.text = @"Scan the barcode in the area below";
    label.frame = CGRectMake(20, 20, 280, 82);
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:17.0];
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.textColor = [UIColor colorWithRed:0.0 green:0.588 blue:1.0 alpha:1.0];
    label.backgroundColor = [UIColor clearColor];
    [self addSubview:label];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self baseInit];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

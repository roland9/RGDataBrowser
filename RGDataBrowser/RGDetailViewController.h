//
//  RGDetailViewController.h
//  RGDataBrowser
//
//  Created by RolandG on 11/02/2014.
//  Copyright (c) 2014 mapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RGDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end

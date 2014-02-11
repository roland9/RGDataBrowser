//
//  RGMasterViewController.h
//  RGDataBrowser
//
//  Created by RolandG on 11/02/2014.
//  Copyright (c) 2014 mapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RGDetailViewController;

#import <CoreData/CoreData.h>

@interface RGMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) RGDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

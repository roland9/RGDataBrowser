//
//  RGCollectionViewController.h
//  RGDataBrowser
//
//  Created by RolandG on 26/02/2014.
//  Copyright (c) 2014 mapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RGBaseCVC.h"

@interface RGCollectionViewController : RGBaseCVC <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, copy)   NSString   *parentId;
@property (nonatomic, copy)   NSString   *levelDescription;

@end

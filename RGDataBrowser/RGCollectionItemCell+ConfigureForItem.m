//
//  RGCollectionItemCell+ConfigureForItem.m
//  RGDataBrowser
//
//  Created by RolandG on 26/02/2014.
//  Copyright (c) 2014 mapps. All rights reserved.
//

#import "RGCollectionItemCell+ConfigureForItem.h"
#import "RGObject.h"
#import <UIImageView+AFNetworking.h>
#import "DDLog.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_WARN;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif


@implementation RGCollectionItemCell (ConfigureForItem)

- (void)configureForItem:(RGObject *)item {
    DDLogInfo(@"%s", __FUNCTION__);
    
    self.itemTitleLabel.text = item.itemDescription;
    BOOL doesShowDisclosureIndicator = NO;
    
    if ([item.numberOfSubentries integerValue] > 0) {
        self.subentriesLabel.text = [item.numberOfSubentries stringValue];
        doesShowDisclosureIndicator = YES;
    } else {
        self.subentriesLabel.text = @"";
    }
    
    if ([item.imageThumbnail length] > 0) {
        [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:item.imageThumbnail] placeholderImage:nil];
    }
    
    if ([item.detailHTML length] > 0) {
        doesShowDisclosureIndicator = YES;
    }
    
    if ([item.articleLink length] > 0) {
        doesShowDisclosureIndicator = YES;
    }
    
    if (doesShowDisclosureIndicator) {
//        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        self.selectionStyle = UITableViewCellSelectionStyleGray;
    } else {
//        self.accessoryType = UITableViewCellAccessoryNone;
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

@end

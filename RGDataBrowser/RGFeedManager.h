//
//  RGFeedManager.h
//  RGDataBrowser
//
//  Created by RolandG on 06/09/2013.
//  Copyright (c) 2013 RG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RGChannel, RGObject;


@interface RGFeedManager : NSObject <NSXMLParserDelegate>

@property (nonatomic, readonly, strong) NSArray *configDataEntries;

- (NSArray *)dataEntries;
- (NSArray *)itemsWithParentId:(NSString *)theParentId;
- (NSArray *)itemsWithSearchString:(NSString *)theSearchString parentId:(NSString *)theParentId;
- (RGObject *)objectWithItemId:(NSString *)theItemId;

- (void)loadDataURLString:(NSString *)theURLString;
- (void)loadConfigDataURLString:(NSString *)theURLString;
- (void)loadDataFileString:(NSString *)theFileString extension:(NSString *)theExtension;

- (void)startNetworkCallsOnce;

+ (id)sharedRGFeedManager;

@end

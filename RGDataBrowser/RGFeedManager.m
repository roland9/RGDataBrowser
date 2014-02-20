//
//  RGFeedManager.m
//  RGDataBrowser
//
//  Created by RolandG on 06/09/2013.
//  Copyright (c) 2013 RG. All rights reserved.
//

#import "RGFeedManager.h"
#import <AFNetworking/AFNetworking.h>
#import "RGHTTPSessionManager.h"
#import "RGObject.h"
#import "RGConfigData.h"
#import <CoreData+MagicalRecord.h>
#import "DDLog.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_INFO;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif


@interface RGFeedManager()
@end


@implementation RGFeedManager


////////////////////////////////////////////////////////////////////
# pragma mark - Public

- (NSArray *)dataEntries {
    return [RGObject MR_findAll];
}


- (NSArray *)itemsWithParentId:(NSString *)theParentId {
    DDLogInfo(@"%s: parentId=%@", __FUNCTION__, theParentId);

    return [self.dataEntries filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"parentId = %@", theParentId]];
}


- (NSArray *)itemsWithSearchString:(NSString *)theSearchString parentId:(NSString *)theParentId {
    DDLogInfo(@"%s: searchString=%@  parentId=%@", __FUNCTION__, theSearchString, theParentId);
    
    if ((theSearchString == nil) || [theSearchString length] == 0)
        return [RGObject MR_findAll];
    
    // Search all entries in DB for items whose itemDescription matches searchString
    NSArray *searchResult;
    if (theParentId && ![theParentId isEqualToString:@"0"]) {
        searchResult = [RGObject MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"itemDescription contains[cd] %@ AND parentId = %@", theSearchString, theParentId]];
    } else
        searchResult = [RGObject MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"itemDescription contains[cd] %@", theSearchString]];
    
    DDLogVerbose(@"%s: new search results=%@", __FUNCTION__, searchResult);
    
    return searchResult;
}


- (RGObject *)objectWithItemId:(NSString *)theItemId {
    DDLogInfo(@"%s: itemId=%@", __FUNCTION__, theItemId);

    return [RGObject MR_findFirstByAttribute:@"itemId" withValue:theItemId];
}


- (void)loadDataURLString:(NSString *)theURLString {
    DDLogInfo(@"%s: url=%@", __FUNCTION__, theURLString);

    [[RGHTTPSessionManager manager] GET:theURLString parameters:NULL success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *error;
        
        if (!error) {
            NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"inconsistent");
            NSDictionary *json = (NSDictionary *)responseObject;

            NSArray *entries = json[@"feed"][@"entry"];
            NSAssert([entries isKindOfClass:[NSArray class]], @"expected array");
            DDLogInfo(@"%s: count=%lu", __FUNCTION__, (unsigned long)[entries count]);
            DDLogVerbose(@"%s: entries=%@", __FUNCTION__, entries);
            
            // find the number of subentries; store in a mutable dictionary so we can access it before creating the object in Core Data
            NSDictionary *numberOfSubentriesDict = [self getNumberOfSubentries:entries];
            
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

                // first, clear out previous entries (maybe later we can merge them)
                [RGObject MR_deleteAllMatchingPredicate:[NSPredicate predicateWithValue:YES]];
                
                [entries enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                    NSAssert([dict isKindOfClass:[NSDictionary class]], @"inconsistent");

                    RGObject *object = [RGObject objectWithItemId:dict[@"gsx$itemid"][@"$t"] inContext:localContext];
                    object.parentId = dict[@"gsx$parentid"][@"$t"];
                    object.itemDescription = dict[@"gsx$itemdescription"][@"$t"];
                    object.nextLevel = dict[@"gsx$nextlevel"][@"$t"];
                    object.imageFull = dict[@"gsx$imagefull"][@"$t"];
                    object.imageThumbnail = dict[@"gsx$imagethumbnail"][@"$t"];
                    object.articleLink = dict[@"gsx$articlelink"][@"$t"];
                    object.detailHTML = dict[@"gsx$detailhtml"][@"$t"];
                    object.numberOfSubentries = numberOfSubentriesDict[object.itemId];
                }];
                
            }];
            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
            // todoRG - error handling?
    }];
}


- (void)loadDataFileString:(NSString *)theFileString extension:(NSString *)theExtension {
    DDLogInfo(@"%s: url=%@", __FUNCTION__, theFileString);
    
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:theFileString withExtension:theExtension];
    
    NSError *error;
    NSData *fileData = [NSData dataWithContentsOfURL:fileURL options:NSDataReadingUncached error:&error];
    id JSONObject = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingAllowFragments error:&error];
    
    if (!error) {
        
        NSAssert([JSONObject isKindOfClass:[NSDictionary class]], @"inconsistent");
        NSDictionary *json = (NSDictionary *)JSONObject;
        
        NSArray *entries = json[@"feed"][@"entry"];
        NSAssert([entries isKindOfClass:[NSArray class]], @"expected array");
        DDLogInfo(@"%s: count=%lu", __FUNCTION__, (unsigned long)[entries count]);
        DDLogVerbose(@"%s: entries=%@", __FUNCTION__, entries);
        
        NSDictionary *numberOfSubentriesDict = [self getNumberOfSubentries:entries];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            
            [RGObject MR_deleteAllMatchingPredicate:[NSPredicate predicateWithValue:YES]];
            
            [entries enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                NSAssert([dict isKindOfClass:[NSDictionary class]], @"inconsistent");
                
                RGObject *object = [RGObject objectWithItemId:dict[@"gsx$itemid"][@"$t"] inContext:localContext];
                object.parentId = dict[@"gsx$parentid"][@"$t"];
                object.itemDescription = dict[@"gsx$itemdescription"][@"$t"];
                object.nextLevel = dict[@"gsx$nextlevel"][@"$t"];
                object.imageFull = dict[@"gsx$imagefull"][@"$t"];
                object.imageThumbnail = dict[@"gsx$imagethumbnail"][@"$t"];
                object.articleLink = dict[@"gsx$articlelink"][@"$t"];
                object.detailHTML = dict[@"gsx$detailhtml"][@"$t"];
                object.numberOfSubentries = numberOfSubentriesDict[object.itemId];
            }];
        }];
    }
}


- (void)loadConfigDataURLString:(NSString *)theURLString {
    DDLogInfo(@"%s: url=%@", __FUNCTION__, theURLString);
    
    [[RGHTTPSessionManager manager] GET:theURLString parameters:NULL success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *error;
        
        if (!error) {
            NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"inconsistent");
            NSDictionary *json = (NSDictionary *)responseObject;

            NSArray *entries = json[@"feed"][@"entry"];
            NSAssert([entries isKindOfClass:[NSArray class]], @"expected array");
            NSMutableArray __block *configEntries = [NSMutableArray array];
            
            [entries enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                NSAssert([dict isKindOfClass:[NSDictionary class]], @"inconsistent");
                
                RGConfigData *config = [[RGConfigData alloc] init];
                config.configItem = dict[@"gsx$setting"][@"$t"];
                config.configValue = dict[@"gsx$value"][@"$t"];
                
                [configEntries addObject:config];
            }];
            
            DDLogVerbose(@"%s: itemEntries=%@", __FUNCTION__, configEntries);
            
            self.configDataEntries = [NSArray arrayWithArray:configEntries];
            
        } else
            self.configDataEntries = nil;
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // todoRG - error handling?
        self.configDataEntries = nil;
        
    }];
}


/////////////////////////////////////////////////////////////////////////////////////////////
# pragma mark - Private

- (NSDictionary *)getNumberOfSubentries:(NSArray *)entries {
    __block NSMutableDictionary *numberOfSubentriesDict = [NSMutableDictionary dictionary];
    
    [entries enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        NSAssert([dict isKindOfClass:[NSDictionary class]], @"inconsistent");
        NSArray *subEntries = [entries filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"gsx$parentid"][@"$t"] isEqualToString:dict[@"gsx$itemid"][@"$t"]];
        }]];
        numberOfSubentriesDict[dict[@"gsx$itemid"][@"$t"]] = @([subEntries count]);
    }];
    
    return numberOfSubentriesDict;
}


//- (void)initDataSample:(NSString *)fileName type:(NSString *)type
//{
//    NSString *inputFile = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
//    NSAssert(inputFile, @"could not find RSS input file");
//    //    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:inputFile];
//    NSData *inputData = [NSData dataWithContentsOfFile:inputFile];
//    
//    NSError *error = nil;
//    FPFeed *feed = [FPParser parsedFeedWithData:inputData error:&error];
//    
//    NSAssert(feed, @"feed empty");
//    
//    __block RGChannel *appFeed = nil;
//    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
//        
//        NSString *feedTitle = [feed title];
//        appFeed = [RGChannel feedWithName:feedTitle inContext:localContext];
//        [appFeed MR_importValuesForKeysWithObject:feed];
//        
//    }];
//}


//- (void)createDummyChannel {
//    RGChannel *newChannel = [RGChannel MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
//
//    newChannel.feedDescription = @"dummy channel";
//    newChannel.language = @"English (IE)";
//    newChannel.lastBuildDate = [NSDate date];
//    newChannel.link = @"http://www.spiegel.de/schlagzeilen/tops/index.rss";
//    newChannel.pubDate = [NSDate date];
//    newChannel.title = @"My Dummy Channel";
//
//    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
//}


/////////////////////////////////////////////////////////////////////////////////////////////
# pragma mark - Setter

- (void)setConfigDataEntries:(NSArray *)configDataEntries {
    [self willChangeValueForKey:@"configDataEntries"];
    _configDataEntries = configDataEntries;
    [self didChangeValueForKey:@"configDataEntries"];
}


- (id) init {
    self = [super init];
    if (self) {        
    }
    return self;
}




+ (id)sharedRGFeedManager
{
    static dispatch_once_t onceQueue;
    static RGFeedManager *rGFeedManager = nil;
    
    dispatch_once(&onceQueue, ^{ rGFeedManager = [[self alloc] init]; });
    return rGFeedManager;
}

@end

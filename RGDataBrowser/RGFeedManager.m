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
#import <DDLogMacros.h>

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
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
            
#warning do we really have to clear it out here? that breaks the tests...
//            [RGObject MR_deleteAllMatchingPredicate:[NSPredicate predicateWithValue:YES]];
            
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

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
                }];
                
            } completion:^(BOOL success, NSError *error) {
                
                [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                    [self updateSubentriesWithContext:localContext];
                }];
            }];

            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
            // todoRG - error handling?
    }];
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

//- (void)createTestEnvironment {
//    DDLogInfo(@"%s", __FUNCTION__);
//
//    [self initDataSample:@"rss2sample.xml" type:@"rss"];
//    [self initDataSample:@"spiegelIndex" type:@"rss"];
//}


/////////////////////////////////////////////////////////////////////////////////////////////
# pragma mark - Private

- (void)updateSubentriesWithContext:(NSManagedObjectContext *)context {
    
    [[RGObject MR_findAll] enumerateObjectsUsingBlock:^(RGObject *obj, NSUInteger idx, BOOL *stop) {
#warning optimize - check if been calculated before
        RGObject *object = [RGObject objectWithItemId:obj.itemId inContext:context];
        object.numberOfSubentries = [RGObject MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"parentId = %@", obj.itemId]];
    }];
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
        [self loadDataURLString:@"0Apmsn6hlyPHudHUxSHJ1YzhPVjV4VEJTTkl6aGhnclE/od6/public/values?alt=json"];
        [self loadConfigDataURLString:@"0Apmsn6hlyPHudHUxSHJ1YzhPVjV4VEJTTkl6aGhnclE/od7/public/values?alt=json"];
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

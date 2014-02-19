//
//  RGSampleSpec.m
//  RGDataBrowser
//
//  Created by Roland on 13/02/2014.
//  Copyright (c) 2014 mapps. All rights reserved.
//
#import "Kiwi.h"
#import "RGFeedManager.h"
#import "RGObject.h"

SPEC_BEGIN(GoogleSpreadsheetTests)

describe(@"Load Test Spreadsheet locally", ^{
    
//    beforeAll(^{
#warning pending - need to avoid setting up the core data stack on disk - see AppDelegate
////        [MagicalRecord setupCoreDataStackWithInMemoryStore];
//    });
    
    it(@"data loaded", ^{
        [[[[RGFeedManager sharedRGFeedManager] dataEntries] should] haveCountOf:53];
        
        [[[[RGFeedManager sharedRGFeedManager] objectWithItemId:@"1"] should] haveValue:@"Asia" forKeyPath:@"itemDescription"];
        [[[[RGFeedManager sharedRGFeedManager] objectWithItemId:@"1"] should] haveValue:@"0" forKeyPath:@"parentId"];
        [[[[RGFeedManager sharedRGFeedManager] objectWithItemId:@"1"] should] haveValue:@"Countries" forKeyPath:@"nextLevel"];
        [[[[RGFeedManager sharedRGFeedManager] objectWithItemId:@"1"] should] haveValue:@"" forKeyPath:@"imageFull"];
        [[[[RGFeedManager sharedRGFeedManager] objectWithItemId:@"1"] should] haveValue:@"" forKeyPath:@"imageThumbnail"];
        [[[[RGFeedManager sharedRGFeedManager] objectWithItemId:@"1"] should] haveValue:@"" forKeyPath:@"detailHTML"];
        [[[[RGFeedManager sharedRGFeedManager] objectWithItemId:@"1"] should] haveValue:@"http://en.wikipedia.org/wiki/Asia" forKeyPath:@"articleLink"];
        [[[[RGFeedManager sharedRGFeedManager] objectWithItemId:@"1"] should] haveValue:@5 forKeyPath:@"numberOfSubentries"];
    });
});


//describe(@"Load Test Spreadsheet via network", ^{
//
////    beforeAll(^{
////        [[RGFeedManager sharedRGFeedManager] loadDataFileString:@"CountriesFlags" extension:@"json"];
////    });
//    
//        it(@"data loaded", ^{
//            [[[[RGFeedManager sharedRGFeedManager] dataEntries] should] haveCountOf:53];
//            
//            [[[[RGFeedManager sharedRGFeedManager] objectWithItemId:@"1"] should] haveValue:@"Asia" forKeyPath:@"itemDescription"];
//            [[[[RGFeedManager sharedRGFeedManager] objectWithItemId:@"1"] should] haveValue:@"0" forKeyPath:@"parentId"];
//            [[[[RGFeedManager sharedRGFeedManager] objectWithItemId:@"1"] should] haveValue:@"Countries" forKeyPath:@"nextLevel"];
//            [[[[RGFeedManager sharedRGFeedManager] objectWithItemId:@"1"] should] haveValue:@"" forKeyPath:@"imageFull"];
//            [[[[RGFeedManager sharedRGFeedManager] objectWithItemId:@"1"] should] haveValue:@"" forKeyPath:@"imageThumbnail"];
//            [[[[RGFeedManager sharedRGFeedManager] objectWithItemId:@"1"] should] haveValue:@"" forKeyPath:@"detailHTML"];
//            [[[[RGFeedManager sharedRGFeedManager] objectWithItemId:@"1"] should] haveValue:@"http://en.wikipedia.org/wiki/Asia" forKeyPath:@"articleLink"];
//            [[[[RGFeedManager sharedRGFeedManager] objectWithItemId:@"1"] should] haveValue:@5 forKeyPath:@"numberOfSubentries"];
//
//        
//        //        RGObject *obj2 = [RGObject MR_createEntity];
//        //        obj2.itemId = @"10";
//        //        obj2.parentId = @"1";
//        //        obj2.itemDescription = @"Indonesia";
//        //        obj2.nextLevel = @"Cities";
//        //        obj2.imageFull = @"";
//        //        obj2.imageThumbnail = @"";
//        //        obj2.detailHTML = @"";
//        //        obj2.articleLink = @"http://en.wikipedia.org/wiki/Indonesia";
//        //        obj2.numberOfSubentries = @0;
//        //
//        //        RGObject *obj3 = [RGObject MR_createEntity];
//        //        obj3.itemId = @"41";
//        //        obj3.parentId = @"6";
//        //        obj3.itemDescription = @"Kenya";
//        //        obj3.nextLevel = @"Cities";
//        //        obj3.imageFull = @"";
//        //        obj3.imageThumbnail = @"";
//        //        obj3.detailHTML = @"";
//        //        obj3.articleLink = @"http://en.wikipedia.org/wiki/Kenya";
//        //        obj3.numberOfSubentries = @0;
//        //
//        //        RGObject *obj4 = [RGObject MR_createEntity];
//        //        obj4.itemId = @"47";
//        //        obj4.parentId = @"12";
//        //        obj4.itemDescription = @"Frankfurt am Main";
//        //        obj4.nextLevel = @"";
//        //        obj4.imageFull = @"";
//        //        obj4.imageThumbnail = @"";
//        //        obj4.detailHTML = @"<h1>Frankfurt detail HTML</h1>this is the body text";
//        //        obj4.articleLink = @"http://en.wikipedia.org/wiki/Frankfurt am Main";
//        //        obj4.numberOfSubentries = @0;
//        //
//        //        RGObject *obj5 = [RGObject MR_createEntity];
//        //        obj5.itemId = @"7";
//        //        obj5.parentId = @"1";
//        //        obj5.itemDescription = @"China";
//        //        obj5.nextLevel = @"Cities";
//        //        obj5.imageFull = @"http://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Flag_of_the_People%27s_Republic_of_China.svg/1000px-Flag_of_the_People%27s_Republic_of_China.svg.png";
//        //        obj5.imageThumbnail = @"http://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Flag_of_the_People%27s_Republic_of_China.svg/200px-Flag_of_the_People%27s_Republic_of_China.svg.png";
//        //        obj5.detailHTML = @"";
//        //        obj5.articleLink = @"http://en.wikipedia.org/wiki/China";
//        //        obj5.numberOfSubentries = @0;
//        
//#warning that doesn't work anymore with CD -> because we create the object to test against in the context!!!
//        
//        //        [[expectFutureValue([[RGFeedManager sharedRGFeedManager] dataEntries]) shouldEventuallyBeforeTimingOutAfter(5)]
//        //         containObjectsInArray:@[obj1
//        //                                 //, obj2, obj3, obj4, obj5
//        //                                 ]];
//        
//    });
//});

SPEC_END
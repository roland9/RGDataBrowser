//
//  RGCollectionViewController.m
//  RGDataBrowser
//
//  Created by RolandG on 26/02/2014.
//  Copyright (c) 2014 mapps. All rights reserved.
//

#import "RGCollectionViewController.h"
#import "RGDetailViewController.h"
#import "RGFeedManager.h"
#import "RGCollectionItemCell.h"
#import "RGCollectionItemCell+ConfigureForItem.h"
#import "RGObject.h"
#import "RGConfigData.h"
#import "RGSearchDataSource.h"
#import "DDLog.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_INFO;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif


static NSString * const ItemCellIdentifier = @"ItemCell";




@interface RGCollectionViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) RGDetailViewController *detailViewController;
@property (nonatomic, strong) RGSearchDataSource *searchDataSource;

@end


@implementation RGCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailViewController = (RGDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.splitViewController.delegate = self.detailViewController;
    
    [self setupTableView];
    
    [[RGFeedManager sharedRGFeedManager] startNetworkCallsOnce];
}

- (void)dealloc {
    [[RGFeedManager sharedRGFeedManager] removeObserver:self forKeyPath:@"configDataEntries" context:nil];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    self.parentId = @"0";
    
    // because this is the first call and calls init, it also initializes the Core Data stack
    [[RGFeedManager sharedRGFeedManager] addObserver:self forKeyPath:@"configDataEntries" options:NSKeyValueObservingOptionNew context:nil];
}


////////////////////////////////////////////////////////////////////
# pragma mark - SearchDisplayDelegate

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    DDLogInfo(@"%s", __FUNCTION__);
    
}

//- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
//}

//- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
//}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    DDLogInfo(@"%s", __FUNCTION__);
    
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	// Update the filtered array based on the search text and scope.
    self.searchDataSource.searchResults = [[RGFeedManager sharedRGFeedManager] itemsWithSearchString:searchString parentId:self.parentId];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


/////////////////////////////////////////////////////////////////////////////////////////////
# pragma mark - Private

// KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    DDLogInfo(@"%s: keyPath=%@", __FUNCTION__, keyPath);
    
    if ([keyPath isEqualToString:@"configDataEntries"]) {
        DDLogInfo(@"%s", __FUNCTION__);
        
        NSArray *initialLevelConfig = [[[RGFeedManager sharedRGFeedManager] configDataEntries] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = %@", @"configItem", @"InitialLevel"]];
        if ([initialLevelConfig count] > 0)
            self.navigationItem.title = ((RGConfigData *)initialLevelConfig[0]).configValue;
    }
}


- (void)setupTableView {
    [self.collectionView registerNib:[RGCollectionItemCell nib] forCellWithReuseIdentifier:[self cellIdentifier]];
    
    // kick off data loading
    [RGFeedManager sharedRGFeedManager];
    
    // for the initial level, get the description from the config sheet in the database (use KVO to find out when it's available); for others, it's set by the parent table view controller
    NSString *myTitle = self.levelDescription;
    self.navigationItem.title = myTitle;
    
    self.searchDataSource = [[RGSearchDataSource alloc] init];
    self.searchDisplayController.searchResultsDataSource = self.searchDataSource;
    //    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
}


/////////////////////////////////////////////////////////////////////////////////////////////
# pragma mark - RGBaseFRCProtocol - Fetched results controller & Table View

- (NSArray *)sortDescriptors {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemDescription" ascending:YES];
    return @[sortDescriptor];
}

- (NSString *)entityName {
    return @"RGObject";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSAssert([object isKindOfClass:[RGObject class]], @"expected RGObject");
    NSAssert([cell isKindOfClass:[RGCollectionItemCell class]], @"expected RGItemCell");
    
    [(RGCollectionItemCell *)cell configureForItem:(RGObject *)object];
}

- (NSString *)cellIdentifier {
    return ItemCellIdentifier;
}

- (NSPredicate *)predicate {
    return [NSPredicate predicateWithFormat:@"parentId = %@", self.parentId];
}


#pragma mark UITableViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    RGObject *obj;
    
    obj = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([obj.numberOfSubentries unsignedIntegerValue] > 0) {
        // we have usbentries -> navigate to next level list
        RGCollectionViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"RGCollectionViewController"];
        NSAssert([cvc isKindOfClass:[RGCollectionViewController class]], @"expected TVC");
        
        cvc.parentId = obj.itemId;
        cvc.levelDescription = obj.nextLevel;
        
        [self.navigationController pushViewController:cvc animated:YES];
        
    } else if ([obj.numberOfSubentries unsignedIntegerValue] == 0  &&
               [obj.detailHTML length] > 0) {
        
        // we don't have subentries, but we have detailHTML info -> show html in detailVC
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self.detailViewController setDetailItem:@{@"title": obj.itemDescription, @"html": obj.detailHTML}];
            
        } else {
            RGDetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RGDetailViewController"];
            NSAssert([detailVC isKindOfClass:[RGDetailViewController class]], @"inconsistent storyboard");
            
            [detailVC setDetailItem:@{@"title": obj.itemDescription, @"html": obj.detailHTML}];
            [self.navigationController pushViewController:detailVC animated:YES];
        }
        
    } else if ([obj.articleLink length] > 0) {
        
        // we don't have subentries or detailHTML, but we have a hyperlink to an article
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self.detailViewController setDetailItem:@{@"title": obj.itemDescription, @"link": obj.articleLink}];
            
        } else {
            RGDetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RGDetailViewController"];
            NSAssert([detailVC isKindOfClass:[RGDetailViewController class]], @"inconsistent storyboard");
            
            [detailVC setDetailItem:@{@"title": obj.itemDescription, @"link": obj.articleLink}];
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    }
}

@end

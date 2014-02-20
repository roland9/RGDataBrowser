//
//  RGSearchDataSource.m
//  RGDataBrowser
//
//  Created by Roland on 20/02/2014.
//  Copyright (c) 2014 mapps. All rights reserved.
//

#import "RGSearchDataSource.h"
#import "RGObject.h"


@implementation RGSearchDataSource


////////////////////////////////////////////////////////////////////
# pragma mark - Search Bar - DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger counter = [self.searchResults count];
    return counter;
}


static NSString *kSearchCellID = @"SearchCellIdentifier";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dequeue a cell from self's table view.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchCellID];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSearchCellID];
    
    RGObject *object = self.searchResults[indexPath.row];
    NSAssert([object isKindOfClass:[RGObject class]], @"inconsistent");
	cell.textLabel.text = object.itemDescription;
    
    return cell;
}

@end

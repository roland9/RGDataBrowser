//
//  RGCollectionItemCell.h
//  RGDataBrowser
//
//  Created by RolandG on 26/02/2014.
//  Copyright (c) 2014 mapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RGCollectionItemCell : UICollectionViewCell

+ (UINib *)nib;

@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subentriesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@end

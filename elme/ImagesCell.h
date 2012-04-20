//
//  ImagesCell.h
//  elme
//
//  Created by Sven A. Schmidt on 17.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImagesView;

@interface ImagesCell : UITableViewCell

@property (strong, nonatomic) NSArray *detailItem;

@property (weak, nonatomic) IBOutlet UIView *noImagesView;
@property (weak, nonatomic) IBOutlet ImagesView *imagesView;

- (CGFloat)rowHeight;

@end

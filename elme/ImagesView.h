//
//  ImagesView.h
//  elme
//
//  Created by Sven A. Schmidt on 20.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagesView : UIScrollView

@property (strong, nonatomic) NSArray *detailItem;
@property (assign) CGFloat imageAspectRatio;
@property (assign) CGFloat padding;
@property (assign) NSUInteger imagesPerRow;

@end

//
//  ImagesView.h
//  elme
//
//  Created by Sven A. Schmidt on 20.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum ImagesViewGrowthDirection {
  kVertical,
  kHorizontal
} ImagesViewGrowthDirection;


@interface ImagesView : UIScrollView

@property (strong, nonatomic) NSArray *detailItem;
@property (assign) ImagesViewGrowthDirection growthDirection;
@property (assign) CGFloat imageAspectRatio;
@property (assign) CGFloat padding;
@property (assign) NSUInteger imagesPerFixedDimension;
@property (assign) BOOL allowsSelection;
@property (strong, nonatomic) UIColor *selectionColor;
@property (assign) CGFloat selectionBorderWidth;

@property (readonly) UIImage *selectedImage;
@property (readonly) NSUInteger selectedIndex;

@end

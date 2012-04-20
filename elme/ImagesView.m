//
//  ImagesView.m
//  elme
//
//  Created by Sven A. Schmidt on 20.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "ImagesView.h"

@implementation ImagesView

@synthesize detailItem = _detailItem;
@synthesize growthDirection = _growthDirection;
@synthesize imageAspectRatio = _imageAspectRatio;
@synthesize imagesPerFixedDimension = _imagesPerFixedDimension;
@synthesize padding = _padding;


#pragma mark - Managing the detail item


- (void)setDetailItem:(id)newDetailItem
{
  if (_detailItem != newDetailItem) {
    _detailItem = newDetailItem;
    [self configureView];
  }
}


- (void)configureView {
  NSArray *images = self.detailItem;
  
  CGFloat totalSpace = self.growthDirection == kVertical ? self.frame.size.width : self.frame.size.height;
  CGFloat totalPadding = (self.imagesPerFixedDimension -1) * self.padding;
  int fixedDimensionSize = (totalSpace - totalPadding) / self.imagesPerFixedDimension;
  int imageWidth, imageHeight;
  if (self.growthDirection == kVertical) {
    imageWidth = fixedDimensionSize;
    imageHeight = round(imageWidth / self.imageAspectRatio);
  } else {
    imageHeight = fixedDimensionSize;
    imageWidth = round(imageHeight * self.imageAspectRatio);
  }
  int colWidth = imageWidth + self.padding;
  int rowHeight = imageHeight + self.padding;
  
  // lay out images
  {
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [obj removeFromSuperview];
    }];
    for (int i = 0; i < images.count; ++i) {
      UIImage *image = [images objectAtIndex:i];
      UIImageView *view = [[UIImageView alloc] initWithImage:image];
      //    view.userInteractionEnabled = YES;
      //    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)]];
      
      int col, row;
      if (self.growthDirection == kVertical) {
        col = i % self.imagesPerFixedDimension;
        row = i / self.imagesPerFixedDimension;
      } else {
        col = i / self.imagesPerFixedDimension;
        row = i % self.imagesPerFixedDimension;
      }
      view.frame = CGRectMake(col*colWidth, row*rowHeight, imageWidth, imageHeight);
      [self addSubview:view];
    }
  }
  
  // set content size
  {
    CGSize contentSize;
    int nImagesInGrowthDirection = ceil(images.count / (float)self.imagesPerFixedDimension);
    totalPadding = (nImagesInGrowthDirection -1) * self.padding;
    if (self.growthDirection == kVertical) {
      contentSize = CGSizeMake(totalSpace,
                               nImagesInGrowthDirection * imageHeight + totalPadding);
    } else {
      contentSize = CGSizeMake(nImagesInGrowthDirection * imageWidth + totalPadding,
                               totalSpace);
    }
    self.contentSize = contentSize;
  }
}


- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // set defaults
    self.growthDirection = kVertical;
    self.imageAspectRatio = 4./3.;
    self.padding = 4;
    self.imagesPerFixedDimension = 4;
  }
  return self;
}


@end

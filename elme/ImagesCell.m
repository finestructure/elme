//
//  ImagesCell.m
//  elme
//
//  Created by Sven A. Schmidt on 17.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "ImagesCell.h"

#import "ImagesView.h"

@implementation ImagesCell

@synthesize detailItem = _detailItem;
@synthesize noImagesView = _noImagesView;
@synthesize imagesView = _imagesView;


#pragma mark - Managing the detail item


- (void)setDetailItem:(id)newDetailItem
{
  if (_detailItem != newDetailItem) {
    _detailItem = newDetailItem;
    [self configureView];
  }
}


- (void)configureView {
  if (self.detailItem.count == 0) {
    self.noImagesView.hidden = NO;
    self.imagesView.hidden = YES;
  } else {
    self.noImagesView.hidden = YES;
    self.imagesView.hidden = NO;
    self.imagesView.growthDirection = kHorizontal;
    self.imagesView.imagesPerFixedDimension = 1;
    self.imagesView.imageAspectRatio = 4./3.;
    self.imagesView.padding = 4;
    self.imagesView.detailItem = self.detailItem;
  }
}


@end

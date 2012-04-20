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
@synthesize imageAspectRatio = _imageAspectRatio;
@synthesize imagesPerRow = _imagesPerRow;
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
  
  CGFloat totalWidth = self.frame.size.width;
  CGFloat totalHorizontalPadding = (self.imagesPerRow -1) * self.padding;
  int imageWidth = (totalWidth - totalHorizontalPadding) / self.imagesPerRow;
  int imageHeight = round(imageWidth / self.imageAspectRatio);
  int colWidth = imageWidth + self.padding;
  int rowHeight = imageHeight + self.padding;
  
  for (int i = 0; i < images.count; ++i) {
    UIImage *image = [images objectAtIndex:i];
    UIImageView *view = [[UIImageView alloc] initWithImage:image];
    //    view.userInteractionEnabled = YES;
    //    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)]];
    
    int col = i % self.imagesPerRow;
    int row = i / self.imagesPerRow;
    view.frame = CGRectMake(col*colWidth, row*rowHeight, imageWidth, imageHeight);
    [self addSubview:view];
  }
  int nRows = ceil(images.count / (float)self.imagesPerRow);
  CGSize contentSize = CGSizeMake(totalWidth,
                                  nRows * rowHeight - self.padding); // rowHeight includes sepWidth, remove extra one
  self.contentSize = contentSize;
}


- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // set defaults
    self.imageAspectRatio = 4./3.;
    self.padding = 4;
    self.imagesPerRow = 4;
  }
  return self;
}


@end

//
//  ImagesView.m
//  elme
//
//  Created by Sven A. Schmidt on 20.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "ImagesView.h"

#import <QuartzCore/QuartzCore.h>


@interface ImagesView () {
  UIImageView *selectedImageView;
}

@end


@implementation ImagesView

@synthesize allowsSelection = _allowsSelection;
@synthesize detailItem = _detailItem;
@synthesize growthDirection = _growthDirection;
@synthesize imageAspectRatio = _imageAspectRatio;
@synthesize imagesPerFixedDimension = _imagesPerFixedDimension;
@synthesize padding = _padding;
@synthesize selectionBorderWidth = _selectionBorderWidth;
@synthesize selectionColor = _selectionColor;


#pragma mark - Accessors


- (UIImage *)selectedImage {
  return selectedImageView.image;
}


#pragma mark - Actions


- (void)tapHandler:(UIGestureRecognizer *)gestureRecognizer {
  UIImageView *view = (UIImageView *)gestureRecognizer.view;
  if (selectedImageView != view) {
    selectedImageView.layer.borderWidth = 0;
    
    view.layer.borderWidth = self.selectionBorderWidth;
    view.layer.borderColor = self.selectionColor.CGColor;

    selectedImageView = view;
  }
}


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
      if (self.allowsSelection) {
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)]];
      }
      
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


#pragma mark - Init


- (void)initialize {
  // set defaults
  self.growthDirection = kVertical;
  self.imageAspectRatio = 4./3.;
  self.padding = 4;
  self.imagesPerFixedDimension = 4;
  self.allowsSelection = NO;
  self.selectionColor = [UIColor yellowColor];
  self.selectionBorderWidth = 3;
}


- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self initialize];
  }
  return self;
}


- (id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    [self initialize];
  }
  return self;
}


@end

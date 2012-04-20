//
//  ImagesCell.m
//  elme
//
//  Created by Sven A. Schmidt on 17.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "ImagesCell.h"

@implementation ImagesCell

@synthesize detailItem = _detailItem;
@synthesize noImagesView = _noImagesView;
@synthesize scrollView = _scrollView;


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
  } else {
    self.noImagesView.hidden = YES;
  }
}


@end

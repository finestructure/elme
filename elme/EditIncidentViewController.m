//
//  EditIncidentViewController.m
//  elme
//
//  Created by Sven A. Schmidt on 11.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "EditIncidentViewController.h"

@interface EditIncidentViewController ()

@end

@implementation EditIncidentViewController

@synthesize detailItem = _detailItem;


#pragma mark - Managing the detail item


- (void)setDetailItem:(id)newDetailItem
{
  if (_detailItem != newDetailItem) {
    _detailItem = newDetailItem;
    
    [self configureView];
  }
}


- (void)configureView
{
  if (self.detailItem) {
  }
}


#pragma mark - Init and view lifecycle


- (void)viewDidLoad
{
  [super viewDidLoad];
  [self configureView];
}


- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Actions


- (IBAction)save:(id)sender {
  [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)cancel:(id)sender {
  [self dismissModalViewControllerAnimated:YES];
}


@end

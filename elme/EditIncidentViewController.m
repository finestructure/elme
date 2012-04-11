//
//  EditIncidentViewController.m
//  elme
//
//  Created by Sven A. Schmidt on 11.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "EditIncidentViewController.h"

#import "Database.h"
#import "Incident.h"

@interface EditIncidentViewController ()

@end

@implementation EditIncidentViewController

@synthesize detailItem = _detailItem;
@synthesize projectLabel = _projectLabel;
@synthesize createdAtLabel = _createdAtLabel;
@synthesize mapView = _mapView;
@synthesize descriptionTextField = _descriptionTextField;


#pragma mark - Helpers


- (void)failedWithError:(NSError *)error {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"General error dialog title") message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alert show];
}


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

  } else {
    self.projectLabel.text = NSLocalizedString(@"kein Projekt", @"no project assigned label");
    self.createdAtLabel.text = @"–";
  }
}


#pragma mark - Init and view lifecycle


- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.mapView.userLocation addObserver:self  
                              forKeyPath:@"location"  
                                 options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)  
                                 context:NULL];
  [self configureView];
}


- (void)viewDidUnload
{
  [self setDescriptionTextField:nil];
  [self setProjectLabel:nil];
  [self setCreatedAtLabel:nil];
  [self setMapView:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - Actions


- (IBAction)save:(id)sender {
  if (self.detailItem == nil) {
    self.detailItem = [[Incident alloc] initWithNewDocumentInDatabase:[Database sharedInstance].database];
  }

  self.detailItem.desc = self.descriptionTextField.text;
  
  RESTOperation* op = [self.detailItem save];
  [op onCompletion: ^{
    if (op.error) {
      [self failedWithError:op.error];
    }
  }];
  [op start];
  
  [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)cancel:(id)sender {
  [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)backgroundTapped:(id)sender {
  [self.view endEditing:YES];
}


#pragma mark - KVO


- (void)observeValueForKeyPath:(NSString *)keyPath  
                      ofObject:(id)object  
                        change:(NSDictionary *)change  
                       context:(void *)context {  
  if ([self.mapView showsUserLocation]) {  
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 2000, 2000);    
    [self.mapView setRegion:region animated:YES];
  }
}


#pragma mark - UITextViewDelegate


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
  if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
    return YES;
  }
  
  [self.descriptionTextField resignFirstResponder];
  return NO;
}


#pragma mark - Keyboard handlers


- (void)keyboardWillShow:(NSNotification *)notification {
  CGRect frame = self.view.frame;
  frame.origin.y -= 100;
  [UIView animateWithDuration:0.2 animations:^{
    self.view.frame = frame;
  }];
}


- (void)keyboardWillHide:(NSNotification *)notification {
  CGRect frame = self.view.frame;
  frame.origin.y += 100;
  [UIView animateWithDuration:0.2 animations:^{
    self.view.frame = frame;
  }];
}


@end

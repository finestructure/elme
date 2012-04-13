//
//  EditIncidentViewController.m
//  elme
//
//  Created by Sven A. Schmidt on 11.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "EditIncidentViewController.h"

#import "Annotation.h"
#import "Database.h"
#import "Incident.h"

#import <CouchCocoa/CouchDesignDocument_Embedded.h>


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


- (void)zoomMapToAnnotationRegion {
  MKMapRect zoomRect = MKMapRectNull;
  for (id <MKAnnotation> annotation in self.mapView.annotations)
  {
    MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
    MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
    if (MKMapRectIsNull(zoomRect)) {
      zoomRect = pointRect;
    } else {
      zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
  }
  [self.mapView setVisibleMapRect:zoomRect animated:YES];
}


- (void)addAnnotationWithTitle:(NSString *)title subtitle:(NSString *)subtitle coordinate:(CLLocationCoordinate2D)coordinate
{
  Annotation *ann = [[Annotation alloc] init];
  ann.title = title;
  ann.subtitle = subtitle;
  ann.coordinate = coordinate;
  [self.mapView addAnnotation:ann];
  [self zoomMapToAnnotationRegion];
}


- (void)setPinForUnit:(CouchQueryRow *)row {
  NSDictionary *unit = row.value;
  NSString *title = [unit objectForKey:@"name"];
  NSString *subtitle = [unit objectForKey:@"address"];
  
  if ([unit objectForKey:@"latitude"] && [unit objectForKey:@"longitude"]) {
    CLLocationDegrees latitude = [[unit objectForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude = [[unit objectForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    [self addAnnotationWithTitle:title subtitle:subtitle coordinate:coordinate];
  } else {
    CLGeocoder *coder = [[CLGeocoder alloc] init];
    NSString *address = [unit objectForKey:@"address"];
    [coder geocodeAddressString:address completionHandler:^(NSArray *__strong placemarks, NSError *__strong error) {
      if (error != nil) {
        if ([error code] == kCLErrorGeocodeFoundNoResult) {
          NSLog(@"*** no result found *** (for: %@)", address);
        } else {
          NSLog(@"geocoding error: %@", [error localizedDescription]);
        }
      } else if ([placemarks count] > 0) {
        CLPlacemark *best = [placemarks objectAtIndex:0];
        NSLog(@"Best placemark: %@", best);
        CLLocationCoordinate2D coordinate = best.location.coordinate;
        [self addAnnotationWithTitle:title subtitle:subtitle coordinate:coordinate];
        { // save coordinates to unit
          NSMutableDictionary *newUnit = [unit mutableCopy];
          [newUnit setValue:[NSNumber numberWithDouble:coordinate.longitude] forKey:@"longitude"];
          [newUnit setValue:[NSNumber numberWithDouble:coordinate.latitude] forKey:@"latitude"];
#warning save coordinates
          //          [self updateUnitAtIndex:index withObject:newUnit];
        }
      }
    }];
    
  }
}


- (void)showUnits {
  CouchDesignDocument* design = [[Database sharedInstance] designDocumentWithName: @"default"];
  [design defineViewNamed: @"units" 
                 mapBlock: ^(NSDictionary* doc, void (^emit)(id key, id value)) {
                   id type = [doc objectForKey: @"type"];
                   if (type && [type isEqualToString:@"project"]) {
                     NSArray *units = [doc objectForKey:@"units"];
                     if (units) {
                       for (NSDictionary *unit in units) {
                         id name = [unit objectForKey:@"name"];
                         emit(name, unit);
                       }
                     }
                   }
                 } 
                  version: @"1.0"];
  CouchQuery *query = [design queryViewNamed:@"units"];
  RESTOperation *op = [query start];
  [op onCompletion:^{
    CouchQueryEnumerator *rows = op.resultObject;
    CouchQueryRow *row = nil;
    while ((row = rows.nextRow) != nil) {
      NSLog(@"row: %@", row);
      [self setPinForUnit:row];
    }
  }];
}


#pragma mark - Init and view lifecycle


- (void)viewDidLoad
{
  [super viewDidLoad];
  [self showUnits];
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
  
  [self.mapView.userLocation addObserver:self  
                              forKeyPath:@"location"  
                                 options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)  
                                 context:NULL];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self.mapView.userLocation removeObserver:self forKeyPath:@"location"];
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

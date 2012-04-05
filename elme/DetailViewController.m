//
//  DetailViewController.m
//  elme
//
//  Created by Sven A. Schmidt on 04.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "DetailViewController.h"

#import "Annotation.h"
#import "Project.h"


@interface DetailViewController ()
- (void)configureView;
@end


@implementation DetailViewController

@synthesize detailItem = _detailItem;
@synthesize mapView = _mapView;
@synthesize tableView = _tableView;


#pragma mark - Helpers

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


- (void)setPinForAddress:(NSString *)address withTitle:(NSString *)title subtitle:(NSString *)subtitle {
  NSLog(@"address: %@", address);
  CLGeocoder *coder = [[CLGeocoder alloc] init];
  [coder geocodeAddressString:address completionHandler:^(NSArray *__strong placemarks, NSError *__strong error) {
    if (error != nil) {
      //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Geocoding Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
      //[alert show];
      if ([error code] == kCLErrorGeocodeFoundNoResult) {
        NSLog(@"*** no result found *** (for: %@)", address);
      } else {
        NSLog(@"geocoding error: %@", [error localizedDescription]);
      }
    } else if ([placemarks count] > 0) {
      CLPlacemark *best = [placemarks objectAtIndex:0];
      NSLog(@"Best placemark: %@", best);
      Annotation *ann = [[Annotation alloc] init];
      ann.title = title;
      ann.subtitle = subtitle;
      ann.coordinate = best.location.coordinate;
      [self.mapView addAnnotation:ann];
      [self zoomMapToAnnotationRegion];
    }
  }];
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
    self.title = self.detailItem.name;
    for (NSDictionary *unit in self.detailItem.units) {
      NSString *address = [unit objectForKey:@"address"];
      if (address != nil) {
        NSString *title = [unit objectForKey:@"name"];
        NSString *subtitle = address;
        [self setPinForAddress:address withTitle:title subtitle:subtitle];
      }
    }
  }
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  [self configureView];
}


- (void)viewDidUnload
{
  [self setMapView:nil];
  [self setTableView:nil];
  [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.detailItem.units.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UnitCell"];
  NSDictionary *unit = [self.detailItem.units objectAtIndex:indexPath.row];
  cell.textLabel.text = [unit valueForKey:@"name"];
  return cell;
}


@end

//
//  LocationCell.m
//  elme
//
//  Created by Sven A. Schmidt on 17.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "LocationCell.h"

#import "Annotation.h"
#import "Database.h"
#import "Project.h"

#import <CouchCocoa/CouchCocoa.h>


@implementation LocationCell

@synthesize mapView = _mapView;
@synthesize nameLabel = _nameLabel;
@synthesize addressTextView = _addressTextView;
@synthesize name = _name;
@synthesize address = _address;
@synthesize coordinate = _coordinate;


#pragma mark - Setters


- (void)setName:(NSString *)name
{
  self.nameLabel.text = name;
}


- (void)setAddress:(NSString *)address
{
  self.addressTextView.text = [address stringByReplacingOccurrencesOfString:@", " withString:@"\n"];
}


- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
  MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000);    
  [self.mapView setRegion:region animated:YES];
}


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


- (void)addAnnotationWithTitle:(NSString *)title subtitle:(NSString *)subtitle coordinate:(CLLocationCoordinate2D)coordinate
{
  Annotation *ann = [[Annotation alloc] init];
  ann.title = title;
  ann.subtitle = subtitle;
  ann.coordinate = coordinate;
  [self.mapView addAnnotation:ann];
  [self zoomMapToAnnotationRegion];
}


- (void)updateProjectWithId:(NSString *)projectId withCoordinate:(CLLocationCoordinate2D)coordinate forAddress:(NSString *)address
{
  Project *project = [[Database sharedInstance] projectWithId:projectId];
  BOOL needsUpdate = NO;
  NSMutableArray *newUnits = [project.units mutableCopy];
  
  for (NSUInteger index = 0; index < project.units.count; index++) {
    NSDictionary *unit = [project.units objectAtIndex:index];
    NSString *unitAddress = [unit valueForKey:@"address"];
    if ([address isEqualToString:unitAddress]
        && [[unit objectForKey:@"latitude"] doubleValue] != coordinate.latitude
        && [[unit objectForKey:@"longitude"] doubleValue] != coordinate.longitude
        ) {
      NSMutableDictionary *newUnit = [unit mutableCopy];
      [newUnit setValue:[NSNumber numberWithDouble:coordinate.longitude] forKey:@"longitude"];
      [newUnit setValue:[NSNumber numberWithDouble:coordinate.latitude] forKey:@"latitude"];
      [newUnits replaceObjectAtIndex:index withObject:newUnit];
      needsUpdate = YES;
    }
  }
  if (needsUpdate) {
    project.units = newUnits;
    RESTOperation *op = [project save];
    [op onCompletion: ^{
      if (op.error) {
        NSLog(@"Error while saving coordinates: %@", [op.error localizedDescription]);
      }
    }];
    [op start];
  }
}


- (void)setPinForUnit:(CouchQueryRow *)row {
  NSDictionary *unit = row.key;
  NSDictionary *project = row.value;
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
          [self updateProjectWithId:[project valueForKey:@"_id"] withCoordinate:coordinate forAddress:address];
        }
      }
    }];
    
  }
}


- (void)showUnits {
  CouchQuery *query = [[Database sharedInstance] units];
  RESTOperation *op = [query start];
  [op onCompletion:^{
    CouchQueryEnumerator *rows = op.resultObject;
    CouchQueryRow *row = nil;
    while ((row = rows.nextRow) != nil) {
      [self setPinForUnit:row];
    }
  }];
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


#pragma mark - Init & view lifecycle


- (id)initWithCoder:(NSCoder *)decoder
{
  self = [super initWithCoder:decoder];
  if (self != nil) {
    [self.mapView.userLocation addObserver:self  
                                forKeyPath:@"location"  
                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)  
                                   context:NULL];
    [self showUnits];
  }
  return self;
}


@end

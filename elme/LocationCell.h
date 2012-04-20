//
//  LocationCell.h
//  elme
//
//  Created by Sven A. Schmidt on 17.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LocationCell : UITableViewCell

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *address;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, nonatomic) BOOL zoomToAnnotations;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *addressTextView;

- (void)showUnits;

- (CGFloat)rowHeight;

@end

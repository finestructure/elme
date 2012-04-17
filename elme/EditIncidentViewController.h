//
//  EditIncidentViewController.h
//  elme
//
//  Created by Sven A. Schmidt on 11.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class Incident;

@interface EditIncidentViewController : UIViewController<UITextViewDelegate>

@property (strong, nonatomic) Incident *detailItem;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

- (IBAction)backgroundTapped:(id)sender;

@end

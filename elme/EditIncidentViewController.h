//
//  EditIncidentViewController.h
//  elme
//
//  Created by Sven A. Schmidt on 11.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Incident;

@interface EditIncidentViewController : UIViewController

@property (strong, nonatomic) Incident *detailItem;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end

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
@property (assign) BOOL isNewItem;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)deleteItem:(id)sender;

@end

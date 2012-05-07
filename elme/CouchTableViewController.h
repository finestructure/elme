//
//  CouchTableViewController.h
//  elme
//
//  Created by Sven A. Schmidt on 10.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

/*
 
 Integration:
 
 - create sub class
 - set it as your view controller class
 - configure/set dataSource property
 - make sure dataSource.tableView is assigned to self.tableView and
   self.tableView.dataSource is assigned to self.dataSource
 - implement couchTableSource:cellForRowAtIndexPath:
 - connect tableView outlet
 
 */

#import <UIKit/UIKit.h>

#import <CouchCocoa/CouchUITableSource.h>

@interface CouchTableViewController : UIViewController<CouchUITableDelegate>

@property (nonatomic, retain) CouchUITableSource* dataSource;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)failedWithError:(NSError *)error;

@end

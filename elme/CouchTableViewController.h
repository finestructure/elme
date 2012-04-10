//
//  CouchTableViewController.h
//  elme
//
//  Created by Sven A. Schmidt on 10.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CouchCocoa/CouchUITableSource.h>

@interface CouchTableViewController : UIViewController<CouchUITableDelegate>

@property (nonatomic, retain) CouchUITableSource* dataSource;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

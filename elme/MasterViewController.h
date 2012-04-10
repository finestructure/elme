//
//  MasterViewController.h
//  elme
//
//  Created by Sven A. Schmidt on 04.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CouchCocoa/CouchUITableSource.h>

@class CouchDatabase;

@interface MasterViewController : UITableViewController<CouchUITableDelegate>

@property (nonatomic, retain) CouchUITableSource* dataSource;

@end

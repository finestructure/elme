//
//  LocationViewController.h
//  elme
//
//  Created by Sven A. Schmidt on 18.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "CouchTableViewController.h"

#import "Protocols.h"

@interface LocationViewController : CouchTableViewController

@property (weak, nonatomic) id<DetailItemHandlerDelegate> delegate;

@end

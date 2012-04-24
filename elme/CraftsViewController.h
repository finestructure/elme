//
//  CraftsViewController.h
//  elme
//
//  Created by Sven A. Schmidt on 24.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Protocols.h"

@class Incident;

@interface CraftsViewController : UITableViewController

@property (strong, nonatomic) Incident *detailItem;
@property (weak, nonatomic) id<DetailItemHandlerDelegate> delegate;

@end

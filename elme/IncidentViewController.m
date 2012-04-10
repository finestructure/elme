//
//  IncidentViewController.m
//  elme
//
//  Created by Sven A. Schmidt on 10.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "IncidentViewController.h"

#import "Database.h"

#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchDesignDocument_Embedded.h>


@interface IncidentViewController ()

@end


@implementation IncidentViewController


#pragma mark - Helpers


- (void)setupDataSource {
  self.dataSource = [[CouchUITableSource alloc] init];
  
  // Create a 'view' containing list items sorted by date:
  CouchDesignDocument* design = [[Database sharedInstance] designDocumentWithName: @"default"];
  [design defineViewNamed: @"projects" 
                 mapBlock: ^(NSDictionary* doc, void (^emit)(id key, id value)) {
                   id type = [doc objectForKey: @"type"];
                   if (type && [type isEqualToString:@"project"]) {
                     id name = [doc objectForKey:@"name"];
                     if (name) {
                       emit(name, doc);
                     }
                   }
                 } 
                  version: @"3.0"];
  
  // Create a query sorted by descending date, i.e. newest items first:
  CouchLiveQuery* query = [[design queryViewNamed: @"projects"] asLiveQuery];
  query.descending = YES;
  self.dataSource.query = query;
  
  // table view connections
  self.dataSource.tableView = self.tableView;
  self.tableView.dataSource = self.dataSource;
}


#pragma mark - Init & view lifecycle


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setupDataSource];
}


- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end

//
//  MasterViewController.m
//  elme
//
//  Created by Sven A. Schmidt on 04.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "MasterViewController.h"

#import "Configuration.h"
#import "Database.h"
#import "DetailViewController.h"
#import "Globals.h"
#import "Project.h"

#import <CouchCocoa/CouchDesignDocument_Embedded.h>


@interface MasterViewController () {
}
@end


@implementation MasterViewController


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


- (Project *)projectForIndexPath:(NSIndexPath *)indexPath {
  CouchQueryRow *row = [self.dataSource rowAtIndex:indexPath.row];
  Project *proj = [Project modelForDocument:row.document];
  return proj;
}


- (void)insertNewObject:(id)sender
{
  Project *proj = [[Project alloc] initWithNewDocumentInDatabase:[Database sharedInstance].database];
  proj.name = @"Neues Projekt";
  
  // Save the document, asynchronously:
  RESTOperation* op = [proj save];
  [op onCompletion: ^{
    if (op.error) {
      [self failedWithError:op.error];
    }
    [self.dataSource.query start];
  }];
  [op start];
}


#pragma mark - Init


- (void)awakeFromNib {
  [super awakeFromNib];
}


- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  self.navigationItem.leftBarButtonItem = self.editButtonItem;

  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
  self.navigationItem.rightBarButtonItem = addButton;
  
  [self setupDataSource];
}


- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}


#pragma mark - CouchUITableDelegate


- (UITableViewCell *)couchTableSource:(CouchUITableSource*)source cellForRowAtIndexPath:(NSIndexPath *)indexPath; {  
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ProjectCell"];
  Project *proj = [self projectForIndexPath:indexPath];
  cell.textLabel.text = proj.name;
  
  return cell;
}


#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Project *proj = [self projectForIndexPath:indexPath];
    [[segue destinationViewController] setDetailItem:proj];
  }
}


@end

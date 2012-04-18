//
//  IncidentViewController.m
//  elme
//
//  Created by Sven A. Schmidt on 10.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "IncidentViewController.h"

#import "Database.h"
#import "EditIncidentViewController.h"
#import "Incident.h"

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
  [design defineViewNamed: @"incidents" 
                 mapBlock: ^(NSDictionary* doc, void (^emit)(id key, id value)) {
                   id type = [doc objectForKey: @"type"];
                   if (type && [type isEqualToString:@"incident"]) {
                     id date = [doc objectForKey: @"created_at"];
                     if (date) {
                       id _id = [doc objectForKey:@"_id"];
                       emit([NSArray arrayWithObjects:date, _id, nil], doc);
                     }
                   }
                 } 
                  version: @"1.0"];
  
  // and a validation function requiring parseable dates:
  design.validationBlock = ^BOOL(TDRevision* newRevision, id<TDValidationContext> context) {
    if (newRevision.deleted)
      return YES;
    id date = [newRevision.properties objectForKey: @"created_at"];
    if (date && ! [RESTBody dateWithJSONObject:date]) {
      context.errorMessage = [@"invalid date " stringByAppendingString:date];
      return NO;
    }
    return YES;
  };

  // Create a query sorted by descending date, i.e. newest items first:
  CouchLiveQuery* query = [[design queryViewNamed: @"incidents"] asLiveQuery];
  query.descending = YES;
  self.dataSource.query = query;
  
  // table view connections
  self.dataSource.tableView = self.tableView;
  self.tableView.dataSource = self.dataSource;
}


- (Incident *)incidentForIndexPath:(NSIndexPath *)indexPath {
  CouchQueryRow *row = [self.dataSource rowAtIndex:indexPath.row];
  Incident *obj = [Incident modelForDocument:row.document];
  return obj;
}


- (void)insertNewObject:(id)sender
{
  id obj = [[Incident alloc] initWithNewDocumentInDatabase:[Database sharedInstance].database];
  
  RESTOperation* op = [obj save];
  [op onCompletion: ^{
    if (op.error) {
      [self failedWithError:op.error];
    }
    [self.dataSource.query start];
  }];
  [op start];
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


#pragma mark - CouchUITableDelegate


- (UITableViewCell *)couchTableSource:(CouchUITableSource*)source cellForRowAtIndexPath:(NSIndexPath *)indexPath; {
  static NSDateFormatter *formatter = nil;
  if (formatter == nil) {
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
  }
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"IncidentCell"];
  Incident *incident = [self incidentForIndexPath:indexPath];
  cell.textLabel.text = [formatter stringFromDate:incident.created_at];
  return cell;
}


#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"NewIncident"]) {
    UINavigationController *nc = [segue destinationViewController];
    EditIncidentViewController *vc = (EditIncidentViewController *)nc.topViewController;
    vc.detailItem = nil;
  }
}


@end

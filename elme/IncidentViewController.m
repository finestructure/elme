//
//  IncidentViewController.m
//  elme
//
//  Created by Sven A. Schmidt on 10.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "IncidentViewController.h"

#import "Database.h"
#import "Globals.h"
#import "EditIncidentViewController.h"
#import "Incident.h"

#import <CouchCocoa/CouchCocoa.h>


@interface IncidentViewController ()

@end


@implementation IncidentViewController


#pragma mark - CouchTableViewController methods
@synthesize versionLabel;


- (void)setupDataSource {
  CouchLiveQuery *query = [[[Database sharedInstance] incidents] asLiveQuery];
  query.descending = YES;
  
  self.dataSource = [[CouchUITableSource alloc] init];
  self.dataSource.query = query;
  
  // table view connections
  self.dataSource.tableView = self.tableView;
  self.tableView.dataSource = self.dataSource;
}


#pragma mark - Helpers


- (Incident *)incidentForIndexPath:(NSIndexPath *)indexPath {
  CouchQueryRow *row = [self.dataSource rowAtIndex:indexPath.row];
  Incident *obj = [Incident modelForDocument:row.document];
  return obj;
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
  self.versionLabel.text = [Globals sharedInstance].version;
  [self setupDataSource];
}


- (void)viewDidUnload
{
  [self setVersionLabel:nil];
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
    EditIncidentViewController *evc = (EditIncidentViewController *)nc.topViewController;
    evc.detailItem = [[Incident alloc] initWithNewDocumentInDatabase:[Database sharedInstance].database];
    evc.isNewItem = YES;
  } else if ([[segue identifier] isEqualToString:@"EditIncident"]) {
    NSIndexPath *selectedRow = self.tableView.indexPathForSelectedRow;
    CouchQueryRow *row = [self.dataSource rowAtIndex:selectedRow.row];

    EditIncidentViewController *evc = (EditIncidentViewController *)segue.destinationViewController;
    evc.detailItem = [Incident modelForDocument:row.document];
    evc.isNewItem = NO;
    [self.tableView deselectRowAtIndexPath:selectedRow animated:YES];
  }
}


@end

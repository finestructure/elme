//
//  LocationViewController.m
//  elme
//
//  Created by Sven A. Schmidt on 18.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "LocationViewController.h"

#import "Database.h"
#import "EditIncidentViewController.h"
#import "Incident.h"
#import "LocationCell.h"

#import <CouchCocoa/CouchCocoa.h>


@interface LocationViewController ()

@end

@implementation LocationViewController

@synthesize delegate = _delegate;

#pragma mark - CouchTableViewController methods


- (void)setupDataSource {
  CouchLiveQuery *query = [[[Database sharedInstance] units] asLiveQuery];
  
  self.dataSource = [[CouchUITableSource alloc] init];
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
  UINib *nib = [UINib nibWithNibName:@"LocationCell" bundle:nil];
  [self.tableView registerNib:nib forCellReuseIdentifier:@"LocationCell"];
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


#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
  return cell.frame.size.height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  CouchQueryRow *row = [self.dataSource rowAtIndex:indexPath.row];
  NSDictionary *unit = row.key;
  
  EditIncidentViewController *evc = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
  evc.detailItem.unit = unit;

  [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
  [self.navigationController popViewControllerAnimated:YES];
  
  if ([self.delegate respondsToSelector:@selector(detailItemEdited)]) {
    [self.delegate detailItemEdited];
  }
}


#pragma mark - CouchUITableDelegate


- (UITableViewCell *)couchTableSource:(CouchUITableSource*)source cellForRowAtIndexPath:(NSIndexPath *)indexPath; {
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
  
  CouchQueryRow *row = [self.dataSource rowAtIndex:indexPath.row];
  NSDictionary *unit = row.key;

  LocationCell *lc = (LocationCell *)cell;
  lc.name = [unit valueForKey:@"name"];
  lc.address = [unit valueForKey:@"address"];
  if (unit && [unit valueForKey:@"latitude"] && [unit valueForKey:@"longitude"]) {
    CLLocationDegrees longitude = [[unit valueForKey:@"longitude"] doubleValue];
    CLLocationDegrees latitude = [[unit valueForKey:@"latitude"] doubleValue];
    lc.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
  }
  
  return cell;
}


@end

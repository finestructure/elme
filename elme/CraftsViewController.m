//
//  CraftsViewController.m
//  elme
//
//  Created by Sven A. Schmidt on 24.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "CraftsViewController.h"

#import "Incident.h"

@interface CraftsViewController () {
  NSArray *crafts;
}

@end


@implementation CraftsViewController

@synthesize delegate = _delegate;
@synthesize detailItem = _detailItem;


- (void)viewDidLoad
{
  [super viewDidLoad];
  crafts = [NSArray arrayWithObjects:
            @"Dachdecker",
            @"Elektro",
            @"Fensterbauer",
            @"Sanitär",
            nil];
}


- (void)viewDidUnload
{
  [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return crafts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  NSString *craft = [crafts objectAtIndex:indexPath.row];
  cell.textLabel.text = craft;
  if ([craft isEqualToString:self.detailItem.craft]) {
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
  } else {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
  }
  return cell;
}


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *craft = [crafts objectAtIndex:indexPath.row];
  self.detailItem.craft = craft;
  [self.delegate detailItemEdited];
  [self.navigationController popViewControllerAnimated:YES];
}


@end

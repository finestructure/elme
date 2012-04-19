//
//  EditIncidentViewController.m
//  elme
//
//  Created by Sven A. Schmidt on 11.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "EditIncidentViewController.h"

#import "Annotation.h"
#import "Database.h"
#import "DescriptionCell.h"
#import "Incident.h"
#import "LocationCell.h"


@interface EditIncidentViewController () {
  NSMutableArray *cells;
}

@end

@implementation EditIncidentViewController

@synthesize detailItem = _detailItem;
@synthesize tableView = _tableView;


#pragma mark - Helpers


- (void)failedWithError:(NSError *)error {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"General error dialog title") message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alert show];
}


#pragma mark - Managing the detail item


- (void)setDetailItem:(id)newDetailItem
{
  if (_detailItem != newDetailItem) {
    _detailItem = newDetailItem;
    
    [self configureView];
  }
}


- (void)configureView
{
  static NSDateFormatter *formatter = nil;
  if (formatter == nil) {
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
  }

  if (self.detailItem) {
    NSString *date = [formatter stringFromDate:self.detailItem.created_at];
    NSString *title = NSLocalizedString(@"Vorfall vom %@", @"Edit incident title");
    self.title = [NSString stringWithFormat:title, date];
  } else {
    self.title = NSLocalizedString(@"Neuer Vorfall", @"Edit incident title (new incident)");
  }
  [self.tableView reloadData];
}


#pragma mark - Init and view lifecycle


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  cells = [NSMutableArray array];
  NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LocationCell" owner:self options:nil];
  [cells addObject:[nib objectAtIndex:0]];
  nib = [[NSBundle mainBundle] loadNibNamed:@"DescriptionCell" owner:self options:nil];
  [cells addObject:[nib objectAtIndex:0]];
  nib = [[NSBundle mainBundle] loadNibNamed:@"ImagesCell" owner:self options:nil];
  [cells addObject:[nib objectAtIndex:0]];

  [self configureView];
}


- (void)viewDidUnload
{
  [self setTableView:nil];
  cells = nil;
  [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  
  [self configureView];
}


- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - Actions


- (IBAction)save:(id)sender {
  if (self.detailItem == nil) {
    self.detailItem = [[Incident alloc] initWithNewDocumentInDatabase:[Database sharedInstance].database];
  }

#warning assign attributes to save from GUI
  
  RESTOperation* op = [self.detailItem save];
  [op onCompletion: ^{
    if (op.error) {
      [self failedWithError:op.error];
    }
  }];
  [op start];
  
  [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)cancel:(id)sender {
  [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  // work-around for growing row height -- keep around initial values
  static NSMutableArray *heights = nil;
  if (heights == nil) {
    heights = [NSMutableArray array];
    for (UITableViewCell *cell in cells) {
      [heights addObject:[NSNumber numberWithDouble:cell.bounds.size.height]];
    }
  }
  return [[heights objectAtIndex:indexPath.section] doubleValue];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch (indexPath.section) {
    case 0:
      [self performSegueWithIdentifier:@"LocationDetail" sender:self];
      break;
      
  }
  [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - UITableViewDataSource


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [cells objectAtIndex:indexPath.section];
  switch (indexPath.section) {
    case 0:
    {
      LocationCell *lc = (LocationCell *)cell;
      if (self.detailItem) {
        NSDictionary *unit = self.detailItem.unit;
        lc.name = [unit valueForKey:@"name"];
        lc.address = [unit valueForKey:@"address"];
        if (unit && [unit valueForKey:@"latitude"] && [unit valueForKey:@"longitude"]) {
          lc.coordinate =
          CLLocationCoordinate2DMake(
                                     [[unit valueForKey:@"latitude"] doubleValue],
                                     [[unit valueForKey:@"longitude"] doubleValue]
          );
        } else {
          lc.zoomToAnnotations = YES;
          [lc showUnits];
        }
      } else {
        lc.name = @"";
        lc.address = @"";
        lc.zoomToAnnotations = YES;
        [lc showUnits];
      }
    }
      break;
      
    case 1:
      ((DescriptionCell *)cell).textView.text = self.detailItem ? self.detailItem.desc : @"";
      break;
  }
  return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 1;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 3;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  switch (section) {
    case 0:
      return NSLocalizedString(@"Ort", @"Location header");
      break;

    case 1:
      return NSLocalizedString(@"Beschreibung", @"Description header");
      break;

    case 2:
      return NSLocalizedString(@"Bilder", @"Images header");
      break;

    default:
      return @"";
      break;
  }
}


#pragma mark - Keyboard handlers


- (void)keyboardWillShow:(NSNotification *)notification {
  CGRect frame = self.view.frame;
  frame.origin.y -= 100;
  [UIView animateWithDuration:0.2 animations:^{
    self.view.frame = frame;
  }];
}


- (void)keyboardWillHide:(NSNotification *)notification {
  CGRect frame = self.view.frame;
  frame.origin.y += 100;
  [UIView animateWithDuration:0.2 animations:^{
    self.view.frame = frame;
  }];
}


@end

//
//  EditIncidentViewController.m
//  elme
//
//  Created by Sven A. Schmidt on 11.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "EditIncidentViewController.h"

#import "Annotation.h"
#import "CraftsViewController.h"
#import "Database.h"
#import "DescriptionCell.h"
#import "ImagesCell.h"
#import "ImagesViewController.h"
#import "Incident.h"
#import "LocationCell.h"
#import "LocationViewController.h"


@interface EditIncidentViewController () {
  NSMutableArray *cells;
}

@end

@implementation EditIncidentViewController

@synthesize detailItem = _detailItem;
@synthesize isNewItem = _isNewItem;
@synthesize tableView = _tableView;
@synthesize toolBar = _toolBar;


#pragma mark - Helpers


- (void)failedWithError:(NSError *)error {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"General error dialog title") message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alert show];
}


- (void)save {
  RESTOperation* op = [self.detailItem save];
  [op onCompletion: ^{
    if (op.error) {
      [self failedWithError:op.error];
    }
  }];
  [op start];
}


#pragma mark - Managing the detail item


- (void)setDetailItem:(id)newDetailItem
{
  if (_detailItem != newDetailItem) {
    _detailItem.delegate = nil;
    _detailItem = newDetailItem;
    _detailItem.delegate = self;
    [self configureView];
  }
}


- (void)configureView
{
  static NSDateFormatter *formatter = nil;
  if (formatter == nil) {
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
  }

  if (self.detailItem) {
    NSString *date = [formatter stringFromDate:self.detailItem.created_at];
    NSString *title = NSLocalizedString(@"Vorfall vom %@", @"Edit incident title");
    self.title = [NSString stringWithFormat:title, date];
    
    DescriptionCell *descCell = [cells objectAtIndex:1];
    descCell.textView.text = self.detailItem.desc;

    ImagesCell *imagesCell = [cells objectAtIndex:2];
    imagesCell.detailItem = self.detailItem.images;
  } else {
    self.title = NSLocalizedString(@"Neuer Vorfall", @"Edit incident title (new incident)");
  }
  [self.tableView reloadData];
}


#pragma mark - Init and view lifecycle


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  NSMutableArray *buttons = [NSMutableArray array];
  if (self.isNewItem) {
    [buttons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)]];
    [buttons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    [buttons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)]];
  } else {
    [buttons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteItem:)]];
  }
  for (UIBarButtonItem *button in buttons) {
    button.style = UIBarButtonItemStyleBordered;
  }
  [self.toolBar setItems:buttons animated:NO];
  
  cells = [NSMutableArray array];
  NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LocationCell" owner:self options:nil];
  [cells addObject:[nib objectAtIndex:0]];
  nib = [[NSBundle mainBundle] loadNibNamed:@"DescriptionCell" owner:self options:nil];
  [cells addObject:[nib objectAtIndex:0]];
  nib = [[NSBundle mainBundle] loadNibNamed:@"ImagesCell" owner:self options:nil];
  [cells addObject:[nib objectAtIndex:0]];
  {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CraftCell"];
    [cells addObject:cell];
  }

  {
    DescriptionCell *cell = [cells objectAtIndex:1];
    cell.delegate = self;
  }
  
  [self configureView];
}


- (void)viewDidUnload
{
  [self setTableView:nil];
  cells = nil;
  [self setToolBar:nil];
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
  [self save];
  [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)cancel:(id)sender {
  [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)deleteItem:(id)sender {
  NSString *title = NSLocalizedString(@"Diesen Vorfall löschen?", 
                                      @"Delete incident action sheet title");
  NSString *cancelButtonTitle = NSLocalizedString(@"Abbrechen",
                                                  @"Cancel button title");
  NSString *destructiveButtonTitle = NSLocalizedString(@"Vorfall löschen",
                                                       @"Delete incident button title");
  UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
  [sheet showFromToolbar:self.toolBar];
}


#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == actionSheet.destructiveButtonIndex) {
    RESTOperation *op = [self.detailItem deleteDocument];
    [op onCompletion: ^{
      if (op.error) {
        [self failedWithError:op.error];
      }
    }];
    [op start];
    [self.navigationController popViewControllerAnimated:YES];
  }
}


#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 3) {
    return 44;
  } else {
    id cell = [cells objectAtIndex:indexPath.section];
    return [cell rowHeight];
  }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch (indexPath.section) {
    case 0:
      [self performSegueWithIdentifier:@"LocationDetail" sender:self];
      break;

    case 2:
      [self performSegueWithIdentifier:@"ImagesDetail" sender:self];
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
      break;
      
    case 2:
      // images cell has its detailItem already assigned in configureView
      break;
      
    case 3:
      cell.textLabel.text = self.detailItem.craft;
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
  return 4;
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

    case 3:
      return NSLocalizedString(@"Gewerk", @"Craft header");
      break;
      
    default:
      return @"";
      break;
  }
}


#pragma mark - DetailItemHandlerDelegate


- (void)detailItemEdited {
  {
    DescriptionCell *cell = [cells objectAtIndex:1];
    self.detailItem.desc = cell.textView.text;
  }
  
  if (! self.isNewItem) {
    // only save on change if item is not new
    // if it is, the complete item will be saved when the user chooses "save"
    // and we want to avoid saving intermediate state before the new object is committed
    [self save];
    [self.tableView reloadData];
  }
}


- (void)detailItemChangedExternally {
  [self configureView];
}


#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"LocationDetail"]) {
    LocationViewController *vc = [segue destinationViewController];
    vc.delegate = self;
  } else if ([[segue identifier] isEqualToString:@"ImagesDetail"]) {
    ImagesViewController *vc = [segue destinationViewController];
    vc.detailItem = self.detailItem;
    vc.delegate = self;
  } else if ([[segue identifier] isEqualToString:@"CraftDetail"]) {
    CraftsViewController *vc = [segue destinationViewController];
    vc.detailItem = self.detailItem;
    vc.delegate = self;
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

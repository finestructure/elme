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

#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchTouchDBServer.h>
#import <CouchCocoa/CouchDesignDocument_Embedded.h>


@interface MasterViewController () {
  NSMutableArray *_objects;
}
@end


@implementation MasterViewController

@synthesize dataSource = _dataSource;


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


- (void)failedWithError:(NSError *)error {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"General error dialog title") message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alert show];
}


- (Project *)projectForIndexPath:(NSIndexPath *)indexPath {
  CouchQueryRow *row = [self.dataSource rowAtIndex:indexPath.row];
  Project *proj = [Project modelForDocument:row.document];
  return proj;
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
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


#pragma mark - CouchUITableDelegate


- (UITableViewCell *)couchTableSource:(CouchUITableSource*)source cellForRowAtIndexPath:(NSIndexPath *)indexPath; {  
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ProjectCell"];
  Project *proj = [self projectForIndexPath:indexPath];
  cell.textLabel.text = proj.name;
  
  return cell;
}


- (void)couchTableSource:(CouchUITableSource*)source updateFromQuery:(CouchLiveQuery*)query previousRows:(NSArray *)oldRows
{
  BOOL (^isModified)(id, id) = ^ BOOL (id oldObj, id newObj) {
    return ! [[oldObj documentRevision] isEqualToString:[newObj documentRevision]];
  };
  
  NSArray *newRows = query.rows.allObjects;
  NSArray *addedIndexPaths = [self addedIndexPathsOldRows:oldRows newRows:newRows];
  NSArray *deletedIndexPaths = [self deletedIndexPathsOldRows:oldRows newRows:newRows];
  NSArray *modifiedIndexPaths = [self modifiedIndexPathsOldRows:oldRows newRows:newRows usingBlock:^BOOL(id oldObj, id newObj) {
    return isModified(oldObj, newObj);
  }];
  
  [self.tableView beginUpdates];
  [self.tableView insertRowsAtIndexPaths:addedIndexPaths withRowAnimation:UITableViewRowAnimationTop];
  [self.tableView deleteRowsAtIndexPaths:deletedIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
  [self.tableView reloadRowsAtIndexPaths:modifiedIndexPaths withRowAnimation:UITableViewRowAnimationRight];
  [self.tableView endUpdates];
}


- (void)couchTableSource:(CouchUITableSource*)source
         operationFailed:(RESTOperation*)op
{
  [self failedWithError:op.error];
}


#pragma mark - Seque

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Project *proj = [self projectForIndexPath:indexPath];
    [[segue destinationViewController] setDetailItem:proj];
  }
}


#pragma mark - Table view update helpers


-(NSDictionary *)indexMapForRows:(NSArray *)rows {
  NSMutableDictionary *indexMap = [[NSMutableDictionary alloc] initWithCapacity:[rows count]];
  for (int index = 0; index < [rows count]; ++index) {
    CouchQueryRow *row = [rows objectAtIndex:index];
    [indexMap setObject:[NSIndexPath indexPathForRow:index inSection:0] forKey:[row documentID]];
  }
  return indexMap;
}


-(NSArray *)deletedIndexPathsOldRows:(NSArray *)oldRows newRows:(NSArray *)newRows {
  NSDictionary *oldIndexMap = [self indexMapForRows:oldRows];
  NSDictionary *newIndexMap = [self indexMapForRows:newRows];
  
  NSMutableSet *remainder = [NSMutableSet setWithArray:oldIndexMap.allKeys];
  NSSet *newIds = [NSSet setWithArray:newIndexMap.allKeys];
  [remainder minusSet:newIds];
  NSArray *deletedIds = remainder.allObjects;
  
  NSArray *deletedIndexPaths = [oldIndexMap objectsForKeys:deletedIds notFoundMarker:[NSNull null]];  
  return deletedIndexPaths;
}


-(NSArray *)addedIndexPathsOldRows:(NSArray *)oldRows newRows:(NSArray *)newRows {
  NSDictionary *oldIndexMap = [self indexMapForRows:oldRows];
  NSDictionary *newIndexMap = [self indexMapForRows:newRows];
  
  NSMutableSet *remainder = [NSMutableSet setWithArray:newIndexMap.allKeys];
  NSSet *oldIds = [NSSet setWithArray:oldIndexMap.allKeys];
  [remainder minusSet:oldIds];
  NSArray *addedIds = remainder.allObjects;
  
  NSArray *addedIndexPaths = [newIndexMap objectsForKeys:addedIds notFoundMarker:[NSNull null]];  
  return addedIndexPaths;
}


-(NSArray *)modifiedIndexPathsOldRows:(NSArray *)oldRows newRows:(NSArray *)newRows usingBlock:(BOOL (^)(id, id))isModified {
  NSDictionary *oldIndexMap = [self indexMapForRows:oldRows];
  NSDictionary *newIndexMap = [self indexMapForRows:newRows];
  
  NSMutableSet *intersection = [NSMutableSet setWithArray:oldIndexMap.allKeys];
  [intersection intersectSet:[NSSet setWithArray:newIndexMap.allKeys]];
  NSArray *intersectionIds = intersection.allObjects;
  
  NSArray *intersectionOldIndexPaths = [oldIndexMap objectsForKeys:intersectionIds notFoundMarker:[NSNull null]];
  NSArray *intersectionNewIndexPaths = [newIndexMap objectsForKeys:intersectionIds notFoundMarker:[NSNull null]];
  NSAssert([intersectionIds count] == [intersectionOldIndexPaths count] &&
           [intersectionIds count] == [intersectionNewIndexPaths count],
           @"intersection index counts must be equal");
  
  NSMutableArray *modifiedIndexPaths = [NSMutableArray array];
  for (NSUInteger index = 0; index < [intersectionIds count]; ++index) {
    NSIndexPath *oldIndexPath = [intersectionOldIndexPaths objectAtIndex:index];
    NSIndexPath *newIndexPath = [intersectionNewIndexPaths objectAtIndex:index];
    CouchQueryRow *oldRow = [oldRows objectAtIndex:oldIndexPath.row];
    CouchQueryRow *newRow = [newRows objectAtIndex:newIndexPath.row];
    NSAssert([[oldRow documentID] isEqualToString:[newRow documentID]],
             @"document ids must be equal for objects in intersection");
    if (isModified(oldRow, newRow)) {
      [modifiedIndexPaths addObject:newIndexPath];
    }
  }
  
  return modifiedIndexPaths;
}


@end

//
//  MasterViewController.m
//  elme
//
//  Created by Sven A. Schmidt on 04.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "MasterViewController.h"

#import "Configuration.h"
#import "DetailViewController.h"
#import "Globals.h"

#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchTouchDBServer.h>
#import <CouchCocoa/CouchDesignDocument_Embedded.h>


@interface MasterViewController () {
  CouchReplication* _pull;
  CouchReplication* _push;
  NSMutableArray *_objects;
}
@end


@implementation MasterViewController

@synthesize database = _database;
@synthesize dataSource = _dataSource;


#pragma mark - Helpers

- (void)registerDefaults {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  Configuration *defaultConf = [[Globals sharedInstance] defaultConfiguration];
  NSDictionary *appdefaults = [NSDictionary dictionaryWithObject:defaultConf.name forKey:kConfigurationDefaultsKey];
  [defaults registerDefaults:appdefaults];
  [defaults synchronize];
}


- (void)setupTouchdb {
  Configuration *conf = [[Globals sharedInstance] currentConfiguration];
  { // register credentials
    NSURLCredential* cred;
    cred = [NSURLCredential credentialWithUser:conf.username
                                      password:conf.password
                                   persistence:NSURLCredentialPersistencePermanent];
    NSURLProtectionSpace* space;
    space = [[NSURLProtectionSpace alloc] initWithHost:conf.hostname
                                                  port:conf.port
                                              protocol:conf.protocol
                                                 realm:conf.realm
                                  authenticationMethod:NSURLAuthenticationMethodDefault];
    [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:cred
                                                        forProtectionSpace:space];
  }
  { // set up database
    CouchTouchDBServer *server = [CouchTouchDBServer sharedInstance];
    if (server.error) {
      [self failedWithError:server.error];
    }
    self.database = [server databaseNamed:conf.localDbname];
    NSError *error;
    if (![self.database ensureCreated:&error]) {
      [self failedWithError:error];
    }
  }
  [self updateSyncURL];
  [self setupDataSource];
}


- (void)setupDataSource {
  self.dataSource = [[CouchUITableSource alloc] init];
  
  // Create a 'view' containing list items sorted by date:
  CouchDesignDocument* design = [self.database designDocumentWithName: @"default"];
  [design defineViewNamed: @"projects" 
                 mapBlock: ^(NSDictionary* doc, void (^emit)(id key, id value)) {
                   id type = [doc objectForKey: @"type"];
                   if (type && [type isEqualToString:@"project"]) {
                     id _id = [doc objectForKey:@"_id"];
                     emit(_id, doc);
                   }
                 } 
                  version: @"1.0"];
  
  // Create a query sorted by descending date, i.e. newest items first:
  CouchLiveQuery* query = [[[self.database designDocumentWithName: @"default"]
                            queryViewNamed: @"projects"] asLiveQuery];
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


- (void)configurationChanged {
  // invalidate the table view data source
  self.tableView.dataSource = nil;
  [self.tableView reloadData];
  
  [self setupTouchdb];
  
  //self.configurationLabel.text = [[Constants sharedInstance] currentConfiguration].displayName;
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

  gCouchLogLevel = 1;
  
  [self registerDefaults];
  
  [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:kConfigurationDefaultsKey options:NSKeyValueObservingOptionNew context:nil];
  
  [self setupTouchdb];
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
  if (!_objects) {
    _objects = [[NSMutableArray alloc] init];
  }
  [_objects insertObject:[NSDate date] atIndex:0];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Table View


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _objects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
  
  NSDate *object = [_objects objectAtIndex:indexPath.row];
  cell.textLabel.text = [object description];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSDate *object = [_objects objectAtIndex:indexPath.row];
    [[segue destinationViewController] setDetailItem:object];
  }
}


#pragma mark - TouchDB Sync


- (void)updateSyncURL {
  NSLog(@"resetting sync");
  if (!self.database) {
    NSLog(@"no database!");
    return;
  }
  Configuration *conf = [[Globals sharedInstance] currentConfiguration];
  NSLog(@"configuration: %@", conf.displayName);
  NSURL* newRemoteURL = [NSURL URLWithString:conf.remoteUrl];
  
  if (newRemoteURL) {
    [self forgetSync];
    _pull = [self.database pullFromDatabaseAtURL:newRemoteURL];
    _push = [self.database pushToDatabaseAtURL:newRemoteURL];
    _pull.continuous = _push.continuous = YES;
    
    [_pull addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
    [_push addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
  }
}


- (void) forgetSync {
  [_pull removeObserver: self forKeyPath: @"completed"];
  [_pull stop];
  _pull = nil;
  [_push removeObserver: self forKeyPath: @"completed"];
  [_push stop];
  _push = nil;
}


#pragma mark - KVO


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
                         change:(NSDictionary *)change context:(void *)context
{
  if (object == _pull || object == _push) {
    unsigned completed = _pull.completed + _push.completed;
    unsigned total = _pull.total + _push.total;
    NSLog(@"SYNC progress: %u / %u", completed, total);
    //    if (total > 0 && completed < total) {
    //      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //    } else {
    //      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //    }
  } else if (object == [NSUserDefaults standardUserDefaults]) {
    NSLog(@"KVO for %@, new conf: %@", keyPath, [[Globals sharedInstance] currentConfiguration].displayName);
    [self configurationChanged];
  }
}


@end

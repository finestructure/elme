//
//  Database.m
//  elme
//
//  Created by Sven A. Schmidt on 10.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "Database.h"

#import "Configuration.h"
#import "Globals.h"

#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchTouchDBServer.h>


@interface Database () {
  CouchReplication* _pull;
  CouchReplication* _push;
}
@end


@implementation Database

@synthesize database = _database;


+ (id)sharedInstance {
  static dispatch_once_t onceQueue;
  static Database *database = nil;
  
  dispatch_once(&onceQueue, ^{ database = [[self alloc] init]; });
  return database;
}


- (BOOL)connect:(NSError **)outError {
  gCouchLogLevel = 1;

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
      *outError = server.error;
      return NO;
    }
    _database = [server databaseNamed:conf.localDbname];
    NSError *error;
    if (![_database ensureCreated:&error]) {
      *outError = server.error;
      return NO;
    }
  }
  [self updateSyncURL];
  return YES;
}


- (CouchDesignDocument *)designDocumentWithName:(NSString *)name {
  return [self.database designDocumentWithName:name];
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
  }
}


- (void) forgetSync {
  [_pull stop];
  _pull = nil;
  [_push stop];
  _push = nil;
}


@end

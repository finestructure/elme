//
//  Configuration.m
//  Graf
//
//  Created by Sven A. Schmidt on 08.03.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "Configuration.h"

@implementation Configuration

@synthesize name = _name;
@synthesize displayName = _displayName;
@synthesize hostname = _hostname;
@synthesize username = _username;
@synthesize password = _password;
@synthesize port = _port;
@synthesize protocol = _protocol;
@synthesize realm = _realm;
@synthesize dbname = _dbname;
@synthesize localDbname = _localDbname;

- (NSString *)remoteUrl {
  if (self.protocol && self.hostname && self.dbname) {
    if (([self.protocol isEqualToString:@"http"] && self.port == 80)
        || ([self.protocol isEqualToString:@"https"] && self.port == 443)) {
      return [NSString stringWithFormat:@"%@://%@/%@", self.protocol, self.hostname, self.dbname];
    } else {
      return [NSString stringWithFormat:@"%@://%@:%d/%@", self.protocol, self.hostname, self.port, self.dbname];
      
    }
  } else {
    return nil;
  }
}

@end

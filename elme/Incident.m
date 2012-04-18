//
//  Incident.m
//  elme
//
//  Created by Sven A. Schmidt on 10.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "Incident.h"

#import "Globals.h"

@implementation Incident

@dynamic created_at;
@dynamic desc;
@dynamic type;
@dynamic version;
@dynamic unit;

- (id)initWithNewDocumentInDatabase:(CouchDatabase *)database
{
  self = [super initWithNewDocumentInDatabase:database];
  if (self) {
    self.created_at = [NSDate date];
    self.type = @"incident";
    self.version = [[Globals sharedInstance] version];
  }
  return self;
}


@end

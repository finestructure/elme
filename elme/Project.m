//
//  Project.m
//  elme
//
//  Created by Sven A. Schmidt on 04.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "Project.h"

#import "Globals.h"

@implementation Project

@dynamic created_at;
@dynamic desc;
@dynamic name;
@dynamic type;
@dynamic units;
@dynamic version;

- (id)initWithNewDocumentInDatabase:(CouchDatabase *)database
{
  self = [super initWithNewDocumentInDatabase:database];
  if (self) {
    self.created_at = [NSDate date];
    self.type = @"project";
    self.version = [[Globals sharedInstance] version];
  }
  return self;
}


@end

//
//  elmeTests.m
//  elmeTests
//
//  Created by Sven A. Schmidt on 04.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Database.h"
#import "Incident.h"

@interface DatabaseTests : SenTestCase

@end


@implementation DatabaseTests


- (void)setUp
{
  [super setUp];
}


- (void)tearDown
{
  [super tearDown];
}


- (void)test_createIncident
{
  Incident *i = [[Incident alloc] initWithNewDocumentInDatabase:[Database sharedInstance].database];
  CouchQuery *incidents = [[Database sharedInstance] incidents];
  NSUInteger incidentCount = incidents.rows.count;
  
  STAssertNotNil(i, nil);
  i.desc = @"test";
  STAssertEquals(i.desc, @"test", nil);
  
  STAssertEquals(incidents.rows.count, incidentCount, nil);    
}

@end

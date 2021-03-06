//
//  Database.h
//  elme
//
//  Created by Sven A. Schmidt on 10.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CouchDatabase;
@class CouchDesignDocument;
@class CouchQuery;
@class Project;

@interface Database : NSObject

@property (readonly) CouchDatabase *database;

+ (Database *)sharedInstance;
- (BOOL)connect:(NSError **)outError;
- (void)disconnect;
- (CouchDesignDocument *)designDocumentWithName:(NSString *)name;

- (Project *)projectWithId:(NSString *)docId;
- (CouchQuery *)units;
- (CouchQuery *)incidents;

@end

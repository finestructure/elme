//
//  Project.h
//  elme
//
//  Created by Sven A. Schmidt on 04.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <CouchCocoa/CouchCocoa.h>

@interface Project : CouchModel

@property (retain) NSDate *created_at;
@property (copy) NSString *desc;
@property (copy) NSString *name;
@property (copy) NSString *type;
@property (retain) NSArray *units;
@property (copy) NSString *version;

@end

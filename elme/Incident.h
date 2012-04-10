//
//  Incident.h
//  elme
//
//  Created by Sven A. Schmidt on 10.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <CouchCocoa/CouchCocoa.h>

@interface Incident : CouchModel

@property (retain) NSDate *created_at;
@property (copy) NSString *desc;
@property (copy) NSString *type;
@property (copy) NSString *version;

@end

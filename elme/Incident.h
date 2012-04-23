//
//  Incident.h
//  elme
//
//  Created by Sven A. Schmidt on 10.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <CouchCocoa/CouchCocoa.h>

#import "Protocols.h"

@interface Incident : CouchModel

@property (weak, nonatomic) id<DetailItemHandlerDelegate> delegate;

@property (retain) NSDate *created_at;
@property (copy) NSString *desc;
@property (retain) NSArray *imageNames;
@property (copy) NSString *type;
@property (copy) NSString *version;
@property (retain) NSDictionary *unit;

- (void)addImage:(UIImage *)image;
- (void)removeImageAtIndex:(NSUInteger)index;
- (NSArray *)images;

@end

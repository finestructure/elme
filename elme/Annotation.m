//
//  Annotation.m
//  Anjin
//
//  Created by Sven A. Schmidt on 09.07.11.
//  Copyright 2011 abstracture GmbH & Co. KG. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end

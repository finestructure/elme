//
//  Incident.m
//  elme
//
//  Created by Sven A. Schmidt on 10.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "Incident.h"

#import "Globals.h"
#import "NSData+MD5.h"
#import "SOCQ+NSArray.h"


@implementation Incident

@synthesize delegate;
@dynamic craft;
@dynamic created_at;
@dynamic desc;
@dynamic imageNames;
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


- (void)addImage:(UIImage *)image {
  NSData *imageData = UIImagePNGRepresentation(image);
  NSString *imageHash = [imageData MD5];
  NSString *fileName = [NSString stringWithFormat:@"%@.png", imageHash];
  NSArray *imageNames = self.imageNames;
  BOOL imageExists = [imageNames any:^BOOL(id obj) {
    return [fileName isEqualToString:obj];
  }];
  if (! imageExists) {
    [self createAttachmentWithName:fileName type:@"image/png" body:imageData];
    if (self.imageNames != nil) {
      NSMutableArray *newImageNames = [self.imageNames mutableCopy];
      [newImageNames addObject:fileName];
      self.imageNames = newImageNames;
    } else {
      // first image
      self.imageNames = [NSArray arrayWithObject:fileName];
    }
  }
}


- (void)removeImageAtIndex:(NSUInteger)index {
  @try {
    CouchAttachment *attachment = [self.imageAttachments objectAtIndex:index];
    [self removeAttachmentNamed:attachment.name];
  }
  @catch (NSException *exception) {
  }
}


- (NSArray *)imageAttachments {
  NSMutableArray *attachments = [NSMutableArray array];
  for (NSString *fileName in self.imageNames) {
    CouchAttachment* attachment = [self attachmentNamed:fileName];
    if (attachment != nil) {
      [attachments addObject:attachment];
    }
  }
  return attachments;
}


- (NSArray *)images {
  NSMutableArray *images = [NSMutableArray array];
  for (CouchAttachment *attachment in self.imageAttachments) {
    UIImage *image = [[UIImage alloc] initWithData: attachment.body];
    [images addObject:image];
  }
  return images;
}


- (void)didLoadFromDocument {
  NSLog(@"Incident %@ changed", self.document.documentID);
  if ([self.delegate respondsToSelector:@selector(detailItemChangedExternally)]) {
    [self.delegate detailItemChangedExternally];
  }
}


@end

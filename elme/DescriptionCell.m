//
//  DescriptionCell.m
//  elme
//
//  Created by Sven A. Schmidt on 17.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "DescriptionCell.h"

@implementation DescriptionCell

@synthesize delegate = _delegate;
@synthesize textView = _textView;


#pragma mark - UITextViewDelegate


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
  if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
    return YES;
  }
  
  [self.textView resignFirstResponder];
  return NO;
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
  if ([self.delegate respondsToSelector:@selector(detailItemEdited)]) {
    [self.delegate detailItemEdited];
  }
}


- (CGFloat)rowHeight {
  return 70;
}


@end

//
//  DescriptionCell.h
//  elme
//
//  Created by Sven A. Schmidt on 17.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DescriptionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *textView;

- (CGFloat)rowHeight;

@end

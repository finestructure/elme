//
//  ImagesViewController.h
//  elme
//
//  Created by Sven A. Schmidt on 19.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface ImagesViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)takeImage:(id)sender;
- (IBAction)deleteImage:(id)sender;

@end

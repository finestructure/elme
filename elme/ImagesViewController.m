//
//  ImagesViewController.m
//  elme
//
//  Created by Sven A. Schmidt on 19.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "ImagesViewController.h"

@interface ImagesViewController () {
  AVCaptureSession *session;
  AVCaptureStillImageOutput *imageOutput;
}

@end


@implementation ImagesViewController

@synthesize imagePreview = _imagePreview;


#pragma mark - Actions


- (IBAction)takeImage:(id)sender {
}

- (IBAction)deleteImage:(id)sender {
}


#pragma mark - Helpers


- (void)createSession {
  session = [[AVCaptureSession alloc] init];
  session.sessionPreset = AVCaptureSessionPresetMedium;
  
  // set up device
  
  AVCaptureDevice *device =
  [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  
  NSError *error = nil;
  AVCaptureDeviceInput *input =
  [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
  if (input) {
    [session addInput:input];
  } else {
    NSLog(@"error setting up video device");
  }
}


#pragma mark - Init and view lifecycle


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}


- (void)viewDidLoad
{
  [super viewDidLoad];

  // session init
  [self createSession];
  
  // set up output
  imageOutput = [[AVCaptureStillImageOutput alloc] init];
  imageOutput.outputSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
  [session addOutput:imageOutput];
  
  // set up preview
  AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
  CGRect bounds = self.imagePreview.layer.bounds;
  captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
  captureVideoPreviewLayer.bounds = bounds;
  captureVideoPreviewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
  [self.imagePreview.layer addSublayer:captureVideoPreviewLayer];  
  
  // start AV session
  [session startRunning];
}


- (void)viewDidUnload
{
  [self setImagePreview:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end

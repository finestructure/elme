//
//  ImagesViewController.m
//  elme
//
//  Created by Sven A. Schmidt on 19.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "ImagesViewController.h"

#import "GCD.h"
#import "ImagesView.h"
#import "Incident.h"


@interface ImagesViewController () {
  AVCaptureSession *session;
  AVCaptureStillImageOutput *imageOutput;
}

@end


@implementation ImagesViewController

@synthesize detailItem = _detailItem;
@synthesize imagePreview = _imagePreview;
@synthesize imagesView = _imagesView;


#pragma mark - Managing the detail item


- (void)setDetailItem:(id)newDetailItem
{
  if (_detailItem != newDetailItem) {
    _detailItem = newDetailItem;
    
    [self configureView];
  }
}


- (void)configureView
{
  self.imagesView.detailItem = self.detailItem.images;
}


#pragma mark - Actions


- (IBAction)takeImage:(id)sender {
  AVCaptureConnection *connection = [imageOutput connectionWithMediaType:AVMediaTypeVideo];
  [imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef sampleBuffer, NSError *error) {
    UIImage *image = [self convertSampleBufferToUIImage:sampleBuffer];
    if (image != nil) {
      [self.detailItem addImage:image];
      [self configureView];
    }
  }];
}


- (IBAction)deleteImage:(id)sender {
  [self.detailItem removeImageAtIndex:self.imagesView.selectedIndex];
  [self configureView];
}


#pragma mark - Helpers


- (UIImage *)convertSampleBufferToUIImage:(CMSampleBufferRef)sampleBuffer {
  UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
  image = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:UIImageOrientationRight];
  CGSize previewSize = self.imagePreview.frame.size;
  
  CGFloat scale = image.size.width/previewSize.width;
  CGRect cropRect = CGRectMake(0,
                               image.size.height/2 - previewSize.height/2*scale,
                               image.size.width,
                               previewSize.height*scale);
  image = [self cropImage:image toFrame:cropRect];
  NSLog(@"image size: %.0f x %.0f", image.size.width, image.size.height);
  return image;
}


- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
  
  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  // Lock the base address of the pixel buffer.
  CVPixelBufferLockBaseAddress(imageBuffer,0);
  
  // Get the number of bytes per row for the pixel buffer.
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
  // Get the pixel buffer width and height.
  size_t width = CVPixelBufferGetWidth(imageBuffer);
  size_t height = CVPixelBufferGetHeight(imageBuffer);
  
  // Create a device-dependent RGB color space.
  static CGColorSpaceRef colorSpace = NULL;
  if (colorSpace == NULL) {
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
      // Handle the error appropriately.
      return nil;
    }
  }
  
  // Get the base address of the pixel buffer.
  void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
  // Get the data size for contiguous planes of the pixel buffer.
  size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
  
  // Create a Quartz direct-access data provider that uses data we supply.
  CGDataProviderRef dataProvider =
  CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
  // Create a bitmap image from data supplied by the data provider.
  CGImageRef cgImage =
  CGImageCreate(width, height, 8, 32, bytesPerRow,
                colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                dataProvider, NULL, true, kCGRenderingIntentDefault);
  CGDataProviderRelease(dataProvider);
  
  // Create and return an image object to represent the Quartz image.
  UIImage *image = [UIImage imageWithCGImage:cgImage];
  CGImageRelease(cgImage);
  
  CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
  
  return image;
}


- (UIImage *)cropImage:(UIImage *)image toFrame:(CGRect)rect {
  UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.);
  [image drawAtPoint:CGPointMake(-rect.origin.x, -rect.origin.y)
           blendMode:kCGBlendModeCopy
               alpha:1.];
  UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return croppedImage;
}


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

  [GCD runBlockInBackground:^{
    [session startRunning];
  }];
  
  // configure images view
  self.imagesView.growthDirection = kVertical;
  self.imagesView.imageAspectRatio = 4./3.;
  self.imagesView.imagesPerFixedDimension = 4;
  self.imagesView.padding = 4;
  self.imagesView.allowsSelection = YES;
  
  [self configureView];
}


- (void)viewDidUnload
{
  [self setImagePreview:nil];
  [self setImagesView:nil];
  session = nil;
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end

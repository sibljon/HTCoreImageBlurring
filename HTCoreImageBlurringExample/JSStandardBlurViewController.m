//
//  JSViewController.m
//  EarlyBirdBlurGradientTest
//
//  Created by Jonathan Sibley on 7/29/13.
//  Copyright (c) 2013 Jonathan Sibley. All rights reserved.
//

#import "JSStandardBlurViewController.h"
#import "UIImage+HTCoreImageBlurring.h"

@interface JSStandardBlurViewController ()

@property (nonatomic, strong) UIImageView *originalImageView;
@property (nonatomic, strong) UIImageView *processedImageView;

@end

@implementation JSStandardBlurViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"london_eye"]];
    [self.view insertSubview:imageView atIndex:0];
    imageView.frame = self.view.bounds;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.originalImageView = imageView;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];

    [UIImage blurImage:[UIImage imageNamed:@"london_eye"]
            blurRadius:3
             cropInset:7
            completion:^(UIImage *resultImage)
     {
         UIImageView *blurredImageView = [[UIImageView alloc] initWithImage:resultImage];
         [self.view insertSubview:blurredImageView atIndex:0];
         blurredImageView.frame = self.view.bounds;
         blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
         self.processedImageView = blurredImageView;

         self.processedImageView.hidden = YES;
         [self toggleImages];
     }];
}

- (void)tapped:(id)sender
{
    [self toggleImages];
}

- (void)toggleImages
{
    self.originalImageView.hidden = ![self.originalImageView isHidden];
    self.processedImageView.hidden = ![self.processedImageView isHidden];
}

@end

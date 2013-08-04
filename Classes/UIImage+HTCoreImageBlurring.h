//
//  UIImage+HTCoreImageBlurring.h
//  EarlyBirdBlurGradientTest
//
//  Created by Jonathan Sibley on 8/3/13.
//  Copyright (c) 2013 Jonathan Sibley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTCoreImage.h"
#import "CIFilter+HTCICategoryBlur.h"
#import "CIFilter+HTCICategoryGradient.h"
#import "CIFilter+HTCICategoryStylize.h"
#import "CIFilter+HTCICategoryDistortionEffect.h"
#import "CIFilter+HTCICategoryGeometryAdjustment.h"

typedef void (^HTCoreImageBlurCompletion)(UIImage *resultImage);

@interface UIImage (HTCoreImageBlurring)

+ (void)blurImage:(UIImage *)sourceImage
       blurRadius:(CGFloat)blurRadius
         cropInset:(CGFloat)cropInset
gradientMaskBottom:(CGFloat)gradientMaskBottom
   gradientMaskTop:(CGFloat)gradientMaskTop
        completion:(HTCoreImageBlurCompletion)completion;

+ (void)blurImage:(UIImage *)sourceImage
       blurRadius:(CGFloat)blurRadius
        cropInset:(CGFloat)cropInset
       completion:(HTCoreImageBlurCompletion)completion;

@end

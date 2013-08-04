//
//  UIImage+HTCoreImageBlurring.m
//  EarlyBirdBlurGradientTest
//
//  Created by Jonathan Sibley on 8/3/13.
//  Copyright (c) 2013 Jonathan Sibley. All rights reserved.
//

// Loosely based off of: http://blog.caffeine.lu/creating-a-tilt-shift-effect-with-coreimage.html and http://developer.apple.com/library/mac/#documentation/GraphicsImaging/Conceptual/CoreImaging/ci_filer_recipes/ci_filter_recipes.html

#import "UIImage+HTCoreImageBlurring.h"

@implementation UIImage (HTCoreImageBlurring)

#pragma mark - Public

+ (void)blurImage:(UIImage *)sourceImage
       blurRadius:(CGFloat)blurRadius
         cropInset:(CGFloat)cropInset
gradientMaskBottom:(CGFloat)gradientMaskBottom
   gradientMaskTop:(CGFloat)gradientMaskTop
        completion:(HTCoreImageBlurCompletion)completion
{
    UIImage *sourceUIImage = sourceImage;
    CIImage *sourceCIImage = [sourceUIImage toCIImage];

    CGRect sourceImageRect = sourceCIImage.extent;

    NSArray *filters = [[self class] coreImageBlurFilterArrayForRadius:blurRadius cropInset:cropInset sourceImageSize:sourceImageRect.size];

    filters = [filters arrayByAddingObject:[[self class] filterToMaskBlurredImageAndBlendWithSourceImage:sourceCIImage gradientMaskBottom:gradientMaskBottom gradientMaskTop:gradientMaskTop]];

    CIImage *resultImage = [sourceCIImage imageByApplyingFilters:filters];
    [resultImage processToUIImageCompletion:^(UIImage *image)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            completion(image);
                        });
     }];
}

+ (CIFilter *)filterToMaskBlurredImageAndBlendWithSourceImage:(CIImage *)sourceImage
                                            gradientMaskBottom:(CGFloat)gradientMaskBottom
                                           gradientMaskTop:(CGFloat)gradientMaskTop
{
    CGRect sourceImageRect = sourceImage.extent;

    CIFilter *bottomGradient = [CIFilter filterLinearGradientWithPoint0:CGPointMake(0, gradientMaskBottom * sourceImageRect.size.height)
                                                                 point1:CGPointMake(0, gradientMaskTop * sourceImageRect.size.height)
                                                                 color0:[UIColor colorWithRed:0 green:1 blue:0 alpha:1]
                                                                 color1:[UIColor colorWithRed:0 green:1 blue:0 alpha:0]];
    CIFilter *bottomGradientCrop = [CIFilter filterCropWithRect:sourceImageRect];
    CIImage *croppedGradientImage = [bottomGradient.outputImage imageByApplyingFilter:bottomGradientCrop];
    CIFilter *maskBlurredPortionAndBlendWithSourceImage = [CIFilter filterBlendWithMaskWithBackgroundImage:sourceImage maskImage:croppedGradientImage];

    return maskBlurredPortionAndBlendWithSourceImage;
}

+ (void)blurImage:(UIImage *)sourceImage blurRadius:(CGFloat)blurRadius cropInset:(CGFloat)cropInset completion:(HTCoreImageBlurCompletion)completion
{
    UIImage *sourceUIImage = sourceImage;
    CIImage *sourceCIImage = [sourceUIImage toCIImage];

    CGRect sourceImageRect = sourceCIImage.extent;

    NSArray *filters = [[self class] coreImageBlurFilterArrayForRadius:blurRadius cropInset:cropInset sourceImageSize:sourceImageRect.size];

    CIImage *resultImage = [sourceCIImage imageByApplyingFilters:filters];
    [resultImage processToUIImageCompletion:^(UIImage *image)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            completion(image);
                        });
     }];
}

#pragma mark - Private helpers

+ (NSArray *)coreImageBlurFilterArrayForRadius:(CGFloat)blurRadius cropInset:(CGFloat)cropInset sourceImageSize:(CGSize)sourceImageSize
{
    CGRect sourceImageRect = (CGRect) {
        .origin.x = 0,
        .origin.y = 0,
        .size.width = sourceImageSize.width,
        .size.height = sourceImageSize.height
    };
    CGRect cropRect = CGRectInset(sourceImageRect, cropInset * 2, cropInset * 2);

    // Blurring makes the image bigger and adds white borders to the outside.  We need to crop off those white borders.  What we're left with is a slightly zoomed in blurred copy of the source image
    CIFilter *blur = [CIFilter filterGaussianBlurWithRadius:blurRadius];
    CGFloat scaleUpFactor = sourceImageRect.size.width / cropRect.size.width;
    CIFilter *scaleUp = [CIFilter filterLanczosWithScale:scaleUpFactor];
    CGRect scaledUpRect = (CGRect) {
        .origin.x = 0,
        .origin.y = 0,
        .size.width = sourceImageRect.size.width * scaleUpFactor,
        .size.height = sourceImageRect.size.height * scaleUpFactor
    };

    CGRect centeredCropRect = CGRectMake(round(CGRectGetMidX(scaledUpRect) - sourceImageSize.width / 2),
                                  round(CGRectGetMidY(scaledUpRect) - sourceImageSize.height / 2),
                                  sourceImageSize.width,
                                  sourceImageSize.height);

    CIFilter *cropToOriginalSize = [CIFilter filterCropWithRect:centeredCropRect];
    CIFilter *translateBackToOrigin = [CIFilter filterWithAffineTransform:CGAffineTransformMakeTranslation(-centeredCropRect.origin.x, -centeredCropRect.origin.y)];

    return @[blur, scaleUp, cropToOriginalSize, translateBackToOrigin];
}

@end

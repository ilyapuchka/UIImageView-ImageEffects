//
//  COOLBlurImageEffect.h
//  
//
//  Created by Ilya Puchka on 02.11.14.
//  Copyright (c) 2014 Ilya Puchka. All rights reserved.
//

#import "COOLImageEffect.h"

@interface COOLBlurImageEffect : NSObject <COOLImageEffect>

@property (nonatomic) CGFloat blurRadius;
@property (nonatomic, copy) UIColor *tintColor;
@property (nonatomic) CGFloat saturationDeltaFactor;
@property (nonatomic, strong) UIImage *maskImage;

+ (COOLBlurImageEffect *)lightEffect;
+ (COOLBlurImageEffect *)extraLightEffect;
+ (COOLBlurImageEffect *)darkEffect;
+ (COOLBlurImageEffect *)tintEffectWithColor:(UIColor *)tintColor;

+ (COOLBlurImageEffect *)blurEffectWithRadius:(CGFloat)blurRadius
                                    tintColor:(UIColor *)tintColor
                        saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                                    maskImage:(UIImage *)maskImage;

+ (COOLBlurImageEffect *)noBlurDarkEffect;

@end
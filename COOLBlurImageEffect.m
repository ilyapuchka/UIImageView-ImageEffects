//
//  COOLBlurImageEffect.m
//
//
//  Created by Ilya Puchka on 02.11.14.
//  Copyright (c) 2014 Ilya Puchka. All rights reserved.
//

#import "COOLBlurImageEffect.h"
#import "UIImage+ImageEffects.h"

@implementation COOLBlurImageEffect

+ (COOLBlurImageEffect *)lightEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    return [self blurEffectWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

+(COOLBlurImageEffect *)extraLightEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
    return [self blurEffectWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

+ (COOLBlurImageEffect *)darkEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
    return [self blurEffectWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

+ (COOLBlurImageEffect *)tintEffectWithColor:(UIColor *)tintColor
{
    const CGFloat EffectColorAlpha = 0.6;
    UIColor *effectColor = tintColor;
    unsigned long componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
    if (componentCount == 2) {
        CGFloat b;
        if ([tintColor getWhite:&b alpha:NULL]) {
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
    }
    else {
        CGFloat r, g, b;
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    return [self blurEffectWithRadius:10 tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];
}

+ (COOLBlurImageEffect *)blurEffectWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
    COOLBlurImageEffect *effect = [COOLBlurImageEffect new];
    effect.blurRadius = blurRadius;
    effect.tintColor = tintColor;
    effect.saturationDeltaFactor = saturationDeltaFactor;
    effect.maskImage = maskImage;
    return effect;
}

+ (COOLBlurImageEffect *)noBlurDarkEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.0 alpha:0.25];
    return [self blurEffectWithRadius:0 tintColor:tintColor saturationDeltaFactor:0 maskImage:nil];
}

- (UIImage *)applyToImage:(UIImage *)image
{
    return [image applyBlurWithRadius:self.blurRadius tintColor:self.tintColor saturationDeltaFactor:self.saturationDeltaFactor maskImage:self.maskImage];
}

- (NSUInteger)hash
{
    return [@(self.blurRadius) hash] ^ [@(self.saturationDeltaFactor) hash] ^ [self.tintColor hash] ^ [self.maskImage hash];
}

@end

//
//  ARImageEffect.h
//
//
//  Created by Ilya Puchka on 11.08.14.
//  Copyright (c) 2014 Ilya Puchka. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol COOLImageEffect <NSObject>

- (UIImage *)applyToImage:(UIImage *)image;
- (NSUInteger)hash;

@end
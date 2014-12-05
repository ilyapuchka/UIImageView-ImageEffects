//
//  UIImageView+AFNetworking_Effects.h
//
//
//  Created by Ilya Puchka on 11.08.14.
//  Copyright (c) 2014 Ilya Puchka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AfNetworking.h"
#import "COOLImageEffect.h"

@interface UIImageView (AFNetworking_Effects)

- (void)setImageWithURL:(NSURL *)url
               animated:(BOOL)animated;

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
               animated:(BOOL)animated;

- (void)setImageWithURL:(NSURL *)url
                 effect:(id<COOLImageEffect>)effect;

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
                 effect:(id<COOLImageEffect>)effect;

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
                 effect:(id<COOLImageEffect>)effect
               animated:(BOOL)animated;

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                        effect:(id<COOLImageEffect>)effect
                      animated:(BOOL)animated
                       success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, UIImage *))success
                       failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *))failure;

@end

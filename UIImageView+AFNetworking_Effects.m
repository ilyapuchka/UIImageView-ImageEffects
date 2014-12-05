//
//  UIImageView+AFNetworking_Effects.m
//
//
//  Created by Ilya Puchka on 11.08.14.
//  Copyright (c) 2014 Ilya Puchka. All rights reserved.
//

#import "UIImageView+AFNetworking_Effects.h"

@interface COOLDecoratedImageCache: NSCache

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request
                            effect:(id<COOLImageEffect>)effect;

- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request
            effect:(id<COOLImageEffect>)effect;

@end

static inline NSString * COOLDecoratedImageCacheKeyFromURLRequestAndEffect(NSURLRequest *request, id<COOLImageEffect> effect) {
    NSString *key = [[request URL] absoluteString];
    if (effect) {
        key = [key stringByAppendingString:[NSString stringWithFormat:@"%lu", (unsigned long)[effect hash]]];
    }
    return key;
}

@implementation COOLDecoratedImageCache

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request
                            effect:(id<COOLImageEffect>)effect {
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }
    
    return [self objectForKey:COOLDecoratedImageCacheKeyFromURLRequestAndEffect(request, effect)];
}

- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request
            effect:(id<COOLImageEffect>)effect
{
    if (image && request) {
        [self setObject:image forKey:COOLDecoratedImageCacheKeyFromURLRequestAndEffect(request, effect)];
    }
}

@end

@implementation UIImageView (AFNetworking_Effects)

+ (COOLDecoratedImageCache *)sharedDecoratedImageCache
{
    static COOLDecoratedImageCache *_af_defaultImageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _af_defaultImageCache = [[COOLDecoratedImageCache alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_af_defaultImageCache removeAllObjects];
        }];
    });
    return _af_defaultImageCache;
};

+ (dispatch_queue_t)cool_sharedImageDecorationQueue {
    static dispatch_queue_t _cool_sharedImageDecrationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cool_sharedImageDecrationQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    });
    
    return _cool_sharedImageDecrationQueue;
}

- (NSURLRequest *)imageRequestWithURL:(NSURL *)url
{
    if (url.absoluteString.length > 0) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        return [request copy];
    }
    else {
        return nil;
    }
}

- (void)setImageWithURL:(NSURL *)url effect:(id<COOLImageEffect>)effect
{
    [self setImageWithURL:url placeholderImage:nil effect:effect];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage effect:(id<COOLImageEffect>)effect
{
    [self setImageWithURLRequest:[self imageRequestWithURL:url] placeholderImage:placeholderImage effect:effect animated:NO success:nil failure:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage effect:(id<COOLImageEffect>)effect animated:(BOOL)animated
{
    [self setImageWithURLRequest:[self imageRequestWithURL:url] placeholderImage:placeholderImage effect:effect animated:animated success:nil failure:nil];
}

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest placeholderImage:(UIImage *)placeholderImage effect:(id<COOLImageEffect>)effect animated:(BOOL)animated success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, UIImage *))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *))failure
{
    if (effect == nil) {
        [self setImageWithURLRequest:urlRequest placeholderImage:placeholderImage success:success failure:failure];
        return;
    }
    
    if (!urlRequest) {
        [self setImage:placeholderImage animated:animated];
        if (failure)
            failure(nil, nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil]);
        return;
    }

    [self cancelImageRequestOperation];
    
    UIImage *cachedImage = [[[self class] sharedDecoratedImageCache] cachedImageForRequest:urlRequest
                                                                                    effect:effect];
    if (cachedImage) {
        if (success) {
            success(nil, nil, cachedImage);
        } else {
            [self setImage:cachedImage animated:animated];
        }
    }
    else {
        __weak __typeof(self) weakSelf = self;
        [self setImageWithURLRequest:urlRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;

            if (effect) {
                dispatch_async([[strongSelf class] cool_sharedImageDecorationQueue], ^{
                    UIImage *decoretedImage = effect?[effect applyToImage:image]: image;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            success(urlRequest, response, decoretedImage);
                        } else if (decoretedImage) {
                            [strongSelf setImage:decoretedImage animated:animated];
                        }
                        
                        [[[strongSelf class] sharedDecoratedImageCache] cacheImage:decoretedImage
                                                                        forRequest:urlRequest
                                                                            effect:effect];
                    });
                });
            }
            else {
                if (success) success(request, response, image);
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [weakSelf setImage:placeholderImage animated:animated];
            if (failure) failure(request, response, error);
        }];
    }
}

- (void)setImageWithURL:(NSURL *)url animated:(BOOL)animated
{
    [self setImageWithURL:url placeholderImage:nil animated:animated];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage animated:(BOOL)animated
{
    NSURLRequest *request = [self imageRequestWithURL:url];
    
    if (!request) {
        [self setImage:placeholderImage animated:animated];
        return;
    }

    __weak __typeof(self) weakSelf = self;
    [self setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {

        if (animated && request != nil) {
            [weakSelf setImage:image animated:animated];
        }
        else {
            weakSelf.image = image;
        }

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [weakSelf setImage:placeholderImage animated:animated];
    }];
}

- (void)setImage:(UIImage *)image animated:(BOOL)animated
{
    [UIView transitionWithView:self
                      duration:animated?0.25f:0.0f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.image = image;
                    }
                    completion:nil];
}


@end

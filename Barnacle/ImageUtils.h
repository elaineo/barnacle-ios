//
//  ImageUtils.h
//  Barnacle
//
//  Created by Warren Mar on 3/14/14.
//  Copyright (c) 2014 Warren Mar. All rights reserved.
//


@interface ImageUtils : NSObject
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToDimension:(float) largest ;
@end

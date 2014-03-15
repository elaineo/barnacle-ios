//
//  ImageUtils.m
//  Barnacle
//
//  Created by Warren Mar on 3/14/14.
//  Copyright (c) 2014 Warren Mar. All rights reserved.
//

#import "ImageUtils.h"

@implementation ImageUtils


+ (UIImage *)imageWithImage:(UIImage *)image scaledToDimension:(float) largest {
    float width = 1280;
    float height = 960;
    if (image.size.width > image.size.height) {
        width = largest;
        height = image.size.height/image.size.width * width;
    } else {
        height = largest;
        width = image.size.width/image.size.height * height;
    }
    return [ImageUtils imageWithImage:image scaledToSize:CGSizeMake(width, height)];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end

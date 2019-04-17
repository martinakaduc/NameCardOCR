//
//  OpenCVWrapper.h
//  NameCardOCR
//
//  Created by Nguyễn Quang Đức on 3/24/19.
//  Copyright © 2019 Nguyễn Quang Đức. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

    + (NSString *)openCVVersionString;
    + (UIImage *)image2Gray:(UIImage *)inputImage;
    + (UIImage *)imageTransform:(UIImage *)inputImage :(CGPoint [_Nullable])vertec :(bool)expandHeight;
    + (UIImage *)imageRotate:(UIImage *)inputImage :(double)inputAngle;
    + (UIImage *)imageThreshold:(UIImage *)inputImage;
    + (UIImage *)imageDenoise:(UIImage *)inputImage;
//    UIImageToMat(uiImage, imageMat);
//    UIImage* img = MatToUIImage(imageMat);
@end

NS_ASSUME_NONNULL_END

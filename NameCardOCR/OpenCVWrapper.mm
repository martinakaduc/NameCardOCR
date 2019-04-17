//
//  OpenCVWrapper.m
//  NameCardOCR
//
//  Created by Nguyễn Quang Đức on 3/24/19.
//  Copyright © 2019 Nguyễn Quang Đức. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVWrapper.h"

@implementation OpenCVWrapper
    #define PI 3.1415926
    #define HEIGHT_EXPAND 0.2
    + (NSString *)openCVVersionString {
        return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
    }
    
    + (UIImage *)image2Gray:(UIImage *)inputImage {
        cv::Mat cvImage, cvImageGray;
        UIImageToMat(inputImage, cvImage);
        cv::cvtColor(cvImage, cvImageGray, cv::COLOR_BGR2GRAY);
//        cvImageGray = cvImageGray > 100;
        return MatToUIImage(cvImageGray);
    }

    + (UIImage *)imageRotate:(UIImage *)inputImage :(double)inputAngle{
        cv::Mat cvImage, outputImage;
        UIImageToMat(inputImage, cvImage);
        cv::Point2f src_center(cvImage.cols/2.0F, cvImage.rows/2.0F);
        cv::Mat rot_mat = cv::getRotationMatrix2D(src_center, inputAngle, 1.0);
        warpAffine(cvImage, outputImage, rot_mat, cvImage.size());
        return MatToUIImage(outputImage);
    }

    + (UIImage *)imageThreshold:(UIImage *)inputImage {
        cv::Mat cvImage, outputImage;
        UIImageToMat(inputImage, cvImage);
//        cv::GaussianBlur(cvImage, outputImage, cv::Size(5,5), 0);
        cv::threshold(cvImage, outputImage, 0, 255, cv::THRESH_BINARY + cv::THRESH_OTSU);
        return MatToUIImage(outputImage);
    }

    + (UIImage *)imageDenoise:(UIImage *)inputImage {
        cv::Mat cvImage, outputImage;
        UIImageToMat(inputImage, cvImage);
        cv::fastNlMeansDenoisingColored(cvImage, outputImage);
//        cv::fastNlMeansDenoising(cvImage, outputImage);
        return MatToUIImage(outputImage);
    }

    + (UIImage *)imageTransform:(UIImage *)inputImage :(CGPoint [])vertec :(bool)expandHeight{
        cv::Mat cvImage, outputImage;
        UIImageToMat(inputImage, cvImage);
        cvImage = cvImage.t();
        
        CGPoint tl, tr, br, bl;
        bl = vertec[0];
        br = vertec[1];
        tr = vertec[2];
        tl = vertec[3];

        cv::Point2f rect [4];
        rect[3] = cv::Point((1-tl.y)*cvImage.cols, (tl.x)*cvImage.rows);
        rect[2] = cv::Point((1-tr.y)*cvImage.cols, (tr.x)*cvImage.rows);
        rect[1] = cv::Point((1-br.y)*cvImage.cols, (br.x)*cvImage.rows);
        rect[0] = cv::Point((1-bl.y)*cvImage.cols, (bl.x)*cvImage.rows);

        double widthA = sqrt(pow((br.x - bl.x)*cvImage.rows, 2) + pow((br.y - bl.y)*cvImage.cols, 2));
        double widthB = sqrt(pow((tr.x - tl.x)*cvImage.rows, 2) + pow((tr.y - tl.y)*cvImage.cols, 2));
        int maxWidth = fmax(int(widthA), int(widthB));

        double heightA = sqrt(pow((tr.x - br.x)*cvImage.rows, 2) + pow((tr.y - br.y)*cvImage.cols, 2));
        double heightB = sqrt(pow((tl.x - bl.x)*cvImage.rows, 2) + pow((tl.y - bl.y)*cvImage.cols, 2));
        int maxHeight = fmax(int(heightA), int(heightB));
        
        cv::Point2f dst[4];
        dst[0] = cv::Point(0, 0);
        dst[1] = cv::Point(maxWidth, 0);
        dst[2] = cv::Point(maxWidth, maxHeight*(1-HEIGHT_EXPAND*expandHeight));
        dst[3] = cv::Point(0, maxHeight*(1-HEIGHT_EXPAND*expandHeight));

        cv::Mat M = cv::getPerspectiveTransform(rect, dst);
        cv::warpPerspective(cvImage, outputImage, M, {maxWidth, maxHeight});
        
        
        return MatToUIImage(outputImage);
    }
    
@end


//
//  OpenCVWrapper.mm
//  ImageProcessing
//
//  Created by Tarek on 12/3/20.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>

#import "ImageProcessing-Bridging-Header.h"

/*
 * add a method convertToMat to UIImage class
 */
@interface UIImage (OpenCVWrapper)
- (void)convertToMat: (cv::Mat *)pMat;
@end

//@interface NSData (OpenCVWrapper)
//- (cv::Mat)CVMat;
//@end
//
//@interface NSData (OpenCVWrapper)
//- (NSData *)NSDataFromCVMat:(cv::Mat)cvMat;
//@property(nonatomic, readonly) cv::Mat CVMat;
//@property(nonatomic, readonly) cv::Mat CVGrayscaleMat;
//@end

//@implementation NSData (OpenCVWrapper)
//// cv::Mat from NSMutableData
//- (cv::Mat)CVMat {
//
//    UIImage *image = [UIImage imageWithData:self];
//
//    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
//    CGFloat cols = image.size.width;
//    CGFloat rows = image.size.height;
//
//    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
//
//    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
//                                                    cols,                       // Width of bitmap
//                                                    rows,                       // Height of bitmap
//                                                    8,                          // Bits per component
//                                                    cvMat.step[0],              // Bytes per row
//                                                    colorSpace,                 // Colorspace
//                                                    kCGImageAlphaNoneSkipLast |
//                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
//
//    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
//    CGContextRelease(contextRef);
//
//    return cvMat;
//}
//
//- (cv::Mat)CVGrayscaleMat {
//
//    UIImage *image = [UIImage imageWithData:self];
//
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
//    CGFloat cols = image.size.width;
//    CGFloat rows = image.size.height;
//
//    cv::Mat cvMat = cv::Mat(rows, cols, CV_8UC1); // 8 bits per component, 1 channel
//
//    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
//                                                    cols,                       // Width of bitmap
//                                                    rows,                       // Height of bitmap
//                                                    8,                          // Bits per component
//                                                    cvMat.step[0],              // Bytes per row
//                                                    colorSpace,                 // Colorspace
//                                                    kCGImageAlphaNone |
//                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
//
//    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
//    CGContextRelease(contextRef);
//    CGColorSpaceRelease(colorSpace);
//
//    return cvMat;
//}
//
//// NSData from cv::Mat
//- (NSData *)NSDataFromCVMat:(cv::Mat)cvMat {
//    return [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
//}
//
//@end

@implementation UIImage (OpenCVWrapper)
- (void)convertToMat: (cv::Mat *)pMat {
    if (self.imageOrientation == UIImageOrientationRight) {
        /*
         * When taking picture in portrait orientation,
         * convert UIImage to OpenCV Matrix in landscape right-side-up orientation,
         * and then rotate OpenCV Matrix to portrait orientation
         */
        UIImageToMat([UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUp], *pMat);
        cv::rotate(*pMat, *pMat, cv::ROTATE_90_CLOCKWISE);
    } else if (self.imageOrientation == UIImageOrientationLeft) {
        /*
         * When taking picture in portrait upside-down orientation,
         * convert UIImage to OpenCV Matrix in landscape right-side-up orientation,
         * and then rotate OpenCV Matrix to portrait upside-down orientation
         */
        UIImageToMat([UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUp], *pMat);
        cv::rotate(*pMat, *pMat, cv::ROTATE_90_COUNTERCLOCKWISE);
    } else {
        /*
         * When taking picture in landscape orientation,
         * convert UIImage to OpenCV Matrix directly,
         * and then ONLY rotate OpenCV Matrix for landscape left-side-up orientation
         */
        UIImageToMat(self, *pMat);
        if (self.imageOrientation == UIImageOrientationDown) {
            cv::rotate(*pMat, *pMat, cv::ROTATE_180);
        }
    }
}
@end


/*
 *  class methods to execute OpenCV operations
 */
@implementation OpenCVWrapper : NSObject

+ (UIImage *)cannyEdgeImage:(UIImage *)image {
    cv::Mat mat;
    [image convertToMat: &mat];

    cv::Mat gray, blur, edge;
    if (mat.channels() > 1) {
        cv::cvtColor(mat, gray, cv::COLOR_RGB2GRAY);
    } else {
        mat.copyTo(gray);
    }

    cv::GaussianBlur(gray, blur, cv::Size(5, 5), 3, 3);

    cv::Canny(blur, edge, 20, 20 * 3, 3);

    UIImage *edgeImg = MatToUIImage(edge);
    return edgeImg;
}

@end

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject
+ (UIImage *)cannyEdgeImage:(UIImage *)image;
@end

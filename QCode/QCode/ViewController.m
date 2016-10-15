//
//  ViewController.m
//  QCode
//
//  Created by hu lianghai on 2016/10/14.
//  Copyright © 2016年 buffalo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    imageView.center = self.view.center;
    [imageView setImage:[self createQRCodeWithString:@"www.baidu.com" withSize:CGSizeMake(300, 300)] ];
    [self.view addSubview:imageView];
}

// 创建二维码
- (UIImage *)createQRCodeWithString:(NSString *)contextStr withSize:(CGSize)size{
    NSData *data = [contextStr dataUsingEncoding:NSUTF8StringEncoding];
    // 创建滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    [filter setValue:data forKey:@"inputMessage"];// 设置输入内容也就是二维码代表的内容
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];// 设置二维码的纠错水平
    CIImage *outPutImage = [filter outputImage];// 二维码输出图 太模糊
    return [self createColorUIImageFromCIImage:outPutImage withImageSize:size];
}

// 没有logo的二维码
- (UIImage *)createNoLogoUIImageFromCIImage:(CIImage *)ciimage withImageSize:(CGSize)imageSize {
    CGRect extent = CGRectIntegral(ciimage.extent);// 二维码图范围
    CGFloat scale = MIN(imageSize.width / CGRectGetWidth(extent), imageSize.height / CGRectGetHeight(extent));// 获得最小的放大比例
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:ciimage fromRect:extent];
    CGContextRef contextRef =CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);//  图像绘制上下文
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    CGContextScaleCTM(contextRef, scale, scale);
    CGContextDrawImage(contextRef, extent, imageRef);
    CGImageRef scaledImage = CGBitmapContextCreateImage(contextRef);
    CGContextRelease(contextRef);
    CGImageRelease(imageRef);
    return [UIImage imageWithCGImage:scaledImage];
}

// 包含logo的二维码
- (UIImage *)createLogoUIImageFromCIImage:(CIImage *)ciimage withImageSize:(CGSize)imageSize {
    UIImage *image = [self createNoLogoUIImageFromCIImage:ciimage withImageSize:imageSize];
    UIImage *logoImage = [UIImage imageNamed:@"tree"];
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
    [image drawInRect:CGRectMake(0, 0, 300, 300)];
    CGFloat logoSize = 50;
    [logoImage drawInRect:CGRectMake((300 - logoSize) / 2, (300 - logoSize) / 2, logoSize, logoSize)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// 彩色二维码
- (UIImage *)createColorUIImageFromCIImage:(CIImage *)ciimage withImageSize:(CGSize)imageSize {
//    UIImage *image = [self createNoLogoUIImageFromCIImage:ciimage withImageSize:imageSize];
//    CIImage *cimage = [image CIImage];
    // 添加颜色滤镜
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"];
    [colorFilter setDefaults];
    [colorFilter setValue:ciimage forKey:@"inputImage"];
    [colorFilter setValue:[CIColor redColor] forKey:@"inputColor0"];// 二维码颜色
    [colorFilter setValue:[CIColor whiteColor] forKey:@"inputColor1"];// 二维码底色
    CIImage *outPutImage = [colorFilter outputImage];
    return [UIImage imageWithCIImage:outPutImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

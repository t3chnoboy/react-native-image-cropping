#import "ReactNativeImageCropping.h"
#import <UIKit/UIKit.h>
#import "TOCropViewController.h"
#import <React/RCTConvert.h>
#import <React/RCTImageLoader.h>

@interface ReactNativeImageCropping () <TOCropViewControllerDelegate>

@property (nonatomic, strong) RCTPromiseRejectBlock _reject;
@property (nonatomic, strong) RCTPromiseResolveBlock _resolve;
@property TOCropViewControllerAspectRatioPreset aspectRatio;


@end

@implementation RCTConvert (AspectRatio)
RCT_ENUM_CONVERTER(TOCropViewControllerAspectRatioPreset, (@{
            @"AspectRatioOriginal" : @(TOCropViewControllerAspectRatioPresetOriginal),
              @"AspectRatioSquare" : @(TOCropViewControllerAspectRatioPresetSquare),
                 @"AspectRatio3x2" : @(TOCropViewControllerAspectRatioPreset3x2),
                 @"AspectRatio5x3" : @(TOCropViewControllerAspectRatioPreset5x3),
                 @"AspectRatio4x3" : @(TOCropViewControllerAspectRatioPreset4x3),
                 @"AspectRatio5x4" : @(TOCropViewControllerAspectRatioPreset5x4),
                 @"AspectRatio7x5" : @(TOCropViewControllerAspectRatioPreset7x5),
                @"AspectRatio16x9" : @(TOCropViewControllerAspectRatioPreset16x9)
                }), UIStatusBarAnimationNone, integerValue)
@end

@implementation ReactNativeImageCropping

RCT_EXPORT_MODULE()


@synthesize bridge = _bridge;

- (NSDictionary *)constantsToExport
{
    return @{
   @"AspectRatioOriginal" : @(TOCropViewControllerAspectRatioPresetOriginal),
     @"AspectRatioSquare" : @(TOCropViewControllerAspectRatioPresetSquare),
        @"AspectRatio3x2" : @(TOCropViewControllerAspectRatioPreset3x2),
        @"AspectRatio5x3" : @(TOCropViewControllerAspectRatioPreset5x3),
        @"AspectRatio4x3" : @(TOCropViewControllerAspectRatioPreset4x3),
        @"AspectRatio5x4" : @(TOCropViewControllerAspectRatioPreset5x4),
        @"AspectRatio7x5" : @(TOCropViewControllerAspectRatioPreset7x5),
       @"AspectRatio16x9" : @(TOCropViewControllerAspectRatioPreset16x9),
    };
}

RCT_EXPORT_METHOD(  cropImageWithUrl:(NSString *)imageUrl
                    resolver:(RCTPromiseResolveBlock)resolve
                    rejecter:(RCTPromiseRejectBlock)reject

)
{
    self._reject = reject;
    self._resolve = resolve;
    self.aspectRatio = NULL;

    NSString *fileURL = [[NSURL alloc] initFileURLWithPath:imageUrl].absoluteString;

    NSURLRequest *imageUrlrequest = [NSURLRequest requestWithURL:[NSURL URLWithString:fileURL]];

    [self.bridge.imageLoader loadImageWithURLRequest:imageUrlrequest callback:^(NSError *error, UIImage *image) {
        if(error) reject(@"100", @"Failed to load image", error);
        if(image) {
            [self handleImageLoad:image];
        }
    }];
}

RCT_EXPORT_METHOD(cropImageWithUrlAndAspect:(NSString *)imageUrl
                                aspectRatio:(TOCropViewControllerAspectRatioPreset)aspectRatio
                                   resolver:(RCTPromiseResolveBlock)resolve
                                   rejecter:(RCTPromiseRejectBlock)reject
        )
{
    self._reject = reject;
    self._resolve = resolve;
    self.aspectRatio = aspectRatio;

    NSString *fileURL = [[NSURL alloc] initFileURLWithPath:imageUrl].absoluteString;

    NSURLRequest *imageUrlrequest = [NSURLRequest requestWithURL:[NSURL URLWithString:fileURL]];

    [self.bridge.imageLoader loadImageWithURLRequest:imageUrlrequest callback:^(NSError *error, UIImage *image) {
        if(error) reject(@"100", @"Failed to load image", error);
        if(image) {
            [self handleImageLoad:image];
        }
    }];

}

- (void)handleImageLoad:(UIImage *)image {

    UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:image];
    cropViewController.delegate = self;

    if(self.aspectRatio) {
        cropViewController.aspectRatioLockEnabled = YES;
        cropViewController.aspectRatioPreset = self.aspectRatio;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [root presentViewController:cropViewController animated:YES completion:nil];
    });
}

/**
 Called when the user has committed the crop action, and provides both the original image with crop co-ordinates.

 @param image The newly cropped image.
 @param cropRect A rectangle indicating the crop region of the image the user chose (In the original image's local co-ordinate space)
 */
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [cropViewController dismissViewControllerAnimated:YES completion:nil];
    });

    NSData *jpgData = UIImageJPEGRepresentation(image, 90);
    NSString *fileName = [NSString stringWithFormat:@"resized-%lf.jpg", [NSDate timeIntervalSinceReferenceDate]];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    [jpgData writeToFile:filePath atomically:YES];
    NSNumber *width  = [NSNumber numberWithFloat:image.size.width];
    NSNumber *height = [NSNumber numberWithFloat:image.size.height];

    NSDictionary * imageData = @{
                             @"uri":filePath,
                             @"width":width,
                             @"height":height
                             };
    self._resolve(imageData);
}
/**
 If implemented, when the user hits cancel, or completes a UIActivityViewController operation, this delegate will be called,
 giving you a chance to manually dismiss the view controller

 */
- (void)cropViewController:(TOCropViewController *)cropViewController didFinishCancelled:(BOOL)cancelled
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [cropViewController dismissViewControllerAnimated:YES completion:nil];
    });
    self._reject(@"400", @"Cancelled", [NSError errorWithDomain:@"Cancelled" code:400 userInfo:NULL]);
}
@end

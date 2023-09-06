//
//  BadgerCustomImageViewController.h
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/16/22.
//

#import <UIKit/UIKit.h>
#import "BadgerEasyTranslations.h"

NS_ASSUME_NONNULL_BEGIN

@interface BadgerCustomImageViewController : BadgerViewController
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
@end

NS_ASSUME_NONNULL_END

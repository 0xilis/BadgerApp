//
//  BadgeColorViewController.h
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/6/22.
//

#import <UIKit/UIKit.h>
#import "BadgerEasyTranslations.h"

NS_ASSUME_NONNULL_BEGIN

@interface BadgeColorViewController : BadgerViewController
UIColor *matchingLabelColor(NSString *color);
UIFont *fontFromFile(NSString* filePath, CGFloat fontSize);
UIColor* colorFromHexString(NSString* hexString);
@end

NS_ASSUME_NONNULL_END

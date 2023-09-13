//
//  BadgeColorViewController.h
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/6/22.
//

#import <UIKit/UIKit.h>
#import "BadgerEasyTranslations.h"
#import <CoreText/CTFont.h>
#import <CoreText/CTFontDescriptor.h>
#import <CoreText/CTFontManager.h>
#include <objc/runtime.h>
#include <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

@interface BadgeColorViewController : BadgerViewController
-(UIColor*)matchingLabelColor:(NSString*)color;
UIFont *fontFromFile(NSString* filePath, CGFloat fontSize);
UIColor* colorFromHexString(NSString* hexString);
UIFont *fontFromDesc(CTFontDescriptorRef desc, CGFloat size);
@end

NS_ASSUME_NONNULL_END

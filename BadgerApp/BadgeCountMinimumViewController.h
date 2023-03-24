//
//  MaximumViewController.h
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/5/22.
//

#import <UIKit/UIKit.h>
#import "BadgerEasyTranslations.h"

NS_ASSUME_NONNULL_BEGIN

@interface BadgeCountMinimumViewController : UIViewController<UITextViewDelegate, UITextFieldDelegate>
@property (nonatomic, assign) NSString* appName;
@property (nonatomic, assign) NSString* appBundleID;
@property (nonatomic, assign, readwrite) NSString* cellTitle;
@property (nonatomic, assign, readwrite) long badgeCount;
@end

NS_ASSUME_NONNULL_END

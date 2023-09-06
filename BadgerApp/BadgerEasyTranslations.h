//
//  BadgerEasyTranslations.h
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/27/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

NSString *trans(NSString *orig);

@interface BadgerViewController : UIViewController
@property (nonatomic, assign) NSString* appName;
@property (nonatomic, assign) NSString* appBundleID;
@property (nonatomic, assign, readwrite) long badgeCount;
@end

extern NSString *daCellTitle;
extern UIView *topTopNotchCoverView;

NS_ASSUME_NONNULL_END

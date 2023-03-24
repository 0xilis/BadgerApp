//
//  BadgerCountConfigManagerViewController.h
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/12/22.
//

#import <UIKit/UIKit.h>
#import "BadgerEasyTranslations.h"

NS_ASSUME_NONNULL_BEGIN

@interface BadgerCountConfigManagerViewController : UIViewController
@property (nonatomic, assign) NSString* appName;
@property (nonatomic, assign) NSString* appBundleID;
@property (nonatomic, assign, readwrite) NSString* cellTitle;
-(void)deleteRowWithTitle:(NSString *)rowTitle;
-(void)completeCountConfig:(NSString *)countConfig;
-(void)resetDefault:(NSString *)rowTitle;
void deleteRowWithTitle(NSString *rowTitle);
void resetDefault(NSString *rowTitle);
@end

NS_ASSUME_NONNULL_END

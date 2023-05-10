//
//  BadgerTopNotchCoverView.h
//  BadgerApp
//
//  Created by Snoolie Keffaber on 5/4/3.
//

#import <UIKit/UIKit.h>

@interface BadgerTopNotchCoverView : UIView
-(void)disappear;
-(void)reappear;
+(BadgerTopNotchCoverView*)findViewInNavBar:(UIView*)navBarView;
+(void)disappear:(UIView*)navBarView;
+(void)reappear:(UIView*)navBarView;
@end

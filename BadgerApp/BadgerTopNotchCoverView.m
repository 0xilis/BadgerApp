//
//  BadgerTopNotchCoverView.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 5/4/23.
//

#import <UIKit/UIKit.h>
#import "BadgerTopNotchCoverView.h"

@implementation BadgerTopNotchCoverView
-(void)disappear {
    [self setHidden:YES];
}
-(void)reappear {
    [self setHidden:NO];
}
+(BadgerTopNotchCoverView*)findViewInNavBar:(UIView*)navBarView {
    for (id daView in [navBarView subviews]) {
        if ([daView isMemberOfClass:[BadgerTopNotchCoverView class]]) {
            return daView;
        }
    }
    return NULL;
}
+(void)disappear:(UIView*)navBarView {
    BadgerTopNotchCoverView* daView = [BadgerTopNotchCoverView findViewInNavBar:navBarView];
    if (daView) {
        [daView disappear];
    }
}
+(void)reappear:(UIView*)navBarView {
    BadgerTopNotchCoverView* daView = [BadgerTopNotchCoverView findViewInNavBar:navBarView];
    if (daView) {
        [daView reappear];
    }
}
@end

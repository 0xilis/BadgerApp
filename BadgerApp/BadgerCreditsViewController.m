//
//  BadgerCreditsViewController.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 8/26/22.
//

#import "BadgerCreditsViewController.h"
#import "BadgerEasyTranslations.h"

@interface BadgerCreditsViewController ()

@end

@implementation BadgerCreditsViewController
- (void)viewDidLoad {
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor]; //if dark mode this looks weird in app selection
    [[self credits]setText:trans(@"Credits:\nDevelopers\nSnoolie (QuickUpdateShortcutSupport@protonmail.com, @QuickUpdate5 Twitter, u/0xilis reddit, 0xilis GitHub)\n\n\nTranslators:\nGerman - lost\nChinese - u/vincent0408")];
}

@end

//
//  BadgerCreditsViewController.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 8/26/22.
//

#import "BadgerCreditsViewController.h"
#import "BadgerEasyTranslations.h"
#import "BadgeColorViewController.h"

@interface BadgerCreditsViewController ()

@end

@implementation BadgerCreditsViewController
- (void)viewDidLoad {
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor]; //if dark mode this looks weird in app selection
    [[self credits]setText:trans(@"Credits:\nDevelopers\nSnoolie (QuickUpdateShortcutSupport@protonmail.com, @QuickUpdate5 Twitter, u/0xilis reddit, 0xilis GitHub)\n\n\nTranslators:\nGerman - lost\nChinese - u/vincent0408")];
    CAGradientLayer* betterBackGd = [[CAGradientLayer alloc]init];
    //ROrangeGrad.png
    [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"FFA959").CGColor, (id)colorFromHexString(@"FF5B51").CGColor, nil]];
    [betterBackGd setStartPoint:CGPointMake(0, 0)];
    [betterBackGd setEndPoint:CGPointMake(1, 1)];
    [betterBackGd setFrame:[[self view] bounds]]; //CGRectMake(0, 0, [[self view]frame].size.width, [[self view]frame].size.height)
    [betterBackGd setType:kCAGradientLayerAxial];
    [[[self view]layer]insertSublayer:betterBackGd atIndex:0];
}

@end

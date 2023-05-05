//
//  ViewController.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 8/26/22.
//

#import "BadgerApplySettingsViewController.h"
#import "BadgerEasyTranslations.h"
#import "BadgeColorViewController.h"

@interface BadgerApplySettingsViewController ()

@end

@implementation BadgerApplySettingsViewController
- (void)viewDidLoad {
    [_respringButton.layer setCornerRadius:5.0];
    [_respringButton setAlpha:0.5];
    [_explainingBox setAlpha:0.5];
    [_label setAlpha:0.5];
    [_respringButton setTitle:trans(@"Respring") forState:UIControlStateNormal];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor]; //if dark mode this looks weird in app selection
    [_explainingBox setText:trans(@"With ♡ from Snoolie. Reach out to me by email at QuickUpdateShortcutSupport@protonmail.com, @QuickUpdate5 on Twitter, and u/0xilis on reddit.")];
    CAGradientLayer* betterBackGd = [[CAGradientLayer alloc]init];
    //RRedGrad.png
    [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"FF4A3F").CGColor, (id)colorFromHexString(@"FF5185").CGColor, nil]];
    [betterBackGd setStartPoint:CGPointMake(0, 0)];
    [betterBackGd setEndPoint:CGPointMake(1, 1)];
    [betterBackGd setFrame:[[self view] bounds]]; //CGRectMake(0, 0, [[self view]frame].size.width, [[self view]frame].size.height)
    [betterBackGd setType:kCAGradientLayerAxial];
    [[[self view]layer]insertSublayer:betterBackGd atIndex:0];
}

- (IBAction)respringButtonPressed:(id)sender {
    //TODO: When porting to iOS 10 and below not all older jailbreaks have sbreload
    pid_t pid;
    /*
     Commented out due to PATH not referring to /var/jb on some rootless jbs, so posix_spawnp won't work :(
    const char *args[] = {"sbreload", NULL, NULL, NULL};
    posix_spawnp(&pid, "sbreload", NULL, NULL, (char *const *)args, NULL);
     */
    FILE *file;
    const char* args[] = {"sbreload", NULL};
    //Rootless
    if ((file = fopen("/var/jb/usr/bin/sbreload","r"))) {
        fclose(file);
        posix_spawn(&pid, "/var/jb/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);
    } else {
        //Rootful (iOS 11+)
        if ((file = fopen("/usr/bin/sbreload","r"))) {
            fclose(file);
            posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);
        } else {
            NSLog(@"Error: sbreload not found!");
        }
    }
}
@end

//
//  MaximumViewController.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/5/22.
//

#import "ViewController.h"
#import "BadgeCountMinimumViewController.h"
#import "BadgerAppSelectionViewController.h"
#include "BadgerPrefHandler.h"

NSString *badgeSetting;
UISlider *slider;

@interface BadgeCountMinimumViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UITextField *numberField;
@property (weak, nonatomic) IBOutlet UITextView *explainingBox;
@property (weak, nonatomic) IBOutlet UIImageView *backgd;
@property (weak, nonatomic) IBOutlet UILabel *appLabel;
@property (weak, nonatomic) IBOutlet UILabel *label;
-(void)sliderChange:(id)sender;
@end

@implementation BadgeCountMinimumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_numberField setReturnKeyType:UIReturnKeyDone];
    _numberField.delegate = self;
    [_numberField setAlpha:0.5];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor]; //if dark mode this looks weird in app selection 
    NSLog(@"%@", [self cellTitle]);
    if ([[self cellTitle]isEqualToString:trans(@"Badge Count Minimum")]) {
        _backgd.image = [UIImage imageNamed:@"RRedGrad.png"];
        _appLabel.hidden = 1;
        [_label setText:trans(@"Badge Count Minimum")];
        [_explainingBox setText:trans(@"This affects the minimum badge count for all applications, universally throughout the system, with the exception if you set a custom amount for a specific app/apps.")];
        badgeSetting = @"minimum";
        if (badgerRetriveUniversalPref(@"BadgeCountMinimum")) {
            _numberField.text = badgerRetriveUniversalPref(@"BadgeCountMinimum");
        }
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Count Minimum for App")]) {
        _backgd.image = [UIImage imageNamed:@"ROrangeGrad.png"];
        _appLabel.hidden = 0;
        _appLabel.text = [self appName];
        [_label setText:trans(@"Badge Count Minimum")];
        [_explainingBox setText:[trans(@"This affects the minimum badge count for (APPNAME).") stringByReplacingOccurrencesOfString:@"(APPNAME)" withString:[self appName]]];
        badgeSetting = @"minimum";
        if (badgerRetriveAppPref([self appBundleID],@"BadgeCountMinimum")) {
            _numberField.text = badgerRetriveAppPref([self appBundleID],@"BadgeCountMinimum");
        }
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Count Limit")]) {
        _backgd.image = [UIImage imageNamed:@"RYellowGrad.png"];
        _appLabel.hidden = 1;
        [_label setText:trans(@"Badge Count Limit")];
        [_explainingBox setText:trans(@"This affects the badge count limit for all applications, universally throughout the system, with the exception if you set a custom limit for a specific app/apps.")];
        badgeSetting = @"limit";
        if (badgerRetriveUniversalPref(@"BadgeCountLimit")) {
            _numberField.text = badgerRetriveUniversalPref(@"BadgeCountLimit");
        }
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Count Limit for App")]) {
        _backgd.image = [UIImage imageNamed:@"RGreenGrad.png"];
        _appLabel.hidden = 0;
        _appLabel.text = [self appName];
        [_label setText:@"Badge Count Limit"];
        [_explainingBox setText:[trans(@"This affects the badge count limit for (APPNAME).") stringByReplacingOccurrencesOfString:@"(APPNAME)" withString:[self appName]]];
        badgeSetting = @"limit";
        if (badgerRetriveAppPref([self appBundleID],@"BadgeCountLimit")) {
            _numberField.text = badgerRetriveAppPref([self appBundleID],@"BadgeCountLimit");
        }
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Opacity")] || [[self cellTitle]isEqualToString:trans(@"Badge Opacity for App")]) {
        _appLabel.hidden = 1;
        [_label setText:trans(@"Badge Opacity")];
        [_explainingBox setText:trans(@"This affects the badge opacity for notification badges.")];
        badgeSetting = @"opacity";
        slider = [[UISlider alloc]initWithFrame:CGRectMake(20, UIScreen.mainScreen.bounds.size.height / 2, UIScreen.mainScreen.bounds.size.width - 40, 40)];
        [slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
        [slider setMaximumValue:100];
        [slider setTintColor:[UIColor orangeColor]];
        [slider setAlpha:0.5];
        [self.view addSubview:slider];
        if ([self appBundleID]) {
            _backgd.image = [UIImage imageNamed:@"ROrangeGrad.png"];
            if ([self badgeCount]) {
                NSString *BadgeOpacity = badgerRetriveAppCountPref([self badgeCount],[self appBundleID],@"BadgeOpacity");
                if (BadgeOpacity) {
                    _numberField.text = [NSString stringWithFormat:@"%@%%",BadgeOpacity];
                    _numberField.subviews[0].alpha = [badgerRetriveAppCountPref([self badgeCount],[self appBundleID],@"BadgeOpacity") floatValue] / 100;
                    [slider setValue:[badgerRetriveAppCountPref([self badgeCount],[self appBundleID],@"BadgeOpacity") integerValue]];
                } else {
                    _numberField.text = @"100%";
                    [slider setValue:100];
                }
            } else {
                NSString *BadgeOpacity = badgerRetriveAppPref([self appBundleID],@"BadgeOpacity");
                if (BadgeOpacity) {
                    _numberField.text = [NSString stringWithFormat:@"%@%%",BadgeOpacity];
                    _numberField.subviews[0].alpha = [badgerRetriveAppPref([self appBundleID],@"BadgeOpacity") floatValue] / 100;
                    [slider setValue:[badgerRetriveAppPref([self appBundleID],@"BadgeOpacity") integerValue]];
                } else {
                    _numberField.text = @"100%";
                    [slider setValue:100];
                }
            }
        } else {
            _backgd.image = [UIImage imageNamed:@"RRedGrad.png"];
            if ([self badgeCount]) {
                NSString *BadgeOpacity = badgerRetriveUniversalCountPref([self badgeCount],@"BadgeOpacity");
                if (BadgeOpacity) {
                    _numberField.text = [NSString stringWithFormat:@"%@%%",BadgeOpacity];
                    _numberField.subviews[0].alpha = [badgerRetriveUniversalCountPref([self badgeCount],@"BadgeOpacity") floatValue] / 100;
                    [slider setValue:[badgerRetriveUniversalCountPref([self badgeCount],@"BadgeOpacity") integerValue]];
                } else {
                    _numberField.text = @"100%";
                    [slider setValue:100];
                }
            } else {
                NSString *BadgeOpacity = badgerRetriveUniversalPref(@"BadgeOpacity");
                if (BadgeOpacity) {
                    _numberField.text = [NSString stringWithFormat:@"%@%%",BadgeOpacity];
                    _numberField.subviews[0].alpha = [badgerRetriveUniversalPref(@"BadgeOpacity") floatValue] / 100;
                    [slider setValue:[badgerRetriveUniversalPref(@"BadgeOpacity") integerValue]];
                } else {
                    _numberField.text = @"100%";
                    [slider setValue:100];
                }
            }
        }
    } else if ([[self cellTitle]isEqualToString:trans(@"Custom Badge Label")]) {
        _backgd.image = [UIImage imageNamed:@"ROrangeGrad.png"];
        _appLabel.hidden = 1;
        [_label setText:trans(@"Custom Badge Label")];
        [_explainingBox setText:trans(@"Set a custom label for notification badges.")];
        badgeSetting = @"label";
        NSString *BadgeLabel;
        if ([self badgeCount]) {
            BadgeLabel = badgerRetriveUniversalCountPref([self badgeCount],@"BadgeLabel");
        } else {
            BadgeLabel = badgerRetriveUniversalPref(@"BadgeLabel");
        }
        if (BadgeLabel) {
            _numberField.text = [NSString stringWithFormat:@"%@",BadgeLabel];
        } else {
            _numberField.text = @"";
        }
        _numberField.placeholder = trans(@"Enter label...");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Size")] || [[self cellTitle]isEqualToString:trans(@"Badge Size for App")]) {
        _appLabel.hidden = 1;
        [_label setText:trans(@"Badge Size")];
        [_explainingBox setText:trans(@"This affects the badge size for notification badges.")];
        badgeSetting = @"size";
        slider = [[UISlider alloc]initWithFrame:CGRectMake(20, UIScreen.mainScreen.bounds.size.height / 2, UIScreen.mainScreen.bounds.size.width - 40, 40)];
        [slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
        [slider setMaximumValue:200];
        [slider setMinimumValue:50];
        [slider setTintColor:[UIColor orangeColor]];
        [slider setAlpha:0.5];
        [self.view addSubview:slider];
        if ([self appBundleID]) {
            [_explainingBox setText:[trans(@"This affects the badge size for (APPNAME).") stringByReplacingOccurrencesOfString:@"(APPNAME)" withString:[self appName]]];
            _backgd.image = [UIImage imageNamed:@"RGreenGrad.png"];
            if ([self badgeCount]) {
                NSString *BadgeSize = badgerRetriveAppCountPref([self badgeCount],[self appBundleID],@"BadgeSize");
                if (BadgeSize) {
                    _numberField.text = [NSString stringWithFormat:@"%@%%",BadgeSize];
                    _numberField.subviews[0].alpha = [badgerRetriveAppCountPref([self badgeCount],[self appBundleID],@"BadgeSize") floatValue] / 100;
                    [slider setValue:[badgerRetriveAppCountPref([self badgeCount],[self appBundleID],@"BadgeSize") integerValue]];
                } else {
                    _numberField.text = @"100%";
                    [slider setValue:100];
                }
            } else {
                NSString *BadgeSize = badgerRetriveAppPref([self appBundleID],@"BadgeSize");
                if (BadgeSize) {
                    _numberField.text = [NSString stringWithFormat:@"%@%%",BadgeSize];
                    _numberField.subviews[0].alpha = [badgerRetriveAppPref([self appBundleID],@"BadgeOpacity") floatValue] / 100;
                    [slider setValue:[badgerRetriveAppPref([self appBundleID],@"BadgeSize") integerValue]];
                } else {
                    _numberField.text = @"100%";
                    [slider setValue:100];
                }
            }
        } else {
            if ([self badgeCount]) {
                _backgd.image = [UIImage imageNamed:@"RYellowGrad.png"];
                NSString *BadgeSize = badgerRetriveUniversalCountPref([self badgeCount],@"BadgeSize");
                if (BadgeSize) {
                    _numberField.text = [NSString stringWithFormat:@"%@%%",BadgeSize];
                    _numberField.subviews[0].alpha = [badgerRetriveUniversalCountPref([self badgeCount],@"BadgeSize") floatValue] / 100;
                    [slider setValue:[badgerRetriveUniversalCountPref([self badgeCount],@"BadgeSize") integerValue]];
                } else {
                    _numberField.text = @"100%";
                    [slider setValue:100];
                }
            } else {
                _backgd.image = [UIImage imageNamed:@"RYellowGrad.png"];
                NSString *BadgeSize = badgerRetriveUniversalPref(@"BadgeSize");
                if (BadgeSize) {
                    _numberField.text = [NSString stringWithFormat:@"%@%%",BadgeSize];
                    _numberField.subviews[0].alpha = [badgerRetriveUniversalPref(@"BadgeSize") floatValue] / 100;
                    [slider setValue:[badgerRetriveUniversalPref(@"BadgeSize") integerValue]];
                } else {
                    _numberField.text = @"100%";
                    [slider setValue:100];
                }
            }
        }
    }
    //[_appLabel sizeToFit];
    //[_explainingBox sizeToFit];
    //[_label sizeToFit];
    //[_label setTextColor:[UIColor purpleColor]];
    [_label setAlpha:0.5];
    //[_explainingBox setTextColor:[UIColor purpleColor]];
    [_explainingBox setAlpha:0.5];
    //[_appLabel setTextColor:[UIColor purpleColor]];
    [_appLabel setAlpha:0.5];
    //[_numberField setTextColor:[UIColor purpleColor]];
    [_label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:25.0f]];
    [_explainingBox setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]];
    //_iconView.image = [UIImage imageNamed:@"MinimumBadge.png"];
    //self.view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.9];//[UIColor colorWithRed:255.0/255.0 green:7.0/255.0 blue:58.0/255.0 alpha:1.0];//cellColorFromRow(0);
    //self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.0];//[UIColor colorWithRed:255.0/255.0 green:7.0/255.0 blue:58.0/255.0 alpha:1.0];
    //_numberField.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:0.0/255.0 blue:20.0/255.0 alpha:0.7];/*[UIColor colorWithRed:139.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];*///[UIColor colorWithRed:254.0/255.0 green:193.0/255.0 blue:206.0/255.0 alpha:1.0];
    //_explainingBox.backgroundColor = _numberField.backgroundColor;//[UIColor colorWithRed:254.0/255.0 green:193.0/255.0 blue:206.0/255.0 alpha:1.0];
    //_explainingBox.layer.cornerRadius = 10.0;
    /*UIView *topNotchCover;
    if (@available(iOS 11.0, *)) {
        topNotchCover = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.applicationFrame.size.width, self.navigationController.navigationBar.frame.size.height)]; //height 96 on 852, 91 on 548
    //
    } else {
        topNotchCover = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.applicationFrame.size.width, 91+(UIScreen.mainScreen.applicationFrame.size.height/60.8)-9.01315789)]; //height 96 on 852, 91 on 548
    }
    topNotchCover.hidden = NO;
    topNotchCover.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    [self.view addSubview:topNotchCover];*/
    // Do any additional setup after loading the view.
    //BUGFIX: (Fixed in Badger 1.2.2) Sometimes with French translations, label can get too big, we *do* resize the label but the thing is that's before we replace the label with the translation, so it's resized for the english translation and not the current actual translation :P. This has been fixed by the line below and now we resize after translation.
    [_label sizeToFit];
    [_label layoutIfNeeded];
    NSLog(@"centerXAnchor: %@",[_label centerXAnchor]);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *newText;
    if ([badgeSetting isEqualToString:@"label"]) {
        newText = textField.text;
    } else {
    NSScanner *scanner = [NSScanner scannerWithString:textField.text];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
    [scanner scanCharactersFromSet:numbers intoString:&newText];
    }
    if (newText.length < 1 && ![badgeSetting isEqualToString:@"label"]) {
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invalid %@ Count",badgeSetting]
                                                        message:trans(@"Please input a number.")
                                                       delegate:self
                                              cancelButtonTitle:trans(@"Okay")
                                              otherButtonTitles:nil];
        [alert show];*/
        if ([badgeSetting isEqualToString:@"minimum"]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid minimum Count") message:trans(@"Your minimum has to be greater than 0.") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:confirmAction];
            [self presentViewController:alert animated:YES completion:nil];
            newText = @"1";
        } else if ([badgeSetting isEqualToString:@"limit"]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid maximum Count") message:trans(@"Your maximum has to be greater than 0.") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:confirmAction];
            [self presentViewController:alert animated:YES completion:nil];
            newText = @"None";
        } else {
            newText = @"100";
        }
    }
    if ([newText integerValue] < 0 && [badgeSetting isEqualToString:@"opacity"]) {
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:trans(@"Invalid opacity")
                                                        message:trans(@"Your (BADGESETTING) has to be equal to or greater than 0%.")
                                                       delegate:self
                                              cancelButtonTitle:trans(@"Okay")
                                              otherButtonTitles:nil];
        [alert show];*/
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid opacity") message:trans(@"Your opacity has to be equal to or greater than 0%.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
        newText = @"0";
    } else if ([newText integerValue] > 100 && [badgeSetting isEqualToString:@"opacity"]) {
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:trans(@"Invalid opacity")
                                                        message:trans(@"Your opacity has to be 100% or less.")
                                                       delegate:self
                                              cancelButtonTitle:trans(@"Okay")
                                              otherButtonTitles:nil];
        [alert show];*/
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid opacity") message:trans(@"Your opacity has to be 100% or less.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
        newText = @"100";
    } else if ([newText integerValue] < 50 && [badgeSetting isEqualToString:@"size"]) {
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:trans(@"Invalid size")
                                                        message:trans(@"Your size has to be equal to or greater than 50%.")
                                                       delegate:self
                                              cancelButtonTitle:trans(@"Okay")
                                              otherButtonTitles:nil];
        [alert show];*/
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid size") message:trans(@"Your size has to be equal to or greater than 50%.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
        newText = @"50";
    } else if ([newText integerValue] > 200 && [badgeSetting isEqualToString:@"size"]) {
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:trans(@"Invalid size")
                                                        message:trans(@"Your size has to be 200% or less.")
                                                       delegate:self
                                              cancelButtonTitle:trans(@"Okay")
                                              otherButtonTitles:nil];
        [alert show];*/
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid size") message:trans(@"Your size has to be 200% or less.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
        newText = @"100";
    }
    if ([newText integerValue] < 1 && ![newText isEqualToString:@"None"] && ![badgeSetting isEqualToString:@"opacity"] && ![badgeSetting isEqualToString:@"size"] && ![badgeSetting isEqualToString:@"label"]) {
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invalid %@ Count",badgeSetting]
                                                        message:[NSString stringWithFormat:@"Your %@ has to be greater than 0.",badgeSetting]
                                                       delegate:self
                                              cancelButtonTitle:trans(@"Okay")
                                              otherButtonTitles:nil];
        [alert show];*/
        if ([badgeSetting isEqualToString:@"minimum"]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid minimum Count") message:trans(@"Your minimum has to be greater than 0.") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:confirmAction];
            [self presentViewController:alert animated:YES completion:nil];
            newText = @"1";
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid maximum Count") message:trans(@"Your maximum has to be greater than 0.") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:confirmAction];
            [self presentViewController:alert animated:YES completion:nil];
            newText = @"None";
        }
    }
    if (![newText isEqualToString:@"None"] && ![badgeSetting isEqualToString:@"label"]) {
        textField.text = [@([newText integerValue]) stringValue];
    } else {
        textField.text = newText;
    }
    [textField resignFirstResponder];
    //save plist
    if ([[self cellTitle]isEqualToString:trans(@"Badge Count Minimum")]) {
        if ([newText isEqualToString:@"1"]) {
            badgerRemoveUniversalPref(@"BadgeCountMinimum");
        } else {
            badgerSaveUniversalPref(@"BadgeCountMinimum", textField.text);
        }
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Count Minimum for App")]) {
        if ([newText isEqualToString:@"1"]) {
            badgerRemoveAppPref([self appBundleID], @"BadgeCountMinimum");
        } else {
            badgerSaveAppPref([self appBundleID], @"BadgeCountMinimum", textField.text);
        }
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Count Limit")]) {
        if ([newText isEqualToString:@"None"]) {
            badgerRemoveUniversalPref(@"BadgeCountLimit");
        } else {
            badgerSaveUniversalPref(@"BadgeCountLimit", textField.text);
        }
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Count Limit for App")]) {
        if ([newText isEqualToString:@"None"]) {
            badgerRemoveAppPref([self appBundleID],@"BadgeCountLimit");
        } else {
            badgerSaveAppPref([self appBundleID],@"BadgeCountLimit", textField.text);
        }
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Opacity")]) {
        if ([newText isEqualToString:@"100"]) {
            if ([self badgeCount]) {
                badgerRemoveUniversalCountPref([self badgeCount],@"BadgeOpacity");
            } else {
                badgerRemoveUniversalPref(@"BadgeOpacity");
            }
        } else {
            if ([self badgeCount]) {
                badgerSaveUniversalCountPref([self badgeCount],@"BadgeOpacity", newText);
            } else {
                badgerSaveUniversalPref(@"BadgeOpacity", newText);
            }
        }
        [slider setValue:[newText integerValue] animated:YES];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Opacity for App")]) {
        if ([newText isEqualToString:@"100"]) {
            if ([self badgeCount]) {
                badgerRemoveAppCountPref([self badgeCount],[self appBundleID],@"BadgeOpacity");
            } else {
                badgerRemoveAppPref([self appBundleID],@"BadgeOpacity");
            }
        } else {
            if ([self badgeCount]) {
                badgerSaveAppCountPref([self badgeCount],[self appBundleID],@"BadgeOpacity", newText);
            } else {
                badgerSaveAppPref([self appBundleID],@"BadgeOpacity", newText);
            }
        }
        [slider setValue:[newText integerValue] animated:YES];
    } else if ([[self cellTitle]isEqualToString:trans(@"Custom Badge Label")]) {
        if ([self badgeCount]) {
            badgerSaveUniversalCountPref([self badgeCount], @"BadgeLabel", newText);
        } else {
            badgerSaveUniversalPref(@"BadgeLabel", newText);
        }
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Size")]) {
        if ([newText isEqualToString:@"100"]) {
            if ([self badgeCount]) {
                badgerRemoveUniversalCountPref([self badgeCount],@"BadgeSize");
            } else {
                badgerRemoveUniversalPref(@"BadgeSize");
            }
        } else {
            if ([self badgeCount]) {
                badgerSaveUniversalCountPref([self badgeCount],@"BadgeSize", newText);
            } else {
                badgerSaveUniversalPref(@"BadgeSize", newText);
            }
        }
        [slider setValue:[newText integerValue] animated:YES];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Size for App")]) {
        if ([newText isEqualToString:@"100"]) {
            if ([self badgeCount]) {
                badgerRemoveAppCountPref([self badgeCount],[self appBundleID],@"BadgeSize");
            } else {
                badgerRemoveAppPref([self appBundleID],@"BadgeSize");
            }
        } else {
            if ([self badgeCount]) {
                badgerSaveAppCountPref([self badgeCount],[self appBundleID],@"BadgeSize", newText);
            } else {
                badgerSaveAppPref([self appBundleID],@"BadgeSize", newText);
            }
        }
        [slider setValue:[newText integerValue] animated:YES];
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSString *newText;
    if ([badgeSetting isEqualToString:@"label"]) {
        newText = textField.text;
    } else {
    NSScanner *scanner = [NSScanner scannerWithString:textField.text];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
    [scanner scanCharactersFromSet:numbers intoString:&newText];
    }
    if ([newText isEqualToString:@""] && ![badgeSetting isEqualToString:@"label"]) {
        if ([badgeSetting isEqualToString:@"minimum"]) {
            newText = @"1";
        } else if ([badgeSetting isEqualToString:@"limit"]) {
            newText = @"None";
        } else {
            newText = @"100";
        }
    }
    if ([newText integerValue] < 0 && [badgeSetting isEqualToString:@"opacity"]) {
        newText = @"0";
    } else if ([newText integerValue] > 100 && [badgeSetting isEqualToString:@"opacity"]) {
        newText = @"100";
    } else if ([newText integerValue] < 50 && [badgeSetting isEqualToString:@"size"]) {
        newText = @"50";
    } else if ([newText integerValue] > 200 && [badgeSetting isEqualToString:@"size"]) {
        newText = @"100";
    }
    if ([newText integerValue] < 1 && ![newText isEqualToString:@"None"] && ![badgeSetting isEqualToString:@"opacity"] && ![badgeSetting isEqualToString:@"size"] && ![badgeSetting isEqualToString:@"label"]) {
        if ([badgeSetting isEqualToString:@"minimum"]) {
            newText = @"1";
        } else {
            newText = @"None";
        }
    }
    if (![newText isEqualToString:@"None"] && ![badgeSetting isEqualToString:@"label"]) {
        textField.text = [@([newText integerValue]) stringValue];
    } else {
        textField.text = newText;
    }
    [textField becomeFirstResponder];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *newText;
    if ([badgeSetting isEqualToString:@"label"]) {
        newText = textField.text;
    } else {
    NSScanner *scanner = [NSScanner scannerWithString:textField.text];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
    [scanner scanCharactersFromSet:numbers intoString:&newText];
    }
    if ([newText isEqualToString:@""] && ![badgeSetting isEqualToString:@"label"]) {
        if ([badgeSetting isEqualToString:@"minimum"]) {
            newText = @"1";
        } else if ([badgeSetting isEqualToString:@"limit"]) {
            newText = @"None";
        } else {
            newText = @"100";
        }
    }
    if ([newText integerValue] < 0 && [badgeSetting isEqualToString:@"opacity"]) {
        newText = @"0";
    } else if ([newText integerValue] > 100 && [badgeSetting isEqualToString:@"opacity"]) {
        newText = @"100";
    } else if ([newText integerValue] < 50 && [badgeSetting isEqualToString:@"size"]) {
        newText = @"50";
    } else if ([newText integerValue] > 200 && [badgeSetting isEqualToString:@"size"]) {
        newText = @"100";
    }
    if ([newText integerValue] < 1 && ![newText isEqualToString:@"None"] && ![badgeSetting isEqualToString:@"opacity"] && ![badgeSetting isEqualToString:@"size"] && ![badgeSetting isEqualToString:@"label"]) {
        if ([badgeSetting isEqualToString:@"minimum"]) {
            newText = @"1";
        } else {
            newText = @"None";
        }
    }
    if (![newText isEqualToString:@"None"] && ![badgeSetting isEqualToString:@"label"]) {
        textField.text = [@([newText integerValue]) stringValue];
    } else {
        textField.text = newText;
    }
    if ([badgeSetting isEqualToString:@"opacity"] || [badgeSetting isEqualToString:@"size"]) {
        textField.text = [NSString stringWithFormat:@"%@%%",textField.text];
    }
    [textField resignFirstResponder];
}
-(void)sliderChange:(id)sender {
    _numberField.text = [NSString stringWithFormat:@"%d%%",(int)[slider value]];
    if ([badgeSetting isEqualToString:@"opacity"]) {
        if ([self appBundleID]) {
            if ((int)[slider value] == 100) {
                if ([self badgeCount]) {
                    badgerRemoveAppCountPref([self badgeCount],[self appBundleID],@"BadgeOpacity");
                } else {
                    badgerRemoveAppPref([self appBundleID],@"BadgeOpacity");
                }
            } else {
                if ([self badgeCount]) {
                    badgerSaveAppCountPref([self badgeCount],[self appBundleID],@"BadgeOpacity",[NSString stringWithFormat:@"%d",(int)[slider value]]);
                } else {
                    badgerSaveAppPref([self appBundleID],@"BadgeOpacity",[NSString stringWithFormat:@"%d",(int)[slider value]]);
                }
            }
        } else {
            if ((int)[slider value] == 100) {
                if ([self badgeCount]) {
                    badgerRemoveUniversalCountPref([self badgeCount],@"BadgeOpacity");
                } else {
                    badgerRemoveUniversalPref(@"BadgeOpacity");
                }
            } else {
                if ([self badgeCount]) {
                    badgerSaveUniversalCountPref([self badgeCount],@"BadgeOpacity",[NSString stringWithFormat:@"%d",(int)[slider value]]);
                } else {
                    badgerSaveUniversalPref(@"BadgeOpacity",[NSString stringWithFormat:@"%d",(int)[slider value]]);
                }
            }
        }
    } else if ([badgeSetting isEqualToString:@"size"]) {
        if ([self appBundleID]) {
            if ((int)[slider value] == 100) {
                if ([self badgeCount]) {
                    badgerRemoveAppCountPref([self badgeCount],[self appBundleID],@"BadgeSize");
                } else {
                    badgerRemoveAppPref([self appBundleID],@"BadgeSize");
                }
            } else {
                if ([self badgeCount]) {
                    badgerSaveAppCountPref([self badgeCount],[self appBundleID],@"BadgeSize",[NSString stringWithFormat:@"%d",(int)[slider value]]);
                } else {
                    badgerSaveAppPref([self appBundleID],@"BadgeSize",[NSString stringWithFormat:@"%d",(int)[slider value]]);
                }
            }
        } else {
            if ((int)[slider value] == 100) {
                if ([self badgeCount]) {
                    badgerRemoveUniversalCountPref([self badgeCount],@"BadgeSize");
                } else {
                    badgerRemoveUniversalPref(@"BadgeSize");
                }
            } else {
                if ([self badgeCount]) {
                    badgerSaveUniversalCountPref([self badgeCount],@"BadgeSize",[NSString stringWithFormat:@"%d",(int)[slider value]]);
                } else {
                    badgerSaveUniversalPref(@"BadgeSize",[NSString stringWithFormat:@"%d",(int)[slider value]]);
                }
            }
        }
    }
    _numberField.subviews[0].alpha = slider.value / 100;
}
@end

void setThemePinkGrad(NSString *themeName) {
    //Input the name of the theme, ex @"PinkGrad.png"
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir,@"GradientType.txt"];
    NSError *error;
    [themeName writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

NSString *getTheme(void) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir,@"GradientType.txt"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    return fileContents;
}

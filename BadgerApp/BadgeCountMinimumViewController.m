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
#import "BadgeColorViewController.h"

NSString *badgeSetting;
UISlider *slider;
long badgeCount3;
NSString *appBundleID3;

@interface BadgeCountMinimumViewController ()

@property (weak, nonatomic) IBOutlet UITextField *numberField;
@property (weak, nonatomic) IBOutlet UITextView *explainingBox;
@property (weak, nonatomic) IBOutlet UILabel *appLabel;
@property (weak, nonatomic) IBOutlet UILabel *label;
//-(void)sliderChange:(id)sender;
@end

@implementation BadgeCountMinimumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    badgeCount3 = [self badgeCount];
    appBundleID3 = [self appBundleID];
    CAGradientLayer* betterBackGd = [[CAGradientLayer alloc]init];
    //RRedGrad.png
    [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"FF4A3F").CGColor, (id)colorFromHexString(@"FF5185").CGColor, nil]];
    
    [_numberField setReturnKeyType:UIReturnKeyDone];
    _numberField.delegate = self;
    [_numberField setAlpha:0.5];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor]; //if dark mode this looks weird in app selection
    if ([daCellTitle isEqualToString:trans(@"Badge Count Minimum")]) {
        //RRedGrad.png
        [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"FF4A3F").CGColor, (id)colorFromHexString(@"FF5185").CGColor, nil]];
        _appLabel.hidden = 1;
        [_label setText:trans(@"Badge Count Minimum")];
        [_explainingBox setText:trans(@"This affects the minimum badge count for all applications, universally throughout the system, with the exception if you set a custom amount for a specific app/apps.")];
        badgeSetting = @"minimum";
        if (badgerRetriveUniversalPref(@"BadgeCountMinimum")) {
            _numberField.text = badgerRetriveUniversalPref(@"BadgeCountMinimum");
        }
    } else if ([daCellTitle isEqualToString:trans(@"Badge Count Minimum for App")]) {
        //ROrangeGrad.png
        [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"FFA959").CGColor, (id)colorFromHexString(@"FF5B51").CGColor, nil]];
        _appLabel.hidden = 0;
        _appLabel.text = [self appName];
        [_label setText:trans(@"Badge Count Minimum")];
        [_explainingBox setText:[trans(@"This affects the minimum badge count for (APPNAME).") stringByReplacingOccurrencesOfString:@"(APPNAME)" withString:[self appName]]];
        badgeSetting = @"minimum";
        if (badgerRetriveAppPref(appBundleID3,@"BadgeCountMinimum")) {
            _numberField.text = badgerRetriveAppPref(appBundleID3,@"BadgeCountMinimum");
        }
    } else if ([daCellTitle isEqualToString:trans(@"Badge Count Limit")]) {
        //RYellowGrad.png
        [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"FFE259").CGColor, (id)colorFromHexString(@"FFA751").CGColor, nil]];
        _appLabel.hidden = 1;
        [_label setText:trans(@"Badge Count Limit")];
        [_explainingBox setText:trans(@"This affects the badge count limit for all applications, universally throughout the system, with the exception if you set a custom limit for a specific app/apps.")];
        badgeSetting = @"limit";
        if (badgerRetriveUniversalPref(@"BadgeCountLimit")) {
            _numberField.text = badgerRetriveUniversalPref(@"BadgeCountLimit");
        }
    } else if ([daCellTitle isEqualToString:trans(@"Badge Count Limit for App")]) {
        //RGreenGrad.png
        [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"81FBB8").CGColor, (id)colorFromHexString(@"28C76F").CGColor, nil]];
        _appLabel.hidden = 0;
        _appLabel.text = [self appName];
        [_label setText:@"Badge Count Limit"];
        [_explainingBox setText:[trans(@"This affects the badge count limit for (APPNAME).") stringByReplacingOccurrencesOfString:@"(APPNAME)" withString:[self appName]]];
        badgeSetting = @"limit";
        if (badgerRetriveAppPref(appBundleID3,@"BadgeCountLimit")) {
            _numberField.text = badgerRetriveAppPref(appBundleID3,@"BadgeCountLimit");
        }
    } else if ([daCellTitle isEqualToString:trans(@"Badge Opacity")] || [daCellTitle isEqualToString:trans(@"Badge Opacity for App")]) {
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
        id currentBadgeOpacity = badgerRetriveCurrentPref(badgeCount3,appBundleID3,@"BadgeOpacity");
        if (currentBadgeOpacity) {
            _numberField.text = [NSString stringWithFormat:@"%@%%",currentBadgeOpacity];
            _numberField.subviews[0].alpha = [currentBadgeOpacity floatValue] / 100;
            [slider setValue:[currentBadgeOpacity integerValue]];
        } else {
            _numberField.text = @"100%";
            [slider setValue:100];
        }
        if (appBundleID3) {
            //RRedGrad.png
            [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"FF4A3F").CGColor, (id)colorFromHexString(@"FF5185").CGColor, nil]];
        } else {
            //RPurpleGrad.png
            [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"E2B0FF").CGColor, (id)colorFromHexString(@"9F44D3").CGColor, nil]];
        }
    } else if ([daCellTitle isEqualToString:trans(@"Custom Badge Label")]) {
        //RRedGrad.png
        [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"FF4A3F").CGColor, (id)colorFromHexString(@"FF5185").CGColor, nil]];
        _appLabel.hidden = 1;
        [_label setText:trans(@"Custom Badge Label")];
        [_explainingBox setText:trans(@"Set a custom label for notification badges.")];
        badgeSetting = @"label";
        NSString *BadgeLabel;
        if (badgeCount3) {
            BadgeLabel = badgerRetriveUniversalCountPref(badgeCount3,@"BadgeLabel");
        } else {
            BadgeLabel = badgerRetriveUniversalPref(@"BadgeLabel");
        }
        if (BadgeLabel) {
            _numberField.text = [NSString stringWithFormat:@"%@",BadgeLabel];
        } else {
            _numberField.text = @"";
        }
        _numberField.placeholder = trans(@"Enter label...");
    } else if ([daCellTitle isEqualToString:trans(@"Badge Size")] || [daCellTitle isEqualToString:trans(@"Badge Size for App")]) {
        _appLabel.hidden = 1;
        [_label setText:trans(@"Badge Size")];
        [_explainingBox setText:trans(@"This affects the badge size for notification badges.")];
        badgeSetting = @"size";
        slider = [[UISlider alloc]initWithFrame:CGRectMake(20, UIScreen.mainScreen.bounds.size.height / 2, UIScreen.mainScreen.bounds.size.width - 40, 40)];
        [slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
        [slider setMaximumValue:200];
        [slider setMinimumValue:50];
        [slider setTintColor:[UIColor orangeColor]];
        [slider setAlpha:1.0];
        [self.view addSubview:slider];
        NSString *BadgeSize = badgerRetriveCurrentPref(badgeCount3,appBundleID3,@"BadgeSize");
        if (BadgeSize) {
            _numberField.text = [NSString stringWithFormat:@"%@%%",BadgeSize];
            //_numberField.subviews[0].alpha = [BadgeSize floatValue] / 100;
            [slider setValue:[BadgeSize integerValue]];
        } else {
            _numberField.text = @"100%";
            [slider setValue:100];
        }
        if (appBundleID3) {
            [_explainingBox setText:[trans(@"This affects the badge size for (APPNAME).") stringByReplacingOccurrencesOfString:@"(APPNAME)" withString:[self appName]]];
            //RYellowGrad.png
            [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"FFE259").CGColor, (id)colorFromHexString(@"FFA751").CGColor, nil]];
        } else {
            //ROrangeGrad.png
            [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"FFA959").CGColor, (id)colorFromHexString(@"FF5B51").CGColor, nil]];
        }
    }
    [_label setAlpha:0.5];
    [_explainingBox setAlpha:0.5];
    [_appLabel setAlpha:0.5];
    //BUGFIX: (Fixed in Badger 1.2.2) Use the existing font sizes
    [_label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:[[_label font]pointSize]]];
    [_explainingBox setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]];
    // Do any additional setup after loading the view.
    //BUGFIX: (Fixed in Badger 1.2.2) Sometimes with French translations, label can get too big, we *do* resize the label but the thing is that's before we replace the label with the translation, so it's resized for the english translation and not the current actual translation :P. This has been fixed by the line below and now we resize after translation.
    [_label setAdjustsFontSizeToFitWidth:YES];
    if (_label.frame.size.width > [self.view frame].size.width) {
        [_label setFrame:CGRectMake(_label.frame.origin.x, _label.frame.origin.y, [self.view frame].size.width - (_label.frame.origin.x * 2), _label.frame.size.height)];
    }
    if (_label.bounds.size.width > [self.view frame].size.width) {
        [_label setBounds:CGRectMake(_label.bounds.origin.x, _label.bounds.origin.y, [self.view frame].size.width - (_label.bounds.origin.x * 2), _label.bounds.size.height)];
    }
    //resize and then size again idfk but this causes less bugs. fuck storyboards.
    [_label sizeToFit];
    [_label layoutIfNeeded];
    [_label setFrame:CGRectMake(_label.frame.origin.x, _label.frame.origin.y, [self.view frame].size.width - (_label.frame.origin.x * 2), _label.frame.size.height)];
    if ((_label.bounds.origin.x + _label.bounds.size.width) > [self.view frame].size.width) {
        [_label setBounds:CGRectMake(_label.bounds.origin.x, _label.bounds.origin.y, [self.view bounds].size.width - (_label.bounds.origin.x * 2), _label.bounds.size.height)];
    }
    
    //set up gradient
    [betterBackGd setStartPoint:CGPointMake(0, 0)];
    [betterBackGd setEndPoint:CGPointMake(1, 1)];
    [betterBackGd setFrame:[[self view] bounds]]; //CGRectMake(0, 0, [[self view]frame].size.width, [[self view]frame].size.height)
    [betterBackGd setType:kCAGradientLayerAxial];
    [[[self view]layer]insertSublayer:betterBackGd atIndex:0];
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid opacity") message:trans(@"Your opacity has to be equal to or greater than 0%.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
        newText = @"0";
    } else if ([newText integerValue] > 100 && [badgeSetting isEqualToString:@"opacity"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid opacity") message:trans(@"Your opacity has to be 100% or less.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
        newText = @"100";
    } else if ([newText integerValue] < 50 && [badgeSetting isEqualToString:@"size"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid size") message:trans(@"Your size has to be equal to or greater than 50%.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
        newText = @"50";
    } else if ([newText integerValue] > 200 && [badgeSetting isEqualToString:@"size"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid size") message:trans(@"Your size has to be 200% or less.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
        newText = @"100";
    }
    if ([newText integerValue] < 1 && ![newText isEqualToString:@"None"] && ![badgeSetting isEqualToString:@"opacity"] && ![badgeSetting isEqualToString:@"size"] && ![badgeSetting isEqualToString:@"label"]) {
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
    if ([daCellTitle isEqualToString:trans(@"Badge Count Minimum")]) {
        if ([newText isEqualToString:@"1"]) {
            badgerRemoveUniversalPref(@"BadgeCountMinimum");
        } else {
            badgerSaveUniversalPref(@"BadgeCountMinimum", textField.text);
        }
    } else if ([daCellTitle isEqualToString:trans(@"Badge Count Minimum for App")]) {
        if ([newText isEqualToString:@"1"]) {
            badgerRemoveAppPref(appBundleID3, @"BadgeCountMinimum");
        } else {
            badgerSaveAppPref(appBundleID3, @"BadgeCountMinimum", textField.text);
        }
    } else if ([daCellTitle isEqualToString:trans(@"Badge Count Limit")] || [daCellTitle isEqualToString:trans(@"Badge Count Limit for App")]) {
        if ([newText isEqualToString:@"None"]) {
            badgerRemoveCurrentPref(badgeCount3,appBundleID3,@"BadgeCountLimit");
        } else {
            badgerSaveCurrentPref(badgeCount3, appBundleID3, @"BadgeCountLimit", textField.text);
        }
    } else if ([daCellTitle isEqualToString:trans(@"Badge Opacity")] || [daCellTitle isEqualToString:trans(@"Badge Opacity for App")]) {
        if ([newText isEqualToString:@"100"]) {
            badgerRemoveCurrentPref(badgeCount3,appBundleID3,@"BadgeOpacity");
        } else {
            badgerSaveCurrentPref(badgeCount3,appBundleID3, @"BadgeOpacity", newText);
        }
        [slider setValue:[newText integerValue] animated:YES];
    } else if ([daCellTitle isEqualToString:trans(@"Custom Badge Label")]) {
        badgerSaveCurrentPref(badgeCount3, NULL, @"BadgeLabel", newText);
    } else if ([daCellTitle isEqualToString:trans(@"Badge Size")] || [daCellTitle isEqualToString:trans(@"Badge Size for App")]) {
        if ([newText isEqualToString:@"100"]) {
            badgerRemoveCurrentPref(badgeCount3,appBundleID3,@"BadgeSize");
        } else {
            badgerSaveCurrentPref(badgeCount3,appBundleID3, @"BadgeSize", newText);
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
    long integerValue = [newText integerValue];
    if (integerValue < 0 && [badgeSetting isEqualToString:@"opacity"]) {
        newText = @"0";
    } else if (integerValue > 100 && [badgeSetting isEqualToString:@"opacity"]) {
        newText = @"100";
    } else if (integerValue < 50 && [badgeSetting isEqualToString:@"size"]) {
        newText = @"50";
    } else if (integerValue > 200 && [badgeSetting isEqualToString:@"size"]) {
        newText = @"100";
    }
    if (integerValue < 1 && ![newText isEqualToString:@"None"] && ![badgeSetting isEqualToString:@"opacity"] && ![badgeSetting isEqualToString:@"size"] && ![badgeSetting isEqualToString:@"label"]) {
        if ([badgeSetting isEqualToString:@"minimum"]) {
            newText = @"1";
        } else {
            newText = @"None";
        }
    }
    if (![newText isEqualToString:@"None"] && ![badgeSetting isEqualToString:@"label"]) {
        textField.text = [@(integerValue) stringValue];
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
        if ((int)[slider value] == 100) {
            badgerRemoveCurrentPref(badgeCount3,appBundleID3,@"BadgeOpacity");
        } else {
            badgerSaveCurrentPref(badgeCount3,appBundleID3,@"BadgeOpacity",[NSString stringWithFormat:@"%d",(int)[slider value]]);
        }
    } else if ([badgeSetting isEqualToString:@"size"]) {
        if ((int)[slider value] == 100) {
            badgerRemoveCurrentPref(badgeCount3,appBundleID3,@"BadgeSize");
        } else {
            badgerSaveCurrentPref(badgeCount3,appBundleID3,@"BadgeSize",[NSString stringWithFormat:@"%d",(int)[slider value]]);
        }
    }
    _numberField.subviews[0].alpha = slider.value / 100;
}
@end

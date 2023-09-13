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
@end

@implementation BadgeCountMinimumViewController

-(void)viewDidLoad {
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
        NSString *countMinimum = badgerRetriveUniversalPref(@"BadgeCountMinimum");
        if (countMinimum) {
            _numberField.text = countMinimum;
        }
    } else if ([daCellTitle isEqualToString:trans(@"Badge Count Minimum for App")]) {
        //ROrangeGrad.png
        [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"FFA959").CGColor, (id)colorFromHexString(@"FF5B51").CGColor, nil]];
        _appLabel.hidden = 0;
        _appLabel.text = [self appName];
        [_label setText:trans(@"Badge Count Minimum")];
        [_explainingBox setText:[trans(@"This affects the minimum badge count for (APPNAME).") stringByReplacingOccurrencesOfString:@"(APPNAME)" withString:[self appName]]];
        badgeSetting = @"minimum";
        NSString *countMinimum = badgerRetriveAppPref(appBundleID3,@"BadgeCountMinimum");
        if (countMinimum) {
            _numberField.text = countMinimum;
        }
    } else if ([daCellTitle isEqualToString:trans(@"Badge Count Limit")]) {
        //RYellowGrad.png
        [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"FFE259").CGColor, (id)colorFromHexString(@"FFA751").CGColor, nil]];
        _appLabel.hidden = 1;
        [_label setText:trans(@"Badge Count Limit")];
        [_explainingBox setText:trans(@"This affects the badge count limit for all applications, universally throughout the system, with the exception if you set a custom limit for a specific app/apps.")];
        badgeSetting = @"limit";
        NSString *countLimit = badgerRetriveUniversalPref(@"BadgeCountLimit");
        if (countLimit) {
            _numberField.text = countLimit;
        }
    } else if ([daCellTitle isEqualToString:trans(@"Badge Count Limit for App")]) {
        /* NOT USED */
        //RGreenGrad.png
        [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"81FBB8").CGColor, (id)colorFromHexString(@"28C76F").CGColor, nil]];
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
        if (!currentBadgeOpacity) {
            currentBadgeOpacity = @"100";
        }
        _numberField.text = [NSString stringWithFormat:@"%@%%",currentBadgeOpacity];
        _numberField.subviews[0].alpha = [currentBadgeOpacity floatValue] / 100;
        [slider setValue:[currentBadgeOpacity integerValue]];
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
        NSString *BadgeLabel = badgerRetriveCurrentPref(badgeCount3,NULL,@"BadgeLabel");
        if (!BadgeLabel) {
            BadgeLabel = @"";
        }
        _numberField.text = BadgeLabel;
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
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *newText;
    if ([badgeSetting isEqualToString:@"label"]) {
        newText = textField.text;
    } else {
        UIAlertController *alert;
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:nil];
        NSCharacterSet *numbers = NSCharacterSet.decimalDigitCharacterSet;
        newText = [textField.text stringByTrimmingCharactersInSet:numbers.invertedSet];
        if (newText.length < 1) {
            if ([badgeSetting isEqualToString:@"minimum"]) {
                alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid minimum Count") message:trans(@"Your minimum has to be greater than 0.") preferredStyle:UIAlertControllerStyleAlert];
                newText = @"1";
            } else if ([badgeSetting isEqualToString:@"limit"]) {
                alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid maximum Count") message:trans(@"Your maximum has to be greater than 0.") preferredStyle:UIAlertControllerStyleAlert];
                newText = @"None";
            } else {
                newText = @"100";
            }
        }
        if ([newText integerValue] < 0 && [badgeSetting isEqualToString:@"opacity"]) {
            alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid opacity") message:trans(@"Your opacity has to be equal to or greater than 0%.") preferredStyle:UIAlertControllerStyleAlert];
            newText = @"0";
        } else if ([newText integerValue] > 100 && [badgeSetting isEqualToString:@"opacity"]) {
            alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid opacity") message:trans(@"Your opacity has to be 100% or less.") preferredStyle:UIAlertControllerStyleAlert];
            newText = @"100";
        } else if ([newText integerValue] < 50 && [badgeSetting isEqualToString:@"size"]) {
            alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid size") message:trans(@"Your size has to be equal to or greater than 50%.") preferredStyle:UIAlertControllerStyleAlert];
            newText = @"50";
        } else if ([newText integerValue] > 200 && [badgeSetting isEqualToString:@"size"]) {
            alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid size") message:trans(@"Your size has to be 200% or less.") preferredStyle:UIAlertControllerStyleAlert];
            newText = @"100";
        }
        if ([newText integerValue] < 1 && ![newText isEqualToString:@"None"] && ![badgeSetting isEqualToString:@"opacity"] && ![badgeSetting isEqualToString:@"size"]) {
            if ([badgeSetting isEqualToString:@"minimum"]) {
                alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid minimum Count") message:trans(@"Your minimum has to be greater than 0.") preferredStyle:UIAlertControllerStyleAlert];
                newText = @"1";
            } else {
                alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid maximum Count") message:trans(@"Your maximum has to be greater than 0.") preferredStyle:UIAlertControllerStyleAlert];
                newText = @"None";
            }
        }
        if (alert) {
            [alert addAction:confirmAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    if (![newText isEqualToString:@"None"] && ![badgeSetting isEqualToString:@"label"]) {
        textField.text = [@([newText integerValue]) stringValue];
    } else {
        textField.text = newText;
    }
    [textField resignFirstResponder];
    //save plist
    if ([badgeSetting isEqualToString:@"minimum"]) {
        if ([newText isEqualToString:@"1"]) {
            badgerRemoveCurrentPref(0, appBundleID3, @"BadgeCountMinimum");
        } else {
            badgerSaveCurrentPref(0, appBundleID3, @"BadgeCountMinimum", newText);
        }
    } else if ([badgeSetting isEqualToString:@"limit"]) {
        if ([newText isEqualToString:@"None"]) {
            badgerRemoveCurrentPref(badgeCount3,appBundleID3,@"BadgeCountLimit");
        } else {
            badgerSaveCurrentPref(badgeCount3, appBundleID3, @"BadgeCountLimit", newText);
        }
    } else if ([badgeSetting isEqualToString:@"opacity"]) {
        if ([newText isEqualToString:@"100"]) {
            badgerRemoveCurrentPref(badgeCount3,appBundleID3,@"BadgeOpacity");
        } else {
            badgerSaveCurrentPref(badgeCount3,appBundleID3, @"BadgeOpacity", newText);
        }
        [slider setValue:[newText integerValue] animated:YES];
    } else if ([badgeSetting isEqualToString:@"label"]) {
        badgerSaveCurrentPref(badgeCount3, NULL, @"BadgeLabel", newText);
    } else if ([badgeSetting isEqualToString:@"size"]) {
        if ([newText isEqualToString:@"100"]) {
            badgerRemoveCurrentPref(badgeCount3,appBundleID3,@"BadgeSize");
        } else {
            badgerSaveCurrentPref(badgeCount3,appBundleID3, @"BadgeSize", newText);
        }
        [slider setValue:[newText integerValue] animated:YES];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    NSString *newText;
    if ([badgeSetting isEqualToString:@"label"]) {
        newText = textField.text;
    } else {
        NSCharacterSet *numbers = NSCharacterSet.decimalDigitCharacterSet;
        newText = [textField.text stringByTrimmingCharactersInSet:numbers.invertedSet];
        if ([newText isEqualToString:@""]) {
            if ([badgeSetting isEqualToString:@"minimum"]) {
                newText = @"1";
            } else if ([badgeSetting isEqualToString:@"limit"]) {
                newText = @"None";
            } else {
                newText = @"100";
            }
        }
    }
    long integerValue = [newText integerValue];
    /* Opacity / Size caps */
    if ([badgeSetting isEqualToString:@"opacity"]) {
        if (integerValue < 0) {
            newText = @"0";
        } else if (integerValue > 100) {
            newText = @"100";
        }
    } else if ([badgeSetting isEqualToString:@"size"]) {
        if (integerValue < 50) {
            newText = @"50";
        } else if (integerValue > 200) {
            newText = @"100";
        }
    } else if (integerValue < 1 && ![newText isEqualToString:@"None"] && ![badgeSetting isEqualToString:@"label"]) {
        if ([badgeSetting isEqualToString:@"minimum"]) {
            newText = @"1";
        } else {
            newText = @"None";
        }
    }
    /* yes, this if statement is not needed, but if i remove it, fucks up compile optimizations so i have to keep it. */
    if (integerValue) {
        textField.text = newText;
    }
    textField.text = newText;
    [textField becomeFirstResponder];
}
-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (![badgeSetting isEqualToString:@"label"]) {
        NSString *newText;
        NSCharacterSet *numbers = NSCharacterSet.decimalDigitCharacterSet;
        newText = [textField.text stringByTrimmingCharactersInSet:numbers.invertedSet];
        if ([newText isEqualToString:@""]) {
            if ([badgeSetting isEqualToString:@"minimum"]) {
                newText = @"1";
            } else if ([badgeSetting isEqualToString:@"limit"]) {
                newText = @"None";
            } else {
                newText = @"100";
            }
        }
        long integerValue = [newText integerValue];
        /* Opacity / Size caps */
        if ([badgeSetting isEqualToString:@"opacity"]) {
            if (integerValue < 0) {
                newText = @"0";
            } else if (integerValue > 100) {
                newText = @"100";
            }
        } else if ([badgeSetting isEqualToString:@"size"]) {
            if (integerValue < 50) {
                newText = @"50";
            } else if (integerValue > 200) {
                newText = @"100";
            }
        } else if (integerValue < 1 && ![newText isEqualToString:@"None"]) {
            if ([badgeSetting isEqualToString:@"minimum"]) {
                newText = @"1";
            } else {
                newText = @"None";
            }
        }
        textField.text = newText;
        if ([badgeSetting isEqualToString:@"opacity"] || [badgeSetting isEqualToString:@"size"]) {
            textField.text = [NSString stringWithFormat:@"%@%%",textField.text];
        }
    }
    [textField resignFirstResponder];
}
-(void)sliderChange:(id)sender {
    int sliderValue = (int)[slider value];
    _numberField.text = [NSString stringWithFormat:@"%d%%",sliderValue];
    if ([badgeSetting isEqualToString:@"opacity"]) {
        if (sliderValue == 100) {
            badgerRemoveCurrentPref(badgeCount3,appBundleID3,@"BadgeOpacity");
        } else {
            badgerSaveCurrentPref(badgeCount3,appBundleID3,@"BadgeOpacity",[NSString stringWithFormat:@"%d",sliderValue]);
        }
    } else if ([badgeSetting isEqualToString:@"size"]) {
        if (sliderValue == 100) {
            badgerRemoveCurrentPref(badgeCount3,appBundleID3,@"BadgeSize");
        } else {
            badgerSaveCurrentPref(badgeCount3,appBundleID3,@"BadgeSize",[NSString stringWithFormat:@"%d",sliderValue]);
        }
    }
    _numberField.subviews[0].alpha = slider.value / 100;
}
@end

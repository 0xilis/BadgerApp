//
//  BadgeColorViewController.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/6/22.
//

#import "ViewController.h"
#import "BadgeColorViewController.h"
#include "BadgerPrefHandler.h"
#import <CoreText/CTFont.h>
#import <CoreText/CTFontDescriptor.h>
#import <CoreText/CTFontManager.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
//https://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string

NSArray *colorsToPick;

@interface BadgeColorViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextView *explainingBox;
@property (weak, nonatomic) IBOutlet UIPickerView *colorPicker;
@property (weak, nonatomic) IBOutlet UIImageView *backgd;
@end

@implementation BadgeColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CAGradientLayer* betterBackGd = [[CAGradientLayer alloc]init];
    [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"81FBB8").CGColor, (id)colorFromHexString(@"28C76F").CGColor, nil]];
    [_label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:25.0f]];
    [_explainingBox setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    //remember to don't just set these to red, but once pref saving is implemented pull from prefs and get that color
    if ([[self cellTitle]isEqualToString:trans(@"Badge Color")] || [[self cellTitle]isEqualToString:trans(@"Badge Color for App")]) {
        colorsToPick = [[NSArray alloc]initWithObjects:@"Default (Red)",@"Pink",@"Orange",@"Yellow",@"Green",@"Blue",@"Purple",@"Magenta",@"Teal",@"Brown",@"Black",@"White",@"Gray",@"Custom",@"Random",@"App Color", nil];
        NSString *badgeColor;
        id temp = badgerRetriveCurrentPref([self badgeCount],[self appBundleID],@"BadgeColor");
        if (temp) {
            badgeColor = temp[@"ColorName"];
        }
        if ([self appBundleID]) {
            //RBlueGrad.png
            [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"ABDCFF").CGColor, (id)colorFromHexString(@"0396FF").CGColor, nil]];
            [_explainingBox setText:[trans(@"This affects the badge color for (APPNAME).")stringByReplacingOccurrencesOfString:@"(APPNAME)" withString:[self appName]]];
        } else {
            [_explainingBox setText:trans(@"This affects the badge color for notification badges.")];
        }
        if (!badgeColor) {
            badgeColor = @"Default (Red)";
        }
        [_explainingBox setTextColor:[self matchingLabelColor:badgeColor]];
        [_label setTextColor:[self matchingLabelColor:badgeColor]];
        [_colorPicker selectRow:[colorsToPick indexOfObject:badgeColor] inComponent:0 animated:NO];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Position")]) {
        colorsToPick = [[NSArray alloc]initWithObjects:@"Default (Top Right)",@"Top Left",@"Bottom Right",@"Bottom Left",@"Center",@"Random", nil];
        id temp = badgerRetriveUniversalPref(@"BadgePosition");
        if (temp) {
            if ([temp objectForKey:@"PositionName"]) {
                [_colorPicker selectRow:[colorsToPick indexOfObject:[temp objectForKey:@"PositionName"]] inComponent:0 animated:NO];
            }
        }
        [_label setText:trans(@"Badge Position")];
        if ([self appBundleID]) {
            [_explainingBox setText:[trans(@"This affects the badge position for (APPNAME).") stringByReplacingOccurrencesOfString:@"(APPNAME)" withString:[self appName]]];
        } else {
            [_explainingBox setText:trans(@"This affects the badge position for notification badges.")];
        }
        //ROrangeGrad.png
        [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"FFA959").CGColor, (id)colorFromHexString(@"FF5B51").CGColor, nil]];
        [_label setAlpha:0.5];
        [_explainingBox setAlpha:0.5];
        [_colorPicker setAlpha:0.5];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Shape")] || [[self cellTitle]isEqualToString:trans(@"Badge Shape for App")]) {
        colorsToPick = [[NSArray alloc]initWithObjects:@"Default",@"Triangle",@"Square",@"Round Square",@"Hexagon", nil];
        id currentBadgeShape = badgerRetriveCurrentPref([self badgeCount],[self appBundleID], @"BadgeShape");
        if (currentBadgeShape) {
            [_colorPicker selectRow:[colorsToPick indexOfObject:currentBadgeShape] inComponent:0 animated:NO];
        }
        [_label setText:trans(@"Badge Shape")];
        if ([self appBundleID]) {
            [_explainingBox setText:[trans(@"This affects the shape for (APPNAME).") stringByReplacingOccurrencesOfString:@"(APPNAME)" withString:[self appName]]];
            //RGreenGrad.png
            [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"81FBB8").CGColor, (id)colorFromHexString(@"28C76F").CGColor, nil]];
        } else {
            [_explainingBox setText:trans(@"This affects the shape for notification badges.")];
            //RYellowGrad.png
            [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"FFE259").CGColor, (id)colorFromHexString(@"FFA751").CGColor, nil]];
        }
        [_label setAlpha:0.5];
        [_explainingBox setAlpha:0.5];
        [_colorPicker setAlpha:0.5];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Label Color")] || [[self cellTitle]isEqualToString:trans(@"Badge Label Color for App")]) {
        [_label setText:trans(@"Badge Label Color")];
        colorsToPick = [[NSArray alloc]initWithObjects:@"Default (White)",@"Red",@"Pink",@"Orange",@"Yellow",@"Green",@"Blue",@"Purple",@"Magenta",@"Teal",@"Brown",@"Black",@"Gray",@"Custom",@"Random", nil];
        NSString *badgeColor;
        if ([self appBundleID]) {
            //RBlueGrad.png
            [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"ABDCFF").CGColor, (id)colorFromHexString(@"0396FF").CGColor, nil]];
            if ([self badgeCount]) {
                id temp = badgerRetriveAppCountPref([self badgeCount],[self appBundleID],@"BadgeLabelColor");
                if (temp) {
                    badgeColor = [temp objectForKey:@"ColorName"];
                }
            } else {
                id temp = badgerRetriveAppPref([self appBundleID],@"BadgeLabelColor");
                if (temp) {
                    badgeColor = [temp objectForKey:@"ColorName"];
                }
            }
        } else {
            //RGreenGrad.png
            [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"81FBB8").CGColor, (id)colorFromHexString(@"28C76F").CGColor, nil]];
            if ([self badgeCount]) {
                id temp = badgerRetriveUniversalCountPref([self badgeCount],@"BadgeLabelColor");
                if (temp) {
                    badgeColor = [temp objectForKey:@"ColorName"];
                }
            } else {
                id temp = badgerRetriveUniversalPref(@"BadgeLabelColor");
                if (temp) {
                    badgeColor = [temp objectForKey:@"ColorName"];
                }
            }
        }
        if (!badgeColor) {
            badgeColor = @"Default (White)";
        }
        [_explainingBox setTextColor:[self matchingLabelColor:badgeColor]];
        [_label setTextColor:[self matchingLabelColor:badgeColor]];
        [_colorPicker selectRow:[colorsToPick indexOfObject:badgeColor] inComponent:0 animated:NO];
        if ([self appBundleID]) {
            [_explainingBox setText:[trans(@"This affects the label color for (APPNAME).") stringByReplacingOccurrencesOfString:@"(APPNAME)" withString:[self appName]]];
        } else {
            [_explainingBox setText:trans(@"This affects the label color for badges.")];
        }
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Font")]) {
        [_label setText:trans(@"Badge Font")];
        [_explainingBox setText:trans(@"This affects the font for badge labels.")];
        colorsToPick = [[NSArray alloc]initWithObjects:@"Default",@"Chalkduster",@"Didot",@"Copperplate",@"Papyrus",@"Zapfino",@"Baskerville",@"Courier",@"Custom", nil];
        NSString *badgeColor;
        //RPurpleGrad.png
        [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"E2B0FF").CGColor, (id)colorFromHexString(@"9F44D3").CGColor, nil]];
        if ([self badgeCount]) {
            badgeColor = badgerRetriveUniversalCountPref([self badgeCount],@"BadgeFont");
        } else {
            badgeColor = badgerRetriveUniversalPref(@"BadgeFont");
        }
        if (badgeColor == nil) {
            id currentBadgeFontPath = badgerRetriveCurrentPref(_badgeCount, [self appBundleID], @"BadgeFontPath");
            if (currentBadgeFontPath) {
                [_explainingBox setFont:fontFromFile(currentBadgeFontPath, 20.0)];
                [_label setFont:fontFromFile(currentBadgeFontPath, 23.0)];
                badgeColor = @"Custom";
            }
            if (![badgeColor isEqualToString:@"Custom"]) {
                badgeColor = @"Default";
            }
        }
        [_colorPicker selectRow:[colorsToPick indexOfObject:badgeColor] inComponent:0 animated:NO];
        if (![badgeColor isEqualToString:@"Default"] && ![badgeColor isEqualToString:@"Custom"]) {
            [_explainingBox setFont:[UIFont fontWithName:badgeColor size:20.0]];
            [_label setFont:[UIFont fontWithName:badgeColor size:23.0]];
        } else {
            if ([badgeColor isEqualToString:@"Default"]) {
                [_explainingBox setFont:[UIFont systemFontOfSize:20.0]];
                [_label setFont:[UIFont systemFontOfSize:23.0]];
            }
        }
    }
    
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
    
    // Do any additional setup after loading the view.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return trans([colorsToPick objectAtIndex:row]);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [colorsToPick count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (id)view;

        if (!label)
        {

            label= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
            label.textAlignment = NSTextAlignmentCenter;
            if ([[self cellTitle]isEqualToString:trans(@"Badge Color")] || [[self cellTitle]isEqualToString:trans(@"Badge Color for App")] || [[self cellTitle]isEqualToString:trans(@"Badge Label Color")] || [[self cellTitle]isEqualToString:trans(@"Badge Label Color for App")]) {
                label.textColor = [self matchingLabelColor:[colorsToPick objectAtIndex:row]];
            }
            if ([[self cellTitle]isEqualToString:trans(@"Badge Font")] && ![[colorsToPick objectAtIndex:row]isEqualToString:@"Default"]) {
                if ([[colorsToPick objectAtIndex:row]isEqualToString:@"Custom"]) {
                    id currentBadgeFontPath = badgerRetriveCurrentPref(_badgeCount, [self appBundleID], @"BadgeFontPath");
                    if (currentBadgeFontPath) {
                        label.font = fontFromFile(currentBadgeFontPath, 14.0);
                    }
                } else {
                    label.font = [UIFont fontWithName:[colorsToPick objectAtIndex:row] size:14.0];
                }
            } else {
                label.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];
            }
            label.text = trans([colorsToPick objectAtIndex:row]);
            label.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];

        }

        return label;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([[self cellTitle]isEqualToString:trans(@"Badge Color")] || [[self cellTitle]isEqualToString:trans(@"Badge Color for App")]) {
    [_explainingBox setTextColor:[self matchingLabelColor:[colorsToPick objectAtIndex:row]]];
    [_label setTextColor:[self matchingLabelColor:[colorsToPick objectAtIndex:row]]];
    if ([[colorsToPick objectAtIndex:row]isEqualToString:@"Default"]) {
        //remove BadgeColor since we're default anyway
        badgerRemoveCurrentPref([self badgeCount],[self appBundleID], @"BadgeColor");
    } else {
        CGFloat red, green, blue, alpha;
        if ([[colorsToPick objectAtIndex:row]isEqualToString:@"Custom"]) {
            red = 0.0;
            green = 0.0;
            blue = 0.0;
            alpha = 1.0;
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Badger"
                                                                           message:trans(@"Enter the hex code of your color.")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"...";
            }];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIColor *customColor = colorFromHexString([[alert textFields][0] text]);
                if (customColor) {
                    [customColor getRed:(CGFloat *)&red green:(CGFloat *)&green blue:(CGFloat *)&blue alpha:(CGFloat *)&alpha];
                    badgerSaveCurrentPref([self badgeCount],[self appBundleID], @"BadgeColor", [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",blue],@"Blue",[NSString stringWithFormat:@"%f",green],@"Green",[NSString stringWithFormat:@"%f",red],@"Red",[colorsToPick objectAtIndex:row],@"ColorName", nil]);
                    [self->_label setTextColor:customColor];
                    [self->_explainingBox setTextColor:customColor];
                    [((UILabel *)[self->_colorPicker viewForRow:[colorsToPick indexOfObject:@"Custom"] forComponent:0])setTextColor:customColor];
                }
            }];
            [alert addAction:confirmAction];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            [[self matchingLabelColor:[colorsToPick objectAtIndex:row]] getRed:&red green: &green blue: &blue alpha: &alpha];
            badgerSaveCurrentPref([self badgeCount],[self appBundleID], @"BadgeColor", [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",blue],@"Blue",[NSString stringWithFormat:@"%f",green],@"Green",[NSString stringWithFormat:@"%f",red],@"Red",[colorsToPick objectAtIndex:row],@"ColorName", nil]);
        }
    }
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Label Color")] || [[self cellTitle]isEqualToString:trans(@"Badge Label Color for App")]) {
        [_explainingBox setTextColor:[self matchingLabelColor:[colorsToPick objectAtIndex:row]]];
        [_label setTextColor:[self matchingLabelColor:[colorsToPick objectAtIndex:row]]];
        if ([[colorsToPick objectAtIndex:row]isEqualToString:@"Default (White)"]) {
            //remove BadgeColor since we're default anyway
            badgerRemoveCurrentPref([self badgeCount],[self appBundleID], @"BadgeLabelColor");
        } else {
            CGFloat red, green, blue, alpha;
            //[matchingLabelColor([colorsToPick objectAtIndex:row]) getRed:&red green: &green blue: &blue alpha: &alpha];
            [[self matchingLabelColor:[colorsToPick objectAtIndex:row]] getRed:&red green:&green blue:&blue alpha:&alpha];
            badgerSaveCurrentPref([self badgeCount],[self appBundleID], @"BadgeLabelColor", [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",blue],@"Blue",[NSString stringWithFormat:@"%f",green],@"Green",[NSString stringWithFormat:@"%f",red],@"Red",[colorsToPick objectAtIndex:row],@"ColorName", nil]);
        }
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Position")]) {
        //Badge Position
        if ([[colorsToPick objectAtIndex:row]isEqualToString:@"Default (Top Right)"]) {
            //remove BadgeColor since we're default anyway
            badgerRemoveUniversalPref(@"BadgePosition");
        } else {
            if ([[colorsToPick objectAtIndex:row]isEqualToString:@"Top Left"]) {
                badgerSaveUniversalPref(@"BadgePosition", [[NSDictionary alloc]initWithObjectsAndKeys:@54,@"CenterXOffset",@0,@"CenterYOffset",[colorsToPick objectAtIndex:row],@"PositionName", nil]);
            } else if ([[colorsToPick objectAtIndex:row]isEqualToString:@"Bottom Right"]) {
                badgerSaveUniversalPref(@"BadgePosition", [[NSDictionary alloc]initWithObjectsAndKeys:@0,@"CenterXOffset",@54,@"CenterYOffset",[colorsToPick objectAtIndex:row],@"PositionName", nil]);
            } else if ([[colorsToPick objectAtIndex:row]isEqualToString:@"Bottom Left"]) {
                badgerSaveUniversalPref(@"BadgePosition", [[NSDictionary alloc]initWithObjectsAndKeys:@54,@"CenterXOffset",@54,@"CenterYOffset",[colorsToPick objectAtIndex:row],@"PositionName", nil]);
            } else if ([[colorsToPick objectAtIndex:row]isEqualToString:@"Center"]) {
                badgerSaveUniversalPref(@"BadgePosition", [[NSDictionary alloc]initWithObjectsAndKeys:@30,@"CenterXOffset",@30,@"CenterYOffset",[colorsToPick objectAtIndex:row],@"PositionName", nil]);
            } else if ([[colorsToPick objectAtIndex:row]isEqualToString:@"Random"]) {
                //we need CenterXOffset and CenterYOffset pre-defined in case of 1.1->1.0 downgrade
                badgerSaveUniversalPref(@"BadgePosition", [[NSDictionary alloc]initWithObjectsAndKeys:@0,@"CenterXOffset",@0,@"CenterYOffset",[colorsToPick objectAtIndex:row],@"PositionName", nil]);
            }
        }
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Font")]) {
        if (![[colorsToPick objectAtIndex:row]isEqualToString:@"Default"] && ![[colorsToPick objectAtIndex:row]isEqualToString:@"Custom"]) {
            [_explainingBox setFont:[UIFont fontWithName:[colorsToPick objectAtIndex:row] size:20.0]];
            [_label setFont:[UIFont fontWithName:[colorsToPick objectAtIndex:row] size:23.0]];
        } else {
            if ([[colorsToPick objectAtIndex:row]isEqualToString:@"Custom"]) {
                
            } else {
                [_explainingBox setFont:[UIFont systemFontOfSize:20.0]];
                [_label setFont:[UIFont systemFontOfSize:23.0]];
            }
        }
        if ([[colorsToPick objectAtIndex:row]isEqualToString:@"Custom"]) {
            UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc]initWithDocumentTypes:[[NSArray alloc]initWithObjects:@"public.truetype-font", nil] inMode:UIDocumentPickerModeImport];
            documentPicker.delegate = self;
            [documentPicker setModalPresentationStyle:UIModalPresentationFormSheet];
            [self presentViewController:documentPicker animated:YES completion:nil];
        } else {
            if ([[colorsToPick objectAtIndex:row]isEqualToString:@"Default"]) {
                badgerRemoveCurrentPref([self badgeCount], nil, @"BadgeFont");
                badgerRemoveCurrentPref([self badgeCount], nil, @"BadgeFontPath");
            } else {
                badgerSaveCurrentPref([self badgeCount], nil, @"BadgeFont", [colorsToPick objectAtIndex:row]);
            }
        }
    } else {
        if ([[colorsToPick objectAtIndex:row]isEqualToString:@"Default"]) {
            //remove BadgeColor since we're default anyway
            badgerRemoveCurrentPref([self badgeCount],[self appBundleID], @"BadgeShape");
        } else {
            badgerSaveCurrentPref([self badgeCount],[self appBundleID], @"BadgeShape", [colorsToPick objectAtIndex:row]);
        }
    }
}
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if ([urls firstObject]) {
        badgerRemoveCurrentPref([self badgeCount],[self appBundleID], @"BadgeFontPath");
        badgerRemoveCurrentPref([self badgeCount],[self appBundleID], @"BadgeFont");
        if ([self badgeCount]) {
            if ([self appBundleID]) {
                FILE *file;
                if ((file = fopen([[NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/%ld-%@.ttf",_badgeCount,[self appBundleID]]UTF8String],"r"))) {
                    fclose(file);
                    remove([[NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/%ld-%@.ttf",_badgeCount,[self appBundleID]]UTF8String]);
                }
                [[NSFileManager defaultManager]copyItemAtURL:[urls firstObject] toURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/%ld-%@.ttf",_badgeCount,[self appBundleID]]] error:nil];
                badgerSaveAppCountPref(_badgeCount, [self appBundleID], @"BadgeFontPath", [NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/%ld-%@.ttf",_badgeCount,[self appBundleID]]);
                [_label setFont:fontFromFile([NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/%ld-%@.ttf",_badgeCount,[self appBundleID]], 23.0)];
                [_explainingBox setFont:fontFromFile([NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/%ld-%@.ttf",_badgeCount,[self appBundleID]], 20.0)];
                [((UILabel *)[self->_colorPicker viewForRow:[colorsToPick indexOfObject:@"Custom"] forComponent:0])setFont:fontFromFile([NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/%ld-%@.ttf",_badgeCount,[self appBundleID]], 14.0)];
            } else {
                FILE *file;
                if ((file = fopen([[NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/%ld.ttf",[self badgeCount]]UTF8String],"r"))) {
                    fclose(file);
                    remove([[NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/%ld.ttf",[self badgeCount]]UTF8String]);
                }
                [[NSFileManager defaultManager]copyItemAtURL:[urls firstObject] toURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/%ld.ttf",_badgeCount]] error:nil];
                badgerSaveUniversalCountPref(_badgeCount, @"BadgeFontPath", [NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/%ld.ttf",_badgeCount]);
                [_label setFont:fontFromFile([NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/%ld.ttf",_badgeCount], 23.0)];
                [_explainingBox setFont:fontFromFile([NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/%ld.ttf",_badgeCount], 20.0)];
                [((UILabel *)[self->_colorPicker viewForRow:[colorsToPick indexOfObject:@"Custom"] forComponent:0])setFont:fontFromFile([NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/%ld.ttf",_badgeCount], 14.0)];
            }
        } else {
            if ([self appBundleID]) {
                FILE *file;
                if ((file = fopen([[NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/Default-%@.ttf",[self appBundleID]]UTF8String],"r"))) {
                    fclose(file);
                    remove([[NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/Default-%@.ttf",[self appBundleID]]UTF8String]);
                }
                [[NSFileManager defaultManager]copyItemAtURL:[urls firstObject] toURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/Default-%@.ttf",[self appBundleID]]] error:nil];
                badgerSaveAppPref([self appBundleID], @"BadgeFontPath", [NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/Default-%@.ttf",[self appBundleID]]);
                [_label setFont:fontFromFile([NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/Default-%@.ttf",[self appBundleID]], 23.0)];
                [_explainingBox setFont:fontFromFile([NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/Default-%@.ttf",[self appBundleID]], 20.0)];
                [((UILabel *)[self->_colorPicker viewForRow:[colorsToPick indexOfObject:@"Custom"] forComponent:0])setFont:fontFromFile([NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/Default-%@.ttf",[self appBundleID]], 14.0)];
            } else {
                FILE *file;
                if ((file = fopen("/var/mobile/Library/Badger/BadgeFonts/Default.ttf","r"))) {
                    fclose(file);
                    remove("/var/mobile/Library/Badger/BadgeFonts/Default.ttf");
                }
                [[NSFileManager defaultManager]copyItemAtURL:[urls firstObject] toURL:[NSURL fileURLWithPath:@"/var/mobile/Library/Badger/BadgeFonts/Default.ttf"] error:nil];
                badgerSaveUniversalPref(@"BadgeFontPath", @"/var/mobile/Library/Badger/BadgeFonts/Default.ttf");
                [_label setFont:fontFromFile(@"/var/mobile/Library/Badger/BadgeFonts/Default.ttf", 23.0)];
                [_explainingBox setFont:fontFromFile(@"/var/mobile/Library/Badger/BadgeFonts/Default.ttf", 20.0)];
                [((UILabel *)[self->_colorPicker viewForRow:[colorsToPick indexOfObject:@"Custom"] forComponent:0])setFont:fontFromFile(@"/var/mobile/Library/Badger/BadgeFonts/Default.ttf", 14.0)];
            }
        }
        
    } else {
        //if user didn't select file, go back to BadgeFont if it exists, if not go to default
        id currentBadgeFont = badgerRetriveCurrentPref([self badgeCount], [self appBundleID], @"BadgeFont");
        if (currentBadgeFont) {
            [_colorPicker selectRow:[colorsToPick indexOfObject:currentBadgeFont] inComponent:0 animated:YES];
        } else {
            [_colorPicker selectRow:0 inComponent:0 animated:YES];
        }
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    //if user didn't select file, go back to BadgeFont if it exists, if not go to default
    id currentBadgeFont = badgerRetriveCurrentPref([self badgeCount], [self appBundleID], @"BadgeFont");
    if (currentBadgeFont) {
        [_colorPicker selectRow:[colorsToPick indexOfObject:currentBadgeFont] inComponent:0 animated:YES];
    } else {
        [_colorPicker selectRow:0 inComponent:0 animated:YES];
    }
}

-(UIColor*)matchingLabelColor:(NSString*)color {
    if ([color isEqualToString:@"Default (Red)"]) {
        return [UIColor redColor];
    } else if ([color isEqualToString:@"Pink"]) {
        return [UIColor systemPinkColor];
    } else if ([color isEqualToString:@"Orange"]) {
        return [UIColor orangeColor];
    } else if ([color isEqualToString:@"Yellow"]) {
        return [UIColor yellowColor];
    } else if ([color isEqualToString:@"Green"]) {
        return [UIColor greenColor];
    } else if ([color isEqualToString:@"Blue"]) {
        return [UIColor blueColor];
    } else if ([color isEqualToString:@"Purple"]) {
        return [UIColor purpleColor];
    } else if ([color isEqualToString:@"Magenta"]) {
        return [UIColor magentaColor];
    } else if ([color isEqualToString:@"Teal"]) {
        return [UIColor systemTealColor];
    } else if ([color isEqualToString:@"Brown"]) {
        return [UIColor brownColor];
    } else if ([color isEqualToString:@"White"]) {
        return [UIColor whiteColor];
    } else if ([color isEqualToString:@"Default (White)"]) {
        return [UIColor whiteColor];
    } else if ([color isEqualToString:@"Red"]) {
        return [UIColor redColor];
    } else if ([color isEqualToString:@"Gray"]) {
        return [UIColor grayColor];
    } else if ([color isEqualToString:@"Custom"]) {
        id currentBadgeColor;
        if ([[self cellTitle]isEqualToString:trans(@"Badge Color for App")] || [[self cellTitle]isEqualToString:trans(@"Badge Color")]) {
            currentBadgeColor = badgerRetriveCurrentPref([self badgeCount], [self appBundleID], @"BadgeColor");
        } else if ([[self cellTitle]isEqualToString:trans(@"Badge Label Color for App")] || [[self cellTitle]isEqualToString:trans(@"Badge Label Color")]) {
            currentBadgeColor = badgerRetriveCurrentPref([self badgeCount], [self appBundleID], @"BadgeLabelColor");
        }
        if (currentBadgeColor) {
            return [UIColor colorWithRed:[currentBadgeColor[@"Red"]floatValue] green:[currentBadgeColor[@"Green"]floatValue] blue:[currentBadgeColor[@"Blue"]floatValue] alpha:1.0];
        }
        return [UIColor colorWithRed:(arc4random_uniform(256) / 255.0) green:(arc4random_uniform(256) / 255.0) blue:(arc4random_uniform(256) / 255.0) alpha:1.0];
    } else if ([color isEqualToString:@"Random"]) {
        return [UIColor colorWithRed:(arc4random_uniform(256) / 255.0) green:(arc4random_uniform(256) / 255.0) blue:(arc4random_uniform(256) / 255.0) alpha:1.0];
    } else if ([color isEqualToString:@"App Color"]) {
           return [UIColor colorWithRed:(arc4random_uniform(256) / 255.0) green:(arc4random_uniform(256) / 255.0) blue:(arc4random_uniform(256) / 255.0) alpha:1.0];
    } else {
        return [UIColor blackColor];
    }
}
@end

UIFont *fontFromFile(NSString* filePath, CGFloat fontSize) {
 NSData *fileData = [NSData dataWithContentsOfFile:filePath];
 if(fileData) {
  CTFontDescriptorRef desc = CTFontManagerCreateFontDescriptorFromData((CFDataRef)fileData);
  if(desc != NULL){
   CTFontRef ctfont = CTFontCreateWithFontDescriptor(desc, fontSize, nil);
   UIFont *font = CFBridgingRelease(ctfont);
   return font;
  }
 }
 return nil;
}

UIColor* colorFromHexString(NSString* hexString) {
    NSString *sexString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![sexString containsString:@"#"]) {
        sexString = [@"#" stringByAppendingString:sexString];
    }
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:sexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

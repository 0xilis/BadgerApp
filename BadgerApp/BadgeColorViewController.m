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
@end

long badgeCount;
NSString *appBundleID;

@implementation BadgeColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    badgeCount = [self badgeCount];
    appBundleID = [self appBundleID];
    CAGradientLayer* betterBackGd = [[CAGradientLayer alloc]init];
    [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"81FBB8").CGColor, (id)colorFromHexString(@"28C76F").CGColor, nil]];
    [_label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:25.0f]];
    [_explainingBox setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    //remember to don't just set these to red, but once pref saving is implemented pull from prefs and get that color
    if ([daCellTitle isEqualToString:trans(@"Badge Color")] || [daCellTitle isEqualToString:trans(@"Badge Color for App")]) {
        colorsToPick = [[NSArray alloc]initWithObjects:@"Default (Red)",@"Pink",@"Orange",@"Yellow",@"Green",@"Blue",@"Purple",@"Magenta",@"Teal",@"Brown",@"Black",@"White",@"Gray",@"Custom",@"Random",@"App Color", nil];
        NSString *badgeColor;
        id temp = badgerRetriveCurrentPref(badgeCount,appBundleID,@"BadgeColor");
        if (temp) {
            badgeColor = temp[@"ColorName"];
        }
        if (appBundleID) {
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
    } else if ([daCellTitle isEqualToString:trans(@"Badge Position")]) {
        colorsToPick = [[NSArray alloc]initWithObjects:@"Default (Top Right)",@"Top Left",@"Bottom Right",@"Bottom Left",@"Center",@"Random", nil];
        id temp = badgerRetriveUniversalPref(@"BadgePosition");
        if (temp) {
            if (temp[@"PositionName"]) {
                [_colorPicker selectRow:[colorsToPick indexOfObject:temp[@"PositionName"]] inComponent:0 animated:NO];
            }
        }
        [_label setText:trans(@"Badge Position")];
        if (appBundleID) {
            [_explainingBox setText:[trans(@"This affects the badge position for (APPNAME).") stringByReplacingOccurrencesOfString:@"(APPNAME)" withString:[self appName]]];
        } else {
            [_explainingBox setText:trans(@"This affects the badge position for notification badges.")];
        }
        //ROrangeGrad.png
        [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"FFA959").CGColor, (id)colorFromHexString(@"FF5B51").CGColor, nil]];
        [_label setAlpha:0.5];
        [_explainingBox setAlpha:0.5];
        [_colorPicker setAlpha:0.5];
    } else if ([daCellTitle isEqualToString:trans(@"Badge Shape")] || [daCellTitle isEqualToString:trans(@"Badge Shape for App")]) {
        colorsToPick = [[NSArray alloc]initWithObjects:@"Default",@"Triangle",@"Square",@"Round Square",@"Hexagon", nil];
        id currentBadgeShape = badgerRetriveCurrentPref(badgeCount,appBundleID, @"BadgeShape");
        if (currentBadgeShape) {
            [_colorPicker selectRow:[colorsToPick indexOfObject:currentBadgeShape] inComponent:0 animated:NO];
        }
        [_label setText:trans(@"Badge Shape")];
        if (appBundleID) {
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
    } else if ([daCellTitle isEqualToString:trans(@"Badge Label Color")] || [daCellTitle isEqualToString:trans(@"Badge Label Color for App")]) {
        [_label setText:trans(@"Badge Label Color")];
        colorsToPick = [[NSArray alloc]initWithObjects:@"Default (White)",@"Red",@"Pink",@"Orange",@"Yellow",@"Green",@"Blue",@"Purple",@"Magenta",@"Teal",@"Brown",@"Black",@"Gray",@"Custom",@"Random", nil];
        NSString *badgeColor;
        if (appBundleID) {
            //RBlueGrad.png
            [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"ABDCFF").CGColor, (id)colorFromHexString(@"0396FF").CGColor, nil]];
        } else {
            //RGreenGrad.png
            [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"81FBB8").CGColor, (id)colorFromHexString(@"28C76F").CGColor, nil]];
        }
        id temp = badgerRetriveCurrentPref(badgeCount, appBundleID, @"BadgeLabelColor");
        if (temp) {
            badgeColor = temp[@"ColorName"];
        }
        if (!badgeColor) {
            badgeColor = @"Default (White)";
        }
        [_explainingBox setTextColor:[self matchingLabelColor:badgeColor]];
        [_label setTextColor:[self matchingLabelColor:badgeColor]];
        [_colorPicker selectRow:[colorsToPick indexOfObject:badgeColor] inComponent:0 animated:NO];
        if (appBundleID) {
            [_explainingBox setText:[trans(@"This affects the label color for (APPNAME).") stringByReplacingOccurrencesOfString:@"(APPNAME)" withString:[self appName]]];
        } else {
            [_explainingBox setText:trans(@"This affects the label color for badges.")];
        }
    } else if ([daCellTitle isEqualToString:trans(@"Badge Font")]) {
        [_label setText:trans(@"Badge Font")];
        [_explainingBox setText:trans(@"This affects the font for badge labels.")];
        colorsToPick = [[NSArray alloc]initWithObjects:@"Default",@"Chalkduster",@"Didot",@"Copperplate",@"Papyrus",@"Zapfino",@"Baskerville",@"Courier",@"Custom", nil];
        //RPurpleGrad.png
        [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"E2B0FF").CGColor, (id)colorFromHexString(@"9F44D3").CGColor, nil]];
        NSString *badgeColor = badgerRetriveCurrentPref(badgeCount,appBundleID,@"BadgeFont");
        UIFont *explainingBoxFont;
        UIFont *labelFont;
        if (badgeColor == nil) {
            id currentBadgeFontPath = badgerRetriveCurrentPref(badgeCount, appBundleID, @"BadgeFontPath");
            if (currentBadgeFontPath) {
                explainingBoxFont = fontFromFile(currentBadgeFontPath, 20.0);
                labelFont = fontFromFile(currentBadgeFontPath, 23.0);
                badgeColor = @"Custom";
            } else {
                badgeColor = @"Default";
            }
        } else {
            /* not Default, and NOT Custom Badge font */
            explainingBoxFont = [UIFont fontWithName:badgeColor size:20.0];
            labelFont = [UIFont fontWithName:badgeColor size:23.0];
        }
        [_colorPicker selectRow:[colorsToPick indexOfObject:badgeColor] inComponent:0 animated:NO];
        if ([badgeColor isEqualToString:@"Default"]) {
            explainingBoxFont = [UIFont systemFontOfSize:20.0];
            labelFont = [UIFont systemFontOfSize:23.0];
        }
        [_explainingBox setFont:explainingBoxFont];
        [_label setFont:labelFont];
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
    if (!label) {
        NSString *objAtIndex = [colorsToPick objectAtIndex:row];
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
        label.textAlignment = NSTextAlignmentCenter;
        if ([daCellTitle isEqualToString:trans(@"Badge Color")] || [daCellTitle isEqualToString:trans(@"Badge Color for App")] || [daCellTitle isEqualToString:trans(@"Badge Label Color")] || [daCellTitle isEqualToString:trans(@"Badge Label Color for App")]) {
            label.textColor = [self matchingLabelColor:objAtIndex];
        }
        if ([daCellTitle isEqualToString:trans(@"Badge Font")] && ![objAtIndex isEqualToString:@"Default"]) {
            if ([objAtIndex isEqualToString:@"Custom"]) {
                id currentBadgeFontPath = badgerRetriveCurrentPref(badgeCount, appBundleID, @"BadgeFontPath");
                if (currentBadgeFontPath) {
                    label.font = fontFromFile(currentBadgeFontPath, 14.0);
                }
            } else {
                label.font = [UIFont fontWithName:objAtIndex size:14.0];
            }
        } else {
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];
        }
        label.text = trans(objAtIndex);
        label.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
    }
    return label;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *objectAtIndex = [colorsToPick objectAtIndex:row];
    if ([daCellTitle isEqualToString:trans(@"Badge Color")] || [daCellTitle isEqualToString:trans(@"Badge Color for App")] || [daCellTitle isEqualToString:trans(@"Badge Label Color")] || [daCellTitle isEqualToString:trans(@"Badge Label Color for App")]) {
        NSString *prefInUse;
        if ([daCellTitle isEqualToString:trans(@"Badge Label Color")] || [daCellTitle isEqualToString:trans(@"Badge Label Color for App")]) {
            prefInUse = @"BadgeLabelColor";
        } else {
            prefInUse = @"BagdeColor";
        }
        UIColor *daColor = [self matchingLabelColor:objectAtIndex];
        [_explainingBox setTextColor:daColor];
        [_label setTextColor:daColor];
        if ([objectAtIndex isEqualToString:@"Default (Red)"]) {
            //remove BadgeColor/BadgeLabelColor since we're default anyway
            badgerRemoveCurrentPref(badgeCount,appBundleID, prefInUse);
        } else {
            if ([objectAtIndex isEqualToString:@"Custom"]) {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Badger"
                                                                           message:trans(@"Enter the hex code of your color.")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
                [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.placeholder = @"...";
                }];
                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    UIColor *customColor = colorFromHexString([[alert textFields][0] text]);
                    if (customColor) {
                        CGFloat red, green, blue, alpha;
                        red = 0.0;
                        green = 0.0;
                        blue = 0.0;
                        alpha = 1.0;
                        [customColor getRed:(CGFloat *)&red green:(CGFloat *)&green blue:(CGFloat *)&blue alpha:(CGFloat *)&alpha];
                        badgerSaveCurrentPref(badgeCount,appBundleID, prefInUse, @{
                            @"Blue" : [NSString stringWithFormat:@"%f",blue],
                            @"Green" : [NSString stringWithFormat:@"%f",green],
                            @"Red" : [NSString stringWithFormat:@"%f",red],
                            @"ColorName" : objectAtIndex,
                        });
                        [self->_label setTextColor:customColor];
                        [self->_explainingBox setTextColor:customColor];
                        [((UILabel *)[self->_colorPicker viewForRow:[colorsToPick indexOfObject:@"Custom"] forComponent:0])setTextColor:customColor];
                    }
                }];
                [alert addAction:confirmAction];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                CGFloat red, green, blue, alpha;
                [daColor getRed:&red green: &green blue: &blue alpha: &alpha];
                badgerSaveCurrentPref(badgeCount,appBundleID, prefInUse, @{
                    @"Blue" : [NSString stringWithFormat:@"%f",blue],
                    @"Green" : [NSString stringWithFormat:@"%f",green],
                    @"Red" : [NSString stringWithFormat:@"%f",red],
                    @"ColorName" : objectAtIndex,
                });
            }
        }
    } else if ([daCellTitle isEqualToString:trans(@"Badge Position")]) {
        //Badge Position
        if ([objectAtIndex isEqualToString:@"Default (Top Right)"]) {
            /* remove BadgePosition since we're default anyway */
            badgerRemoveUniversalPref(@"BadgePosition");
        } else {
            if ([objectAtIndex isEqualToString:@"Top Left"]) {
                badgerSaveUniversalPref(@"BadgePosition", [[NSDictionary alloc]initWithObjectsAndKeys:@54,@"CenterXOffset",@0,@"CenterYOffset",objectAtIndex,@"PositionName", nil]);
            } else if ([objectAtIndex isEqualToString:@"Bottom Right"]) {
                badgerSaveUniversalPref(@"BadgePosition", [[NSDictionary alloc]initWithObjectsAndKeys:@0,@"CenterXOffset",@54,@"CenterYOffset",objectAtIndex,@"PositionName", nil]);
            } else if ([objectAtIndex isEqualToString:@"Bottom Left"]) {
                badgerSaveUniversalPref(@"BadgePosition", [[NSDictionary alloc]initWithObjectsAndKeys:@54,@"CenterXOffset",@54,@"CenterYOffset",objectAtIndex,@"PositionName", nil]);
            } else if ([objectAtIndex isEqualToString:@"Center"]) {
                badgerSaveUniversalPref(@"BadgePosition", [[NSDictionary alloc]initWithObjectsAndKeys:@30,@"CenterXOffset",@30,@"CenterYOffset",objectAtIndex,@"PositionName", nil]);
            } else {
                //we need CenterXOffset and CenterYOffset pre-defined in case of 1.1->1.0 downgrade
                badgerSaveUniversalPref(@"BadgePosition", [[NSDictionary alloc]initWithObjectsAndKeys:@0,@"CenterXOffset",@0,@"CenterYOffset",objectAtIndex,@"PositionName", nil]);
            }
        }
    } else if ([daCellTitle isEqualToString:trans(@"Badge Font")]) {
        if ([objectAtIndex isEqualToString:@"Custom"]) {
            UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc]initWithDocumentTypes:[[NSArray alloc]initWithObjects:@"public.truetype-font", nil] inMode:UIDocumentPickerModeImport];
            documentPicker.delegate = self;
            [documentPicker setModalPresentationStyle:UIModalPresentationFormSheet];
            [self presentViewController:documentPicker animated:YES completion:nil];
        } else {
            if ([objectAtIndex isEqualToString:@"Default"]) {
                [_explainingBox setFont:[UIFont systemFontOfSize:20.0]];
                [_label setFont:[UIFont systemFontOfSize:23.0]];
                badgerRemoveCurrentPref(badgeCount, nil, @"BadgeFont");
                badgerRemoveCurrentPref(badgeCount, nil, @"BadgeFontPath");
            } else {
                [_explainingBox setFont:[UIFont fontWithName:objectAtIndex size:20.0]];
                [_label setFont:[UIFont fontWithName:objectAtIndex size:23.0]];
                badgerSaveCurrentPref(badgeCount, nil, @"BadgeFont", objectAtIndex);
            }
        }
    } else {
        if ([objectAtIndex isEqualToString:@"Default"]) {
            /* remove BadgeShape since we're default anyway */
            badgerRemoveCurrentPref(badgeCount,appBundleID, @"BadgeShape");
        } else {
            badgerSaveCurrentPref(badgeCount,appBundleID, @"BadgeShape", objectAtIndex);
        }
    }
}
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if ([urls firstObject]) {
        //badgerRemoveCurrentPref(badgeCount,appBundleID, @"BadgeFontPath");
        badgerRemoveCurrentPref(badgeCount,appBundleID, @"BadgeFont");
        NSString *filePath;
        if (badgeCount) {
            if (appBundleID) {
                filePath = [NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/%ld-%@.ttf",badgeCount,appBundleID];
            } else {
                filePath = [NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/%ld.ttf",badgeCount];
            }
        } else {
            if (appBundleID) {
                filePath = [NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeFonts/Default-%@.ttf",appBundleID];
            } else {
                filePath = @"/var/mobile/Library/Badger/BadgeFonts/Default.ttf";
            }
        }
        FILE *file;
        if ((file = fopen([filePath UTF8String],"r"))) {
            fclose(file);
            remove([filePath UTF8String]);
        }
        [[NSFileManager defaultManager]copyItemAtURL:[urls firstObject] toURL:[NSURL fileURLWithPath:filePath] error:nil];
        badgerSaveCurrentPref(badgeCount, appBundleID, @"BadgeFontPath", filePath);
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        CTFontDescriptorRef desc = CTFontManagerCreateFontDescriptorFromData((CFDataRef)fileData);
        UIFont *fontFromFileSize23 = fontFromDesc(desc, 23.0);
        UIFont *fontFromFileSize20 = fontFromDesc(desc, 20.0);
        UIFont *fontFromFileSize14 = fontFromDesc(desc, 14.0);
        [_label setFont:fontFromFileSize23];
        [_explainingBox setFont:fontFromFileSize20];
        [((UILabel *)[self->_colorPicker viewForRow:[colorsToPick indexOfObject:@"Custom"] forComponent:0])setFont:fontFromFileSize14];
    } else {
        /* ignore the error */
        /* this is an awful thing to do but it works, if we do it like this, we save a whole ~80 bytes!!! (that is nothing but BadgerApp's old binary being so big has made me a sucker for space optimizations) */
        [self documentPickerWasCancelled:0];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    //if user didn't select file, go back to BadgeFont if it exists, if not go to default
    id currentBadgeFont = badgerRetriveCurrentPref(badgeCount, appBundleID, @"BadgeFont");
    if (currentBadgeFont) {
        [_colorPicker selectRow:[colorsToPick indexOfObject:currentBadgeFont] inComponent:0 animated:YES];
    } else {
        [_colorPicker selectRow:0 inComponent:0 animated:YES];
    }
}

__attribute__((always_inline)) UIColor *getLastObjectFromDictionary(void) {
    UIColor *redColor;
    /* This results in mov x0, x0. This instruction is not needed so we could remove it to save an instruction, but I have no idea how to do this in a way the compiler would understand */
#if __aarch64__
    asm volatile (
        "mov %0, x0\n\t"
        : "=r" (redColor)
    );
#endif
    return redColor;
}

-(UIColor*)matchingLabelColor:(NSString*)color {
    /*
     * This makes all colors and then puts then in the NSDictionary. However, for some, ex Default (Red) and Red, we don't need to create two objects, we just need to create one and can have both point to the same, saving one objc_msgSend call. However, to my knowledge, there is no way to signify to use the same object pointer as another object in the dictionary in Objective-C. If we try to make a UIColor representing a redColor outside of the dictionary and have these keys point to the same obj it either recreates the object for the pointer or since the variable is not part of the NSDictionary creation messes up compiler optimizations, IDK which one but it does seem that it makes the binary larger and we don't want that. So, instead, we inline some arm64 asm. This works since when it's getting the next object, the x0 register still has the result of the previous obj_msgSend call for the last object. Because of this, we can just re-use x0 and have it work fine. This has the side affect of adding two not needed mov x0, x0 instructions but I don't know how to remove these easily. This, in return, saves of 5 instructions, but if you factor in the work obj_msgSend does and how we call it 2 times less, it's more like 45. This is a micro-optimization but I don't care at this point, I spent 2 hours on this I'm keeping it.
     */
#if __aarch64__
    NSDictionary *colorList = @{
        @"Default (Red)" : [UIColor redColor],
        @"Red" : getLastObjectFromDictionary(),
        @"Pink" : [UIColor systemPinkColor],
        @"Orange" : [UIColor orangeColor],
        @"Yellow" : [UIColor yellowColor],
        @"Green" : [UIColor greenColor],
        @"Blue" : [UIColor blueColor],
        @"Purple" : [UIColor purpleColor],
        @"Magenta" : [UIColor magentaColor],
        @"Teal" : [UIColor systemTealColor],
        @"Brown" : [UIColor brownColor],
        @"Default (White)" : [UIColor whiteColor],
        @"White" : getLastObjectFromDictionary(),
        @"Gray" : [UIColor grayColor],
    };
#else
    NSDictionary *colorList = @{
        @"Default (Red)" : [UIColor redColor],
        @"Red" : [UIColor redColor],
        @"Pink" : [UIColor systemPinkColor],
        @"Orange" : [UIColor orangeColor],
        @"Yellow" : [UIColor yellowColor],
        @"Green" : [UIColor greenColor],
        @"Blue" : [UIColor blueColor],
        @"Purple" : [UIColor purpleColor],
        @"Magenta" : [UIColor magentaColor],
        @"Teal" : [UIColor systemTealColor],
        @"Brown" : [UIColor brownColor],
        @"Default (White)" : [UIColor whiteColor],
        @"White" : [UIColor whiteColor],
        @"Gray" : [UIColor grayColor],
    };
#endif
    UIColor *retColor = colorList[color];
    if (retColor) {
        return retColor;
    }
    if ([color isEqualToString:@"Custom"]) {
        id currentBadgeColor;
        if ([daCellTitle isEqualToString:trans(@"Badge Color for App")] || [daCellTitle isEqualToString:trans(@"Badge Color")]) {
            currentBadgeColor = badgerRetriveCurrentPref(badgeCount, appBundleID, @"BadgeColor");
        } else if ([daCellTitle isEqualToString:trans(@"Badge Label Color for App")] || [daCellTitle isEqualToString:trans(@"Badge Label Color")]) {
            currentBadgeColor = badgerRetriveCurrentPref(badgeCount, appBundleID, @"BadgeLabelColor");
        }
        if (currentBadgeColor) {
            return [UIColor colorWithRed:[currentBadgeColor[@"Red"]floatValue] green:[currentBadgeColor[@"Green"]floatValue] blue:[currentBadgeColor[@"Blue"]floatValue] alpha:1.0];
        }
        return [UIColor colorWithRed:(arc4random_uniform(256) / 255.0) green:(arc4random_uniform(256) / 255.0) blue:(arc4random_uniform(256) / 255.0) alpha:1.0];
    }
    if ([color isEqualToString:@"Random"] || [color isEqualToString:@"App Color"]) {
        return [UIColor colorWithRed:(arc4random_uniform(256) / 255.0) green:(arc4random_uniform(256) / 255.0) blue:(arc4random_uniform(256) / 255.0) alpha:1.0];
    }
    return [UIColor blackColor];
}
@end

UIFont *fontFromDesc(CTFontDescriptorRef desc, CGFloat size) {
    CTFontRef ctFont = CTFontCreateWithFontDescriptor(desc, size, nil);
    return CFBridgingRelease(ctFont);
}

UIFont *fontFromFile(NSString* filePath, CGFloat fontSize) {
 NSData *fileData = [NSData dataWithContentsOfFile:filePath];
 if(fileData) {
  CTFontDescriptorRef desc = CTFontManagerCreateFontDescriptorFromData((CFDataRef)fileData);
  if(desc != NULL){
   return fontFromDesc(desc,fontSize);
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

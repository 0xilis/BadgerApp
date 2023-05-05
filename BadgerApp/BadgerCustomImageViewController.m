//
//  BadgerCustomImageViewController.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/16/22.
//

#import "BadgerCustomImageViewController.h"
#import "BadgerPrefHandler.h"
#import "BadgeColorViewController.h"

@interface BadgerCustomImageViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UITextView *explainingBox;
@property (weak, nonatomic) IBOutlet UIImageView *backgd;
@property (weak, nonatomic) IBOutlet UIButton *chooseImgButton;

@end

@implementation BadgerCustomImageViewController
- (void)viewDidLoad {
    /// <UINavigationBarDelegate, UIImagePickerControllerDelegate>
    [super viewDidLoad];
    CAGradientLayer* betterBackGd = [[CAGradientLayer alloc]init];
    //RBlueGrad.png
    [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"ABDCFF").CGColor, (id)colorFromHexString(@"0396FF").CGColor, nil]];
    [_labelTitle setAlpha:0.5];
    [_explainingBox setAlpha:0.5];
    [_chooseImgButton setAlpha:0.5];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [_chooseImgButton.layer setCornerRadius:5.0];
    if ([self appBundleID]) {
        //RPurpleGrad.png
        [betterBackGd setColors:[[NSArray alloc]initWithObjects:(id)colorFromHexString(@"E2B0FF").CGColor, (id)colorFromHexString(@"9F44D3").CGColor, nil]];
        [_chooseImgButton setBackgroundColor:[UIColor blueColor]];
        [_explainingBox setText:[trans(@"This affects the badge image for (APPNAME).") stringByReplacingOccurrencesOfString:@"(APPNAME)" withString:[self appName]]];
    } else {
        [_explainingBox setText:trans(@"This affects the image for notification badges.")];
    }
    [_chooseImgButton setTitle:trans(@"Choose Image") forState:UIControlStateNormal];
    if ([self badgeCount]) {
        if ([self appBundleID]) {
            if (badgerRetriveAppCountPref([self badgeCount],[self appBundleID], @"BadgeImagePath")) {
                //Safety check if image is not in the path
                UIImage *imageFromBadgeImagePath = [UIImage imageWithContentsOfFile:badgerRetriveAppCountPref([self badgeCount],[self appBundleID], @"BadgeImagePath")];
                if (imageFromBadgeImagePath) {
                    [_chooseImgButton setHidden:1];
                    UIImageView *badgeImage;
                    badgeImage = [[UIImageView alloc]initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width / 2 - 25, UIScreen.mainScreen.bounds.size.height / 2 - 25, 50, 50)];
                    badgeImage.image = imageFromBadgeImagePath;
                    [self.view addSubview:badgeImage];
                }
            }
        } else {
            if (badgerRetriveUniversalCountPref([self badgeCount], @"BadgeImagePath")) {
                //Safety check if image is not in the path
                UIImage *imageFromBadgeImagePath = [UIImage imageWithContentsOfFile:badgerRetriveUniversalCountPref([self badgeCount], @"BadgeImagePath")];
                if (imageFromBadgeImagePath) {
                    [_chooseImgButton setHidden:1];
                    UIImageView *badgeImage;
                    badgeImage = [[UIImageView alloc]initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width / 2 - 25, UIScreen.mainScreen.bounds.size.height / 2 - 25, 50, 50)];
                    badgeImage.image = imageFromBadgeImagePath;
                    [self.view addSubview:badgeImage];
                }
            }
        }
    } else {
        if ([self appBundleID]) {
            if (badgerRetriveAppPref([self appBundleID],@"BadgeImagePath")) {
                //Safety check if image is not in the path
                UIImage *imageFromBadgeImagePath = [UIImage imageWithContentsOfFile:badgerRetriveAppPref([self appBundleID],@"BadgeImagePath")];
                if (imageFromBadgeImagePath) {
                    [_chooseImgButton setHidden:1];
                    UIImageView *badgeImage;
                    badgeImage = [[UIImageView alloc]initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width / 2 - 25, UIScreen.mainScreen.bounds.size.height / 2 - 25, 50, 50)];
                    badgeImage.image = imageFromBadgeImagePath;
                    [self.view addSubview:badgeImage];
                }
            }
        } else {
            if (badgerRetriveUniversalPref(@"BadgeImagePath")) {
                //Safety check if image is not in the path
                UIImage *imageFromBadgeImagePath = [UIImage imageWithContentsOfFile:badgerRetriveUniversalPref(@"BadgeImagePath")];
                if (imageFromBadgeImagePath) {
                    [_chooseImgButton setHidden:1];
                    UIImageView *badgeImage;
                    badgeImage = [[UIImageView alloc]initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width / 2 - 25, UIScreen.mainScreen.bounds.size.height / 2 - 25, 50, 50)];
                    badgeImage.image = imageFromBadgeImagePath;
                    [self.view addSubview:badgeImage];
                }
            }
        }
    }
    
    //set up gradient
    [betterBackGd setStartPoint:CGPointMake(0, 0)];
    [betterBackGd setEndPoint:CGPointMake(1, 1)];
    [betterBackGd setFrame:[[self view] bounds]]; //CGRectMake(0, 0, [[self view]frame].size.width, [[self view]frame].size.height)
    [betterBackGd setType:kCAGradientLayerAxial];
    [[[self view]layer]insertSublayer:betterBackGd atIndex:0];
    
    // Do any additional setup after loading the view.
}

- (IBAction)pressChooseImageButton:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //imagePicker.delegate = self;
    //imagePicker.allowsEditing = YES;
    //imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    //imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePicker animated:YES completion:nil];
    [imagePicker setDelegate:self];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [_chooseImgButton setHidden:1];
    //applicationFrame deprecated iOS 9.0+
    UIImageView *badgeImage;
    //if (@available(iOS 9.0, *)) {
        badgeImage = [[UIImageView alloc]initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width / 2 - 25, UIScreen.mainScreen.bounds.size.height / 2 - 25, 50, 50)];
    /*} else {
        badgeImage = [[UIImageView alloc]initWithFrame:CGRectMake(UIScreen.mainScreen.applicationFrame.size.width / 2 - 25, UIScreen.mainScreen.applicationFrame.size.height / 2 - 25, 50, 50)];
    }*/
    badgeImage.image = [self imageWithImage:selectedImage scaledToSize:CGSizeMake(24,24)];
    NSData* binaryImageData = UIImagePNGRepresentation([self imageWithImage:selectedImage scaledToSize:CGSizeMake(24,24)]);
    if ([self badgeCount]) {
        if ([self appBundleID]) {
            [binaryImageData writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeImages/%@.png",[NSString stringWithFormat:@"%ld-%@",_badgeCount,[self appBundleID]]] atomically:YES];
            badgerSaveAppCountPref(_badgeCount, [self appBundleID],@"BadgeImagePath", [NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeImages/%@.png",[NSString stringWithFormat:@"%ld-%@",_badgeCount,[self appBundleID]]]);
        } else {
            [binaryImageData writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeImages/%@.png",[NSString stringWithFormat:@"%ld",_badgeCount]] atomically:YES];
            badgerSaveUniversalCountPref(_badgeCount, @"BadgeImagePath", [NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeImages/%@.png",[NSString stringWithFormat:@"%ld",_badgeCount]]);
        }
    } else {
        if ([self appBundleID]) {
            [binaryImageData writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeImages/Default-%@.png",[self appBundleID]] atomically:YES];
            badgerSaveAppPref([self appBundleID],@"BadgeImagePath", [NSString stringWithFormat:@"/var/mobile/Library/Badger/BadgeImages/Default-%@.png",[self appBundleID]]);
        } else {
            [binaryImageData writeToFile:@"/var/mobile/Library/Badger/BadgeImages/Default.png" atomically:YES];
            badgerSaveUniversalPref(@"BadgeImagePath", @"/var/mobile/Library/Badger/BadgeImages/Default.png");
        }
    }
    
    [self.view addSubview:badgeImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end

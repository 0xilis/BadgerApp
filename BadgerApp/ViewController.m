//
//  ViewController.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 8/26/22.
//

#import "ViewController.h"
#import "BadgeCountMinimumViewController.h"
#import "BadgerAppSelectionViewController.h"
#import "BadgeColorViewController.h"
/*#import <sys/stat.h>
#import <sys/types.h>
#import <unistd.h>
#include <dlfcn.h>
#import <spawn.h>*/
#import "BadgerCountConfigManagerViewController.h"
#import "BadgerPrefHandler.h"
#import "BadgerVersionInfo.h"
#import "BadgerTableViewCell.h"
#import "BadgerApplySettingsViewController.h"
#import "BadgerCreditsViewController.h"
#import "BadgerTopNotchCoverView.h"

#define ROWS 20

#define TRIAL 0

#define TRANS 0

NSArray *cellTitles;
NSMutableArray *filteredCells;

UIView *topNotchCover;

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@end

@implementation ViewController

-(BOOL)shouldAutorotate {
    return NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    cellTitles = [[NSArray alloc]initWithObjects:@"Badge Count Minimum",@"Badge Count Minimum for App",@"Badge Count Limit",@"Badge Color",@"Badge Color for App",@"Badge Opacity",@"Badge Opacity for App",@"Badge Position",@"Badge Shape",@"Badge Shape for App",@"Badge Image",@"Badge Image for App",@"Custom Badge Label",@"Badge Size",@"Badge Size for App",@"Badge Label Color",@"Badge Label Color for App",@"Badge Font",@"Apply Settings",@"Credits", nil];
    @autoreleasepool {
        NSMutableArray *mutableCellTitles = [[NSMutableArray alloc]init];
        for (NSString* cellTitle in cellTitles) {
            [mutableCellTitles addObject:trans(cellTitle)];
        }
        cellTitles = [[NSArray alloc]initWithArray:mutableCellTitles];
    }
    filteredCells = [cellTitles mutableCopy];
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    // https://stackoverflow.com/questions/65330737/uinavigationcontroller-and-large-titles-when-popping-viewcontroller
    [[self navigationItem]setLargeTitleDisplayMode:UINavigationItemLargeTitleDisplayModeAlways];
    
    //https://stackoverflow.com/questions/64005273/ios14-navigationitem-largetitledisplaymode-always-not-work
    //*maybe* this is needed on iOS 14+?
    [[[self navigationController]navigationBar]sizeToFit];
    
#if TRIAL
    //TODO: Note, this is dumb. Why am I protecting against hooking, these checks are not obfuscated at all and can easily be patched out. Oh wait yeah I decided to not burn myself into obfuscation and DRM to just be used for betas (well ig this will be used for the trial system as well but anyway), and instead just focus on the good tweak. Still leaving this here though since ig it does prevent simple flex patches from forcing no expire
    BadgerVersionInfo *versionInfo = [[BadgerVersionInfo alloc]init];
    [versionInfo populateSelfWithInfo];
    [versionInfo checkIsExpired];
    if ([versionInfo isExpired]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Badger Beta Build Expired"
                                                                       message:[NSString stringWithFormat:@"Beta %@ (%@) has expired. Please install the latest non-beta build from Havoc, or ask for a new beta.",[versionInfo badgerVersion],[versionInfo badgerBuild]]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            exit(7829);
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    //protect against BadgerVersionInfo isExpired hooking
    [versionInfo setIsExpired:YES];
    if (![versionInfo isExpired]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Badger Beta Build Expired"
                                                                       message:[NSString stringWithFormat:@"Beta %@ (%@) has expired. Please install the latest non-beta build from Havoc, or ask for a new beta.",[versionInfo badgerVersion],[versionInfo badgerBuild]]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            exit(7829);
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    //protect against BadgerVersionInfo buildCanExpire hooking
    [versionInfo setBuildCanExpire:YES];
    if (![versionInfo buildCanExpire]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Badger Beta Build Expired"
                                                                       message:[NSString stringWithFormat:@"Beta %@ (%@) has expired. Please install the latest non-beta build from Havoc, or ask for a new beta.",[versionInfo badgerVersion],[versionInfo badgerBuild]]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            exit(7829);
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    //protect against BadgerVersionInfo versionExpireDate hooking, using random number so a tweak can't just check if version expire date equals something
    srand((unsigned int)time(NULL));
    int minRange = 20210101;
    long maxRange = [[NSString stringWithUTF8String:[versionInfo versionExpireDate]]integerValue] - 1;
    int randvalue = rand()%((maxRange+1)-minRange) + minRange;
    [versionInfo setVersionExpireDate:((char *)[[NSString stringWithFormat:@"%d",randvalue]UTF8String])];
    if (![[NSString stringWithUTF8String:[versionInfo versionExpireDate]]isEqualToString:[NSString stringWithFormat:@"%d",randvalue]]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Badger Beta Build Expired"
                                                                       message:[NSString stringWithFormat:@"Beta %@ (%@) has expired. Please install the latest non-beta build from Havoc, or ask for a new beta.",[versionInfo badgerVersion],[versionInfo badgerBuild]]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            exit(7829);
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    //protect against BadgerVersionInfo checkIsExpired hooking, using our rand VED to prevent checking if specific VED and if so NO, else YES. ~~Also check if our values are the same as before we sent them to prevent from simply setting versionInfo values in checkIsExpired~~ prob not needed
    [versionInfo setVersionExpireDate:((char *)[[NSString stringWithFormat:@"%d",randvalue]UTF8String])];
    [versionInfo setBuildCanExpire:YES];
    [versionInfo checkIsExpired];
    if (![versionInfo isExpired]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Badger Beta Build Expired"
                                                                       message:[NSString stringWithFormat:@"Beta %@ (%@) has expired. Please install the latest non-beta build from Havoc, or ask for a new beta.",[versionInfo badgerVersion],[versionInfo badgerBuild]]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            exit(7829);
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    if (![versionInfo buildCanExpire]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Badger Beta Build Expired"
                                                                       message:[NSString stringWithFormat:@"Beta %@ (%@) has expired. Please install the latest non-beta build from Havoc, or ask for a new beta.",[versionInfo badgerVersion],[versionInfo badgerBuild]]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            exit(7829);
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    if (![[NSString stringWithUTF8String:[versionInfo versionExpireDate]]isEqualToString:[NSString stringWithFormat:@"%d",randvalue]]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Badger Beta Build Expired"
                                                                       message:[NSString stringWithFormat:@"Beta %@ (%@) has expired. Please install the latest non-beta build from Havoc, or ask for a new beta.",[versionInfo badgerVersion],[versionInfo badgerBuild]]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            exit(7829);
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
#endif
    
    FILE *file;
    
    if ((file = fopen("/var/mobile/Library/Badger/Prefs/BadgerPrefs.plist","r"))) {
        fclose(file);
    } else {
        badgerSetUpPrefPlistAtSpecificLocation(@"/var/mobile/Library/Badger/Prefs/BadgerPrefs.plist");
    }
    
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    //TODO: Provide an option for iOS 12- users to have dark mode rather than defaulting them to light mode with no option to switch.
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    }
    self.navigationItem.title = @"Badger";
    if (@available(iOS 13.0, *)) {
        self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStyleInsetGrouped];
    } else {
        self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStylePlain];
    }
    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
    [self.view addSubview:self.myTableView];
    
    //for ios 11+, since navigation bar may be below status bar, creating some funky looks with the table view
    topNotchCover = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height)]; //height 96 on 852, 91 on 548
    topNotchCover.hidden = NO;
    if (@available(iOS 13.0, *)) {
        [topNotchCover setBackgroundColor:[UIColor systemBackgroundColor]];
    } else {
        [topNotchCover setBackgroundColor:[UIColor whiteColor]];
    }
    [self.view addSubview:topNotchCover];
    // make the VC conform to UISearchBarDelegate and update the contents like that
    UISearchController *searchController = [[UISearchController alloc] init];
    searchController.searchBar.delegate = self;
    self.navigationItem.searchController = searchController;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    // Do any additional setup after loading the view.
    if (@available(iOS 13.0, *)) { } else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    }
    BOOL didPresentNoPlistAlert = NO;
    if (badgerDoesHaveCompatibilitySafetyFlags() == NO) {
        //Does not have the compatibility safety flags that were added in 1.2.2 - add them
        if (badgerAddMinimumCompatibilityVersion() == NO) {
            //This function only returns NO when badgerPlist cannot be found. Show an alert.
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Badger" message:trans(@"BadgerApp cannot seem to load preferences. This may cause unexpected behavior.") preferredStyle:UIAlertControllerStyleActionSheet];

            UIAlertAction *okAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                //action when pressed button
            }];
            
            [alertController addAction:okAction];
            
            [[alertController popoverPresentationController]setSourceRect:CGRectMake(0, 0, 0, 0)];
            [[alertController popoverPresentationController]setSourceView:[self view]];
            
            [self.parentViewController presentViewController:alertController animated:YES completion:nil];
            didPresentNoPlistAlert = YES;
        }
    }
    if (badgerIsCompatibleWithConfiguration() == NO && !didPresentNoPlistAlert && badgerDoesHaveCompatibilitySafetyFlags()) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Badger" message:[trans(@"Your Badger configuration is not compatible with this version. Please upgrade to Badger (BADGER_MINIMUM_COMPATIBILITY_VERSION) or higher. You can optionally choose to reset your configuration file to use this outdated version.") stringByReplacingOccurrencesOfString:@"(BADGER_MINIMUM_COMPATIBILITY_VERSION)" withString:badgerGetMinimumCompatibilityVersion()] preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *okAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            //action when pressed button
        }];
        
        UIAlertAction *resetAction = [UIAlertAction actionWithTitle:trans(@"Reset") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            //action when pressed button
        }];
        
        [alertController addAction:okAction];
        [alertController addAction:resetAction];
        
        //thank u to https://stackoverflow.com/questions/60516848/swift-set-uibarbuttonitem-as-source-for-popover-without-tap for letting me know how to have my app not crash on iOS 12
        [[alertController popoverPresentationController]setSourceRect:CGRectMake(0, 0, 0, 0)];
        [[alertController popoverPresentationController]setSourceView:[self view]];
        
        [self.parentViewController presentViewController:alertController animated:YES completion: nil];
    }
    //For some strange, inexplicable reason, the prefersLargeTitles navbar condenses if we show an alert. After toying around with it for a day I found that calling sendSubviewToBack somehow fixes it???? So we workaround this behavior by creating a useless view and send it to the back. If you know *why* this happens, please get in contact with me (Snoolie K) because words cannot describe my confusion.
    UIView *genericView = [[UIView alloc]init];
    [self.view addSubview:genericView];
    [self.view sendSubviewToBack:genericView];
    BadgerTopNotchCoverView *topTopNotchCoverView = [[BadgerTopNotchCoverView alloc]init];
    if (@available(iOS 13.0, *)) {
        [topTopNotchCoverView setBackgroundColor:[UIColor systemBackgroundColor]];
    } else {
        [topTopNotchCoverView setBackgroundColor:[UIColor whiteColor]];
    }
    [topTopNotchCoverView setFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[[self navigationController]navigationBar]frame].origin.y)];
    [self.navigationController.view addSubview:topTopNotchCoverView];
}

//TODO: Hacky workaround for the infamous navbar bug. It's hacky but I have had no idea how to fix this since 1.0 and I'm so happy to finally find a workaround in 1.2.2 even if it's not how to properly fix.
- (void)viewWillAppear:(BOOL)animated {
    [self updateTopNotchCoverSize];
}

//TODO: On iOS 12+ this is fine, but on iOS 13+ we change the color of the one navigation bars (different view controllers don't have different navbar bgs, they should) so it looks a little weird when moving. I thought, ok, small issue, but you only really notice it if you look close, so I'll fix this later but no need to fix it for now, but the swipe gesture makes this issue much more noticable to a terrible degree so now I actually need to fucking fix it in Badger 1.3 or Badger 1.2.2.
- (void)viewDidAppear:(BOOL)animated {
    if (@available(iOS 13.0, *)) {
        self.navigationController.navigationBar.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    }
    [self.navigationItem.searchController.searchBar setPlaceholder:trans(@"Enter a setting...")];
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    if (self.navigationController.navigationBar.frame.size.height == self.navigationItem.searchController.searchBar.frame.origin.y) {
        [topNotchCover setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height + self.navigationItem.searchController.searchBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y)];
    } else if (self.navigationController.navigationBar.frame.size.height > 0) {
        [topNotchCover setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y)];
    }
    [BadgerTopNotchCoverView reappear:self.navigationController.view];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [filteredCells count];
}

-(BadgerTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BadgerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[BadgerTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
#if TRANS
    cell.backgroundColor = basedCellColorFromRow(indexPath.row);
#endif
    cell.textLabel.text = cellTitleFromRow(indexPath.row);
    cell.imageView.image = cellImageFromTitle(cellTitleFromRow(indexPath.row));
    [cell.textLabel setAdjustsFontSizeToFitWidth:1];
    //If we got a row that for whatever fucking reason appears even if we already have all the rows we need, hide it. Actually the better solution is to just probably return nil or something because this might look the scrolling look weird but whatever, this was really only needed back in the September builds.
    if (indexPath.row > (ROWS-1)) {
        [cell setHidden:1];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell.imageView.layer setMasksToBounds:YES];
    [cell.imageView.layer setCornerRadius:8.0];
    [cell.imageView setClipsToBounds:YES];
    return cell;
}
//TODO: Ugly method, improve later in Badger 1.3 when we switch to no storyboards (i suck at them)
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateTopNotchCoverSize];
    NSString *cellTitle = cellTitleFromRow(indexPath.row);
    Class cellInfo = NSClassFromString(@"cellInfo");
    id cellInfoInstance = [cellInfo sharedInstance];
    [cellInfoInstance addObserver:self];
    if (cellInfoInstance) {
        [cellInfoInstance setCellTitle:cellTitle];
    }
    if ([cellTitle isEqualToString:trans(@"Badge Count Minimum")]) {
        [BadgerTopNotchCoverView disappear:self.navigationController.view];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeCountMinimumViewController *myNewVC = (BadgeCountMinimumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeCountMinimumViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Count Minimum for App")]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Count Limit")]) {
        [BadgerTopNotchCoverView disappear:self.navigationController.view];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeCountMinimumViewController *myNewVC = (BadgeCountMinimumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeCountMinimumViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Count Limit for App")]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Color")]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Opacity")]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Position")]) {
        [BadgerTopNotchCoverView disappear:self.navigationController.view];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeColorViewController *myNewVC = (BadgeColorViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeColorViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Shape")]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Image")]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Custom Badge Label")]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Color for App")]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Opacity for App")]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Shape for App")]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Size")]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([cellTitle isEqualToString:trans(@"Badge Size for App")]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([cellTitle isEqualToString:trans(@"Badge Label Color")]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([cellTitle isEqualToString:trans(@"Badge Label Color for App")]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([cellTitle isEqualToString:trans(@"Badge Image for App")]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([cellTitle isEqualToString:trans(@"Badge Position for App")]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([cellTitle isEqualToString:trans(@"Badge Font")]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Apply Settings")]) {
        
        [BadgerTopNotchCoverView disappear:self.navigationController.view];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerApplySettingsViewController *myNewVC = (BadgerApplySettingsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerApplySettingsViewController"];
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Credits")]) {
        
        [BadgerTopNotchCoverView disappear:self.navigationController.view];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCreditsViewController *myNewVC = (BadgerCreditsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCreditsViewController"];
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    }
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}
//Serena told me that big cells look ugly so commenting this shit out
/*-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 50;//return 66; //orig 44.0
}*/
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    filteredCells = [[NSMutableArray alloc]init];
    if ([searchText isEqualToString:@""]) {
        filteredCells = [cellTitles mutableCopy];
    } else {
        for (NSString* aCellTitle in cellTitles) {
            if ([[aCellTitle lowercaseString]containsString:[searchText lowercaseString]]) {
                [filteredCells addObject:aCellTitle];
            }
        }
    }
    [_myTableView reloadData];
    [self updateTopNotchCoverSize];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    filteredCells = [cellTitles mutableCopy];
    [_myTableView reloadData];
    [self updateTopNotchCoverSize];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self updateTopNotchCoverSize];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if (self.navigationItem.searchController.searchBar.frame.origin.y > 0) {
        //[topNotchCover setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationItem.searchController.searchBar.frame.origin.y)];
        [topNotchCover setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.origin.y)];
    }
}
-(void)updateTopNotchCoverSize {
    if (self.navigationController.navigationBar.frame.size.height == self.navigationItem.searchController.searchBar.frame.origin.y) {
        [topNotchCover setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height + self.navigationItem.searchController.searchBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y)];
    } else if (self.navigationItem.searchController.searchBar.frame.origin.y != 0) {
        [topNotchCover setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationItem.searchController.searchBar.frame.size.height + self.navigationItem.searchController.searchBar.frame.origin.y + self.navigationController.navigationBar.frame.origin.y)];
    } else if (self.navigationController.navigationBar.frame.size.height > 0) {
        [topNotchCover setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.origin.y + self.navigationItem.searchController.searchBar.frame.size.height)];
    }
}
@end
NSString *cellTitleFromRow(long row) {
    //yes this function is used
    return [cellTitles objectAtIndex:row];
}

int cellRowFromTitle(NSString *cellTitle) {
    int cellRow = 0;
    while ((!([[filteredCells objectAtIndex:cellRow]isEqualToString:cellTitle])) && cellRow <= filteredCells.count) {
        cellRow++;
    }
    if (cellRow > filteredCells.count) {
        return -1;
    }
    return cellRow;
}

UIImage* cellImageFromTitle(NSString* cellTitle) {
    if ([cellTitle isEqualToString:trans(@"Badge Count Minimum")] || [cellTitle isEqualToString:trans(@"Badge Count Minimum for App")]) {
        return [UIImage imageNamed:@"MinimumBadge.png"];
    } else if ([cellTitle isEqualToString:trans(@"Badge Count Limit")] || [cellTitle isEqualToString:trans(@"Badge Count Limit for App")]) {
        return [UIImage imageNamed:@"MaxBadge.png"];
    } else if ([cellTitle isEqualToString:trans(@"Badge Color")] || [cellTitle isEqualToString:trans(@"Badge Color for App")]) {
        return [UIImage imageNamed:@"ColorBadge.png"];
    } else if ([cellTitle isEqualToString:trans(@"Badge Opacity")] || [cellTitle isEqualToString:trans(@"Badge Opacity for App")]) {
        return [UIImage imageNamed:@"BadgeOpacity.png"];
    } else if ([cellTitle isEqualToString:trans(@"Badge Position")] || [cellTitle isEqualToString:trans(@"Badge Position for App")]) {
        return [UIImage imageNamed:@"BadgePos.png"];
    } else if ([cellTitle isEqualToString:trans(@"Badge Shape")] || [cellTitle isEqualToString:trans(@"Badge Shape for App")]) {
        return [UIImage imageNamed:@"BadgeShape.png"];
    } else if ([cellTitle isEqualToString:trans(@"Badge Image")] || [cellTitle isEqualToString:trans(@"Badge Image for App")]) {
        return [UIImage imageNamed:@"ImageBadge.png"];
    } else if ([cellTitle isEqualToString:trans(@"Custom Badge Label")] || [cellTitle isEqualToString:trans(@"Custom Badge Label for App")]) {
        return [UIImage imageNamed:@"CustomLabelBadge.png"];
    } else if ([cellTitle isEqualToString:trans(@"Badge Size")] || [cellTitle isEqualToString:trans(@"Badge Size for App")]) {
        return [UIImage imageNamed:@"BadgeSize.png"];
    } else if ([cellTitle isEqualToString:trans(@"Badge Label Color")] || [cellTitle isEqualToString:trans(@"Badge Label Color for App")]) {
        return [UIImage imageNamed:@"BadgeLabelColor.png"];
    } else if ([cellTitle isEqualToString:trans(@"Badge Font")]) {
        return [UIImage imageNamed:@"BadgeFont.png"];
    } else if ([cellTitle isEqualToString:trans(@"Apply Settings")]) {
        return [UIImage imageNamed:@"ReloadBadger.png"];
    } else if ([cellTitle isEqualToString:trans(@"Credits")]) {
        return [UIImage imageNamed:@"Credits.png"];
    }
    return NULL;
}

UIColor *basedCellColorFromRow(long row) { //UNUSED: i compile Badger app with #TRANS on to make it 100% more epic. in the final release version, this function is not ever used.
    int colorId = row % 4;
    CGFloat red, green, blue, alpha;
    UIColor* cellColor;
    switch(colorId) {
        case 0:
            cellColor = colorFromHexString(@"55CDFC");
            break;
        case 1:
            cellColor = colorFromHexString(@"F7A8B8");
            break;
        case 2:
            cellColor = colorFromHexString(@"FFFFFF");
            break;
        case 3:
            cellColor = colorFromHexString(@"F7A8B8");
            break;
        default:
            NSLog(@"Badger Error: No color set for cell colorId %d\n",colorId);
            return [UIColor whiteColor];
    }
    [cellColor getRed:&red green: &green blue: &blue alpha: &alpha]; //iOS 5.0+
    return [UIColor colorWithRed:red green:green blue:blue alpha:0.5];
}

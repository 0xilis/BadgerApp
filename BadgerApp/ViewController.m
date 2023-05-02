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
#import <CloudKit/CloudKit.h>

#define ROWS 20

#define TRIAL 0

#define TRANS 0

NSArray *cellTitles;
NSMutableArray *filteredCells;

/*void patch_setuid(void) {
    void* handle = dlopen("/usr/lib/libjailbreak.dylib", RTLD_LAZY);
    if (!handle)
        return;

    // Reset errors
    dlerror();
    typedef void (*fix_setuid_prt_t)(pid_t pid);
    fix_setuid_prt_t ptr = (fix_setuid_prt_t)dlsym(handle, "jb_oneshot_fix_setuid_now");
    
    const char *dlsym_error = dlerror();
    if (dlsym_error)
        return;

    ptr(getpid());
}*/

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
    if (@available(iOS 13.0, *)) {
        cellTitles = [[NSArray alloc]initWithObjects:@"Badge Count Minimum",@"Badge Count Minimum for App",@"Badge Count Limit",@"Badge Color",@"Badge Color for App",@"Badge Opacity",@"Badge Opacity for App",@"Badge Position",@"Badge Shape",@"Badge Shape for App",@"Badge Image",@"Badge Image for App",@"Custom Badge Label",@"Badge Size",@"Badge Size for App",@"Badge Label Color",@"Badge Label Color for App",@"Badge Font",@"Apply Settings",@"Credits", nil];
    } else {
        //BadgeFont not available on iOS 12 currently
        cellTitles = [[NSArray alloc]initWithObjects:@"Badge Count Minimum",@"Badge Count Minimum for App",@"Badge Count Limit",@"Badge Color",@"Badge Color for App",@"Badge Opacity",@"Badge Opacity for App",@"Badge Position",@"Badge Shape",@"Badge Shape for App",@"Badge Image",@"Badge Image for App",@"Custom Badge Label",@"Badge Size",@"Badge Size for App",@"Badge Label Color",@"Badge Label Color for App",@"Apply Settings",@"Credits", nil];
    }
    @autoreleasepool {
        NSMutableArray *mutableCellTitles = [[NSMutableArray alloc]init];
        for (NSString* cellTitle in cellTitles) {
            [mutableCellTitles addObject:trans(cellTitle)];
        }
        cellTitles = [[NSArray alloc]initWithArray:mutableCellTitles];
    }
    filteredCells = [cellTitles mutableCopy];
    
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
    //I read that apparently this was needed on Electra but I am no longer needing iOS 11 support so commented this out for now, if Havoc payment ever supports iOS 11 look into this again.
    /*setuid(0);
    setuid(0);
    setgid(0);
    setgid(0);
    if(getuid() == 0) {
        NSLog(@"uid 0!");
    } else {
        if (fopen("/usr/lib/libjailbreak.dylib", "r")) {
            NSLog(@"patching setuid via libjailbreak...");
            patch_setuid();
            setuid(0);
            setuid(0);
            if (getuid() != 0) {
                NSLog(@"still not uid 0");
                NSLog(@"uid: %d",getuid());
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Can't get uid 0"]
                                                                message:@"Badger is having troubles getting root. It may not work properly. Reach out for support. (Code 1)"
                                                               delegate:self
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        } else {
            NSLog(@"not uid 0");
            NSLog(@"uid: %d",getuid());
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Can't get uid 0"]
                                                            message:@"Badger is having troubles getting root. It may not work properly. Reach out for support. (Code 0)"
                                                           delegate:self
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    if(getgid() == 0) {
        NSLog(@"gid 0!");
    } else {
        NSLog(@"not gid 0");
        NSLog(@"gid: %d",getgid());
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Can't get gid 0"]
                                                        message:@"Badger is having troubles getting root. It may not work properly. Reach out for support. (Code 2)"
                                                       delegate:self
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        [alert show];
    }*/
    
    //self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:0 green:181 blue:226 alpha:1.0];
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    //if (@available(iOS 13.0, *)) {
    //TODO: Provide an option for iOS 12- users to have dark mode rather than defaulting them to light mode with no option to switch.
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    }
    /*} else {
        // Fallback on earlier versions
        self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
        self.view.backgroundColor = [UIColor whiteColor];
        
    }*/
    //Beware! dumb broken shit for iOS 10- prefersLargeTitles emulation that was buggy so I commented out
    //We don't even need to use iOS 10- at this point in time lolz
    //if (@available(iOS 11.0, *)) {
        self.navigationItem.title = @"Badger";
        //self.navigationController.navigationBar.prefersLargeTitles = YES;
        //[self.navigationItem setLargeTitleDisplayMode:UINavigationItemLargeTitleDisplayModeNever];
        //[self.navigationController.navigationBar.layer setAnchorPoint:CGPointMake(self.navigationController.navigationBar.layer.anchorPoint.x, self.navigationController.navigationBar.layer.anchorPoint.y + 0.22f)]; //+ 0.22f iPod Touch 7
    /*} else {
        // Fallback on earlier versions
        UILabel *newTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
        newTitle.text = @"Badger";
        newTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:25.0f];
        if (@available(iOS 6.0, *)) {
            newTitle.textAlignment = NSTextAlignmentLeft;
        } else {
            newTitle.textAlignment = UITextAlignmentLeft;
        }
        self.navigationItem.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width*3, self.navigationController.navigationBar.frame.size.height)];
        [self.navigationItem.titleView addSubview:newTitle];
        //As much as I wanted to emulate the prefersLargeTitles navbar on iOS 10, it's just way to buggy for me to implement it in the current state :(.
        //[self.navigationController.navigationBar.layer setAnchorPoint:CGPointMake(self.navigationController.navigationBar.layer.anchorPoint.x, self.navigationController.navigationBar.layer.anchorPoint.y - 1.0f)];
    }*/
    //if (@available(iOS 11.0, *)) {
    if (@available(iOS 13.0, *)) {
        self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStyleInsetGrouped];
    } else {
        self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStylePlain];
    } //previously self.view.frame.size.height + 35 iPod Touch 7, y value is 110 on iPod Touch 7 and 130 on iPhone 11 (UIScreen.mainScreen.applicationFrame.size.height/15.2)-(548/15.2)
    /*} else {
        //move tableview below navbar
        self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0+self.navigationController.navigationBar.frame.size.height+25, self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStyleInsetGrouped]; //previously self.view.frame.size.height + 35 iPod Touch 7, y value is 110 on iPod Touch 7 and 130 on iPhone 11 (UIScreen.mainScreen.applicationFrame.size.height/15.2)-(548/15.2)
    }*/
    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
    /*if (@available(iOS 11.0, *)) {
        //[_myTableView setFrame:CGRectMake(10, 0, _myTableView.frame.size.width - 20, _myTableView.frame.size.height)];
    }*/
    //_myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //[_myTableView setShowsVerticalScrollIndicator:NO];
    //[_myTableView setShowsHorizontalScrollIndicator:NO];
    //[_myTableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAutomatic];
    [self.view addSubview:self.myTableView];
    
    //for ios 11+, since navigation bar may be below status bar, creating some funky looks with the table view
    //    UIView *topNotchCover;
    //if (@available(iOS 11.0, *)) {
    topNotchCover = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height)]; //height 96 on 852, 91 on 548
    //
    /*} else {
        //topNotchCover = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.applicationFrame.size.width, 91+(UIScreen.mainScreen.applicationFrame.size.height/60.8)-9.01315789)]; //height 96 on 852, 91 on 548
        //As much as I wanted to emulate the prefersLargeTitles navbar on iOS 10, it's just way to buggy for me to implement it in the current state :(.
        topNotchCover = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.applicationFrame.size.width, self.navigationController.navigationBar.frame.size.height)];
    }*/
    topNotchCover.hidden = NO;
    topNotchCover.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    [self.view addSubview:topNotchCover];
    // make the VC conform to UISearchBarDelegate and update the contents like that
    UISearchController *searchController = [[UISearchController alloc] init];
    searchController.searchBar.delegate = self;
    self.navigationItem.searchController = searchController;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    //[self.view addSubview:self.searchBar];
    //self.view.backgroundColor = [UIColor colorWithRed:173 green:216 blue:230 alpha:1.0];
    // Do any additional setup after loading the view.
    if (@available(iOS 13.0, *)) { } else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    }
}

#if 0
//TODO: Shit method - read the comment above viewDidAppear for more explanation.
- (void)viewWillAppear:(BOOL)animated {
    //if (@available(iOS 13.0, *)) {
    if (@available(iOS 13.0, *)) {
        self.navigationController.navigationBar.backgroundColor = [UIColor systemBackgroundColor];
        self.view.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    };
    /*} else {
        // Fallback on earlier versions
        self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
        self.view.backgroundColor = [UIColor whiteColor];
        
    }*/
}
#endif

//TODO: Hacky workaround for the infamous navbar bug. It's hacky but I have had no idea how to fix this since 1.0 and I'm so happy to finally find a workaround in 1.2.2 even if it's not how to properly fix.
- (void)viewWillAppear:(BOOL)animated {
    if (self.navigationController.navigationBar.frame.size.height == self.navigationItem.searchController.searchBar.frame.origin.y) {
        [topNotchCover setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height + self.navigationItem.searchController.searchBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y)];
    } else if (self.navigationController.navigationBar.frame.size.height > 0) {
            [topNotchCover setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y)];
    }
        //NSLog(@"navBar y: %f",self.navigationController.navigationBar.frame.origin.y);
        //NSLog(@"searchBar y: %f",self.navigationItem.searchController.searchBar.frame.origin.y);
        //NSLog(@"navbar height: %f",self.navigationController.navigationBar.frame.size.height);
        //NSLog(@"searchBar height: %f",self.navigationItem.searchController.searchBar.frame.size.height);
    //}
    //NSLog(@"navbar: %f",self.navigationController.navigationBar.frame.origin.y);
    //NSLog(@"navbar: %f",self.navigationItem.searchController.searchBar.frame.origin.y);
    //NSLog(@"navbar: %f",self.navigationController.navigationBar.frame.size.height);
    //on create: 20 0 143
}

//TODO: On iOS 12+ this is fine, but on iOS 13+ we change the color of the one navigation bars (different view controllers don't have different navbar bgs, they should) so it looks a little weird when moving. I thought, ok, small issue, but you only really notice it if you look close, so I'll fix this later but no need to fix it for now, but the swipe gesture makes this issue much more noticable to a terrible degree so now I actually need to fucking fix it in Badger 1.3 or Badger 1.2.2.
- (void)viewDidAppear:(BOOL)animated {
    if (@available(iOS 13.0, *)) {
        self.navigationController.navigationBar.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    }
    /*if (@available(iOS 13.0, *)) {
        self.navigationController.navigationBar.backgroundColor = [UIColor systemBackgroundColor];
        self.view.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        // Fallback on earlier versions
        self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
        self.view.backgroundColor = [UIColor whiteColor];
        
    }*/
    /*UISearchController *searchController = [[UISearchController alloc] init];
    searchController.searchBar.delegate = self;
    self.navigationItem.searchController = searchController;
    self.navigationController.navigationBar.userInteractionEnabled = YES;*/
    [self.navigationItem.searchController.searchBar setPlaceholder:trans(@"Enter a setting...")];
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    /*if (@available(iOS 11.0, *)) {
        _myTableView.contentInset = UIEdgeInsetsMake(1, 0, 0, 0);
    }*/
    if (self.navigationController.navigationBar.frame.size.height == self.navigationItem.searchController.searchBar.frame.origin.y) {
        [topNotchCover setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height + self.navigationItem.searchController.searchBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y)];
    } else if (self.navigationController.navigationBar.frame.size.height > 0) {
        [topNotchCover setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y)];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    /*if (@available(iOS 11.0, *)) {
        //return ROWS+1;
        return ROWS;
    } else {
        return ROWS;
    }*/
    return [filteredCells count];
}

-(BadgerTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BadgerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[BadgerTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    /*int colorId = indexPath.row % 6;
    CGFloat red, green, blue, alpha;
    UIColor* cellColor;
    switch(colorId) {
        case 0:
            cellColor = [UIColor redColor];
            break;
        case 1:
            cellColor = [UIColor orangeColor];
            break;
        case 2:
            cellColor = [UIColor yellowColor];
            break;
        case 3:
            cellColor = [UIColor greenColor];
            break;
        case 4:
            cellColor = [UIColor blueColor];
            break;
        case 5:
            cellColor = [UIColor purpleColor];
            break;
        default:
            NSLog(@"Badger Error: No color set for cell colorId %d\n",colorId);
            cellColor = cell.backgroundColor;
            break;
    }
    [cellColor getRed:&red green: &green blue: &blue alpha: &alpha]; //iOS 5.0+
    cell.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.5];*/
#if TRANS
    cell.backgroundColor = basedCellColorFromRow(indexPath.row);
#endif
    //cell.layer.borderColor = basedCellColorFromRow(indexPath.row).CGColor;
    //cell.layer.borderWidth = 2;
    cell.textLabel.text = cellTitleFromRow(indexPath.row);
    cell.imageView.image = cellImageFromTitle(cellTitleFromRow(indexPath.row));
    [cell.textLabel setAdjustsFontSizeToFitWidth:1];
    //If we got a row that for whatever fucking reason appears even if we already have all the rows we need, hide it. Actually the better solution is to just probably return nil or something because this might look the scrolling look weird but whatever, this was really only needed back in the September builds.
    if (indexPath.row > (ROWS-1)) {
        [cell setHidden:1];
    }
    /*if (@available(iOS 11.0, *)) {
        if (indexPath.row == 0) {
            cell.layer.cornerRadius = 15.0;
            [cell.layer setMaskedCorners:kCALayerMaxXMinYCorner|kCALayerMinXMinYCorner];
        } else if (indexPath.row == ROWS-1) {
            cell.layer.cornerRadius = 15.0;
            [cell.layer setMaskedCorners:kCALayerMinXMaxYCorner|kCALayerMaxXMaxYCorner];
        } else {
            cell.layer.cornerRadius = 0.0;
            [cell.layer setMaskedCorners:0];
        }
    }*/
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell.imageView.layer setMasksToBounds:YES];
    [cell.imageView.layer setCornerRadius:8.0];
    [cell.imageView setClipsToBounds:YES];
    return cell;
}
//TODO: Ugly method, improve later in Badger 1.3 when we switch to no storyboards (i suck at them)
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellTitle = cellTitleFromRow(indexPath.row);
    Class cellInfo = NSClassFromString(@"cellInfo");
    id cellInfoInstance = [cellInfo sharedInstance];
    [cellInfoInstance addObserver:self];
    if (cellInfoInstance) {
        [cellInfoInstance setCellTitle:cellTitle];
    }
    if ([cellTitle isEqualToString:trans(@"Badge Count Minimum")]) {
        NSLog(@"Badge Count Minimum Pressed!");
        
        /*Class cellInfo = NSClassFromString(@"cellInfo");
        id cellInfoInstance = [cellInfo sharedInstance];
        //[cellInfoInstance addObserver:self];
        if (cellInfoInstance) {
            [cellInfoInstance setCellTitle:@"Badge Count Minimum"];
        }*/
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeCountMinimumViewController *myNewVC = (BadgeCountMinimumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeCountMinimumViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Count Minimum for App")]) {
        NSLog(@"Badge Count Minimum for App Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Count Limit")]) {
        NSLog(@"Badge Count Limit Pressed!");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeCountMinimumViewController *myNewVC = (BadgeCountMinimumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeCountMinimumViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Count Limit for App")]) {
        NSLog(@"Badge Count Limit for App Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Color")]) {
        NSLog(@"Badge Color Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Opacity")]) {
        NSLog(@"Badge Opacity Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Position")]) {
        NSLog(@"Badge Position Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeColorViewController *myNewVC = (BadgeColorViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeColorViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Shape")]) {
        NSLog(@"Badge Shape Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Image")]) {
        NSLog(@"Badge Image Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Custom Badge Label")]) {
        NSLog(@"Custom Badge Label Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Color for App")]) {
        NSLog(@"Badge Color for App Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Opacity for App")]) {
        NSLog(@"Badge Opacity for App Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Shape for App")]) {
        NSLog(@"Badge Shape for App Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Badge Size")]) {
        NSLog(@"Badge Size Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([cellTitle isEqualToString:trans(@"Badge Size for App")]) {
        NSLog(@"Badge Size for App Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([cellTitle isEqualToString:trans(@"Badge Label Color")]) {
        NSLog(@"Badge Label Color Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([cellTitle isEqualToString:trans(@"Badge Label Color for App")]) {
        NSLog(@"Badge Label Color for App Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([cellTitle isEqualToString:trans(@"Badge Image for App")]) {
        NSLog(@"Badge Image for App Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([cellTitle isEqualToString:trans(@"Badge Position for App")]) {
        NSLog(@"Badge Position for App Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerAppSelectionViewController *myNewVC = (BadgerAppSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerAppSelectionViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([cellTitle isEqualToString:trans(@"Badge Font")]) {
        NSLog(@"Badge Font Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.cellTitle = cellTitle;
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Apply Settings")]) {
        NSLog(@"Apply Settings Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerApplySettingsViewController *myNewVC = (BadgerApplySettingsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerApplySettingsViewController"];
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    } else if ([cellTitle isEqualToString:trans(@"Credits")]) {
        NSLog(@"Credits Pressed!");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCreditsViewController *myNewVC = (BadgerCreditsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCreditsViewController"];
        [self.navigationController pushViewController:myNewVC animated:YES];
         
    }
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    //[cell setBackgroundColor:cellColorFromRow(indexPath.row)];
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
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    filteredCells = [cellTitles mutableCopy];
    [_myTableView reloadData];
}
@end
NSString *cellTitleFromRow(long row) {
    //yes this function is used
    /*switch(row) {
        case 0:
            return @"Badge Count Minimum";
        case 1:
            return @"Badge Count Minimum for App";
        case 2:
            return @"Badge Count Limit";
        case 3:
            return @"Badge Count Limit for App";
        case 4:
            return @"Badge Color";
        case 5:
            return @"Badge Color for App";
        case 6:
            return @"Badge Opacity";
        case 7:
            return @"Badge Opacity for App";
        case 8:
            return @"Badge Position";
        case 9:
            return @"Badge Shape";
        case 10:
            return @"Badge Shape for App";
        case 11:
            return @"Badge Image";
        case 12:
            return @"Badge Image for App";
        case 13:
            return @"Custom Badge Label";
        case 14:
            return @"Badge Size";
        case 15:
            return @"Badge Size for App";
        case 16:
            return @"Badge Label Color";
        case 17:
            return @"Badge Label Color for App";
        case 18:
            return @"App Theme";
        default:
            NSLog(@"Badger Error: No Title Listed for Row %ld\n",row);
            return @"No Title Listed for Row";
    }*/
    return [cellTitles objectAtIndex:row];
}

UIImage *cellImageFromRow(long row) { //UNUSED: cellImageFromTitle is now used instead
    switch(row) {
        case 0:
            return [UIImage imageNamed:@"MinimumBadge.png"];
        case 1:
            return [UIImage imageNamed:@"MinimumBadge.png"];
        case 2:
            return [UIImage imageNamed:@"MaxBadge.png"];
        case 3:
            return [UIImage imageNamed:@"MaxBadge.png"];
        case 4:
            return [UIImage imageNamed:@"ColorBadge.png"];
        case 5:
            return [UIImage imageNamed:@"ColorBadge.png"];
        case 6:
            return [UIImage imageNamed:@"BadgeOpacity.png"];
        case 7:
            return [UIImage imageNamed:@"BadgeOpacity.png"];
        case 8:
            return [UIImage imageNamed:@"BadgePos.png"];
        case 9:
            return [UIImage imageNamed:@"BadgeShape.png"];
        case 10:
            return [UIImage imageNamed:@"BadgeShape.png"];
        case 11:
            return [UIImage imageNamed:@"ImageBadge.png"];
        case 12:
            return [UIImage imageNamed:@"ImageBadge.png"];
        case 13:
            return [UIImage imageNamed:@"CustomLabelBadge.png"];
        case 14:
            return [UIImage imageNamed:@"BadgeSize.png"];
        case 15:
            return [UIImage imageNamed:@"BadgeSize.png"];
        case 16:
            return [UIImage imageNamed:@"BadgeLabelColor.png"];
        case 17:
            return [UIImage imageNamed:@"BadgeLabelColor.png"];
        default:
            NSLog(@"Badger Error: No Image Listed for Row %ld\n",row);
            return [UIImage imageNamed:@"BadgerIcon.png"];
    }
}

NSArray *dylibPossiblePaths(void){ //UNUSED: This function goes unused
    return [[NSArray alloc]initWithObjects:@"/usr/lib/TweakInject/Badger.dylib",@"/var/jb/usr/lib/TweakInject/Badger.dylib", nil];
}

UIColor *cellColorFromRow(long row) { //UNUSED: back in the old badger ui days this was used but with redesigned badger ui this is no longer used
    int colorId = row % 6;
    CGFloat red, green, blue, alpha;
    UIColor* cellColor;
    switch(colorId) {
        case 0:
            cellColor = [UIColor colorWithRed:204/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];//[UIColor redColor];
            break;
        case 1:
            cellColor = [UIColor colorWithRed:230/255.0 green:121/255.0 blue:25/255.0 alpha:1.0];//[UIColor orangeColor];
            break;
        case 2:
            cellColor = [UIColor colorWithRed:(204/255.0) green:(204/255.0) blue:(0/255.0) alpha:1.0];//[UIColor yellowColor];
            break;
        case 3:
            cellColor = [UIColor colorWithRed:0.0980392156863 green:0.901960784314 blue:0.0980392156863 alpha:1.0];//[UIColor greenColor];
            break;
        case 4:
            cellColor = [UIColor colorWithRed:25/255.0 green:25/255.0 blue:230/255.0 alpha:1.0];//[UIColor blueColor]; 25 25 230
            break;
        case 5:
            cellColor = [UIColor colorWithRed:230/255.0 green:25/255.0 blue:230/255.0 alpha:1.0];//[UIColor purpleColor];
            break;
        default:
            NSLog(@"Badger Error: No color set for cell colorId %d\n",colorId);
            return [UIColor whiteColor];
    }
    [cellColor getRed:&red green: &green blue: &blue alpha: &alpha]; //iOS 5.0+
    return [UIColor colorWithRed:red green:green blue:blue alpha:0.5];
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

UIColor *frenchCellColorFromRow(long row) { //UNUSED: i was thinking of doing a cool thing where translators have special colors in home screen but thought it looked bad so translators just get normal builds and this function goes unused
    int colorId = row % 3;
    CGFloat red, green, blue, alpha;
    UIColor* cellColor;
    switch(colorId) {
        case 0:
            cellColor = colorFromHexString(@"002654");
            break;
        case 1:
            cellColor = colorFromHexString(@"FFFFFF");
            break;
        case 2:
            cellColor = colorFromHexString(@"ED2939");
            break;
        default:
            NSLog(@"Badger Error: No color set for cell colorId %d\n",colorId);
            return [UIColor whiteColor];
    }
    [cellColor getRed:&red green: &green blue: &blue alpha: &alpha]; //iOS 5.0+
    return [UIColor colorWithRed:red green:green blue:blue alpha:0.8];
}

//
//  BadgerAppSelectionViewController.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/6/22.
//

#import "ViewController.h"
#import "BadgerAppSelectionViewController.h"
#import "BadgeCountMinimumViewController.h"
#import "BadgeColorViewController.h"
#import "BadgerCountConfigManagerViewController.h"
#import "BadgerCustomImageViewController.h"
#import "BadgerEasyTranslations.h"

NSMutableArray *appImages;
NSMutableArray *appNames;
NSMutableArray *appBundleIDs;
NSMutableArray *filteredAppImages;
NSMutableArray *filteredAppNames;
NSMutableArray *filteredAppBundleIDs;
UIView *topNotchCoverAppSelection;

@interface UIImage (UIApplicationIconPrivate)
+ (instancetype)_applicationIconImageForBundleIdentifier:(NSString*)bundleIdentifier format:(int)format scale:(CGFloat)scale;
@end

@interface LSApplicationState : NSObject
-(bool)isValid;
@end

@interface LSApplicationRecord : NSObject
@property (nonatomic,readonly) NSArray* appTags; // 'hidden'
@property (getter=isLaunchProhibited,readonly) BOOL launchProhibited;
@end

@interface LSApplicationProxy : NSObject
+ (LSApplicationProxy *)applicationProxyForIdentifier:(id)appIdentifier;
@property(readonly) NSString * applicationIdentifier;
@property(readonly) NSString * bundleVersion;
@property(readonly) NSString * bundleExecutable;
@property(readonly) NSArray * deviceFamily;
@property(readonly) NSURL * bundleContainerURL;
@property(readonly) NSString * bundleIdentifier;
@property(readonly) NSURL * bundleURL;
@property(readonly) NSURL * containerURL;
@property(readonly) NSURL * dataContainerURL;
@property(readonly) NSString * localizedShortName;
@property(readonly) NSString * localizedName;
@property(readonly) NSString * shortVersionString;
@property (readonly) BOOL isStickerProvider;
@property(nonatomic, readonly) NSArray *appTags; //thx KBAppList
@property(readonly, nonatomic) NSString *applicationType;
@property(nonatomic, readonly) NSDictionary *iconsDictionary;
@property (getter=isLaunchProhibited,nonatomic,readonly) BOOL launchProhibited;
- (NSArray *)_boundIconFileNames; // iOS 11+
- (NSArray *)boundIconFileNames;  // iOS 10-
- (void)addObserver:(id)arg1;
-(LSApplicationState*)appState;
- (LSApplicationRecord*)correspondingApplicationRecord;
@end

@interface LSApplicationWorkspace : NSObject
+ (id) defaultWorkspace;
- (BOOL) registerApplication:(id)application;
- (BOOL) unregisterApplication:(id)application;
- (BOOL) invalidateIconCache:(id)bundle;
- (BOOL) registerApplicationDictionary:(id)application;
- (BOOL) installApplication:(id)application withOptions:(id)options;
- (BOOL) _LSPrivateRebuildApplicationDatabasesForSystemApps:(BOOL)system internal:(BOOL)internal user:(BOOL)user;
-(NSArray <LSApplicationProxy*> *)allApplications;
-(NSArray <LSApplicationProxy*> *)allInstalledApplications;
@end

@interface BadgerAppCell : NSObject {
    NSString* appName;
    id appImage;
    NSString* appBundleID;
}
@end

@implementation BadgerAppCell
-(NSString *) appName {
    return appName;
}
-(id) appImage {
    return appImage;
}
-(NSString *) appBundleID {
    return appBundleID;
}
-(void) setAppName: (NSString *) a{
    appName=a;
}
-(void) setAppImage: (id) a{
    appImage=a;
}
-(void) setAppBundleID: (NSString *) w{
    appBundleID=w;
}
@end

@interface BadgerAppSelectionViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate>

@end

UITableView *myTableView;

@implementation BadgerAppSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = trans(@"Apps");
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    appImages = [[NSMutableArray alloc]init];
    appNames = [[NSMutableArray alloc]init];
    appBundleIDs = [[NSMutableArray alloc]init];
    Class LSApplicationWorkspace = NSClassFromString(@"LSApplicationWorkspace");
    id AAURLConfiguration1 = [LSApplicationWorkspace defaultWorkspace];
    [AAURLConfiguration1 addObserver:self];
    NSMutableArray <BadgerAppCell*> *badgerApps;
    badgerApps = [[NSMutableArray alloc]init];
    if (AAURLConfiguration1) {
        id arrApp = [AAURLConfiguration1 allInstalledApplications];
        //sort all apps alphabetically
        for (int i=0; i<[arrApp count]; i++) {
            LSApplicationProxy *app = [arrApp objectAtIndex:i];
            NSArray* appTags;
            BOOL launchProhibited = NO;
            if([app respondsToSelector:@selector(correspondingApplicationRecord)]) {
                // On iOS 14, self.appTags is always empty but the application record still has the correct ones
                LSApplicationRecord* record = [app correspondingApplicationRecord];
                appTags = record.appTags;
                launchProhibited = record.launchProhibited;
            } else {
                appTags = app.appTags;
                launchProhibited = app.launchProhibited;
            }
            NSString *applicationIdentifier = [app applicationIdentifier];
            if ((![appTags containsObject:@"hidden"]) && (!launchProhibited) && ![applicationIdentifier isEqualToString:@"com.apple.webapp"]) {
                BadgerAppCell *badgerApp = [[BadgerAppCell alloc]init];
                [badgerApp setAppBundleID:applicationIdentifier];
                UIImage *appIcon = [UIImage _applicationIconImageForBundleIdentifier:applicationIdentifier format:1 scale:[UIScreen mainScreen].scale];
                /* yes i know these are the exact same */
                /* for some reason if i do it the normal way it fucks up optimizations */
                /* so this results in faster code when compiling... */
                /*if (appIcon) {
                    [badgerApp setAppImage:appIcon];
                } else {
                    [badgerApp setAppImage:appIcon];
                }*/
                [badgerApp setAppImage:appIcon];
                NSString *localizedName = [app localizedName];
                if (!localizedName || [@"" isEqualToString:localizedName]){
                    NSURL *infoPlistURL = [[app bundleURL] URLByAppendingPathComponent:@"Info.plist"];
                    NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfURL:infoPlistURL];
                    localizedName = infoPlist[@"CFBundleDisplayName"];
                    if (!localizedName) {
                        localizedName = infoPlist[@"CFBundleName"];
                        if (!localizedName) {
                            localizedName = app.localizedName;
                        }
                    }
                }
                [badgerApp setAppName:localizedName];
                [badgerApps addObject:badgerApp];
            }
        }
    }
    //sort all apps alphabetically
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"appName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    badgerApps = [[badgerApps sortedArrayUsingDescriptors:@[sort]]mutableCopy];
    for (BadgerAppCell *aBadgerApp in badgerApps) {
        [appNames addObject:[aBadgerApp appName]];
        [appImages addObject:[aBadgerApp appImage]];
        [appBundleIDs addObject:[aBadgerApp appBundleID]];
    }
    filteredAppImages = appImages;
    filteredAppNames = appNames;
    filteredAppBundleIDs = appBundleIDs;
    UITableViewStyle tableViewStyle;
    if (@available(iOS 13.0, *)) {
        tableViewStyle = UITableViewStyleInsetGrouped;
    } else {
        tableViewStyle = UITableViewStylePlain;
    }
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height) style:tableViewStyle];
    myTableView.dataSource = self;
    myTableView.delegate = self;
    [self.view addSubview:myTableView];
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor systemBackgroundColor];
        self.navigationController.navigationBar.tintColor = [UIColor labelColor];
    } else {
        // Fallback on earlier versions
        UIColor *whiteColor = [UIColor whiteColor];
        self.view.backgroundColor = whiteColor;
        self.navigationController.navigationBar.backgroundColor = whiteColor;
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    }
    topNotchCoverAppSelection = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height / 1.5)]; //height 96 on 852, 91 on 548
    topNotchCoverAppSelection.hidden = NO;
    topNotchCoverAppSelection.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    [self.view addSubview:topNotchCoverAppSelection];
    //self.view.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    UISearchController *searchController = [[UISearchController alloc] init];
    searchController.searchBar.delegate = self;
    self.navigationItem.searchController = searchController;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    [self.navigationItem.searchController.searchBar setPlaceholder:trans(@"Search for an app...")];
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    //[self updateTopNotchCoverSize];
    updateTopNotchCoverSize(topNotchCoverAppSelection, self);
}
- (void)viewDidAppear:(BOOL)animated {
    if (@available(iOS 13.0, *)) {
        self.navigationController.navigationBar.backgroundColor = [UIColor systemBackgroundColor];
        self.navigationController.navigationBar.tintColor = [UIColor labelColor];
    } else {
        self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    }
    //self.navigationItem.hidesSearchBarWhenScrolling = NO;
    if (self.navigationController.navigationBar.frame.size.height == self.navigationItem.searchController.searchBar.frame.origin.y) {
        [topNotchCoverAppSelection setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height + self.navigationItem.searchController.searchBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y)];
    } else if (self.navigationController.navigationBar.frame.size.height > 0) {
            [topNotchCoverAppSelection setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y)];
    }
    [topTopNotchCoverView setHidden:NO];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [filteredAppNames count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    //REMEMBER! MAKE SURE YOU UPDATE VIEWCONTROLLER FOR INSTALLED USER APPS THAT DON'T HAVE ICONS!!!
    cell.textLabel.text = [filteredAppNames objectAtIndex:indexPath.row];
    id appImage = [filteredAppImages objectAtIndex:indexPath.row];
    if (appImage) {
        cell.imageView.image = appImage;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BadgerViewController *myNewVC;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if ([daCellTitle isEqualToString:trans(@"Badge Shape for App")] || [daCellTitle isEqualToString:trans(@"Badge Color for App")]) {
        myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
    } else if ([daCellTitle isEqualToString:trans(@"Badge Size for App")] || [daCellTitle isEqualToString:trans(@"Badge Label Color for App")] || [daCellTitle isEqualToString:trans(@"Badge Position for App")]) {
        myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
    } else if ([daCellTitle isEqualToString:trans(@"Badge Image for App")]) {
        myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
    } else if ([daCellTitle isEqualToString:trans(@"Badge Opacity for App")]) {
        myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
    } else {
        [topTopNotchCoverView setHidden:YES];
        myNewVC = (BadgeCountMinimumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeCountMinimumViewController"];
    }
    myNewVC.appName = [filteredAppNames objectAtIndex:indexPath.row];
    myNewVC.appBundleID = [filteredAppBundleIDs objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:myNewVC animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        filteredAppNames = appNames;
        filteredAppBundleIDs = appBundleIDs;
        filteredAppImages = appImages;
    } else {
        short index = 0;
        filteredAppNames = [[NSMutableArray alloc]init];
        filteredAppBundleIDs = [[NSMutableArray alloc]init];
        filteredAppImages = [[NSMutableArray alloc]init];
        for (NSString* aAppName in appNames) {
            if ([[aAppName lowercaseString]containsString:[searchText lowercaseString]]) {
                [filteredAppNames addObject:aAppName];
                [filteredAppBundleIDs addObject:[appBundleIDs objectAtIndex:index]];
                [filteredAppImages addObject:[appImages objectAtIndex:index]];
            }
            index++;
        }
    }
    [myTableView reloadData];
    //[self updateTopNotchCoverSize];
    updateTopNotchCoverSize(topNotchCoverAppSelection, self);
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    filteredAppNames = appNames;
    filteredAppBundleIDs = appBundleIDs;
    filteredAppImages = appImages;
    [myTableView reloadData];
    //[self updateTopNotchCoverSize];
    updateTopNotchCoverSize(topNotchCoverAppSelection, self);
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if (self.navigationItem.searchController.searchBar.frame.origin.y > 0) {
        //[topNotchCoverAppSelection setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationItem.searchController.searchBar.frame.origin.y)];
        [topNotchCoverAppSelection setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.origin.y)];
    }
}

/*-(void)updateTopNotchCoverSize {
    if (self.navigationController.navigationBar.frame.size.height == self.navigationItem.searchController.searchBar.frame.origin.y) {
        [topNotchCoverAppSelection setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height + self.navigationItem.searchController.searchBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y)];
    } else if (self.navigationItem.searchController.searchBar.frame.origin.y != 0) {
        [topNotchCoverAppSelection setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationItem.searchController.searchBar.frame.size.height + self.navigationItem.searchController.searchBar.frame.origin.y + self.navigationController.navigationBar.frame.origin.y)];
    } else if (self.navigationController.navigationBar.frame.size.height > 0) {
        [topNotchCoverAppSelection setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.origin.y + self.navigationItem.searchController.searchBar.frame.size.height)];
    }
}*/

@end

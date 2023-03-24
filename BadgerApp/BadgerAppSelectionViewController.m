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
//#import <MobileCoreServices/LSApplicationProxy.h>
//#import <MobileCoreServices/LSApplicationWorkspace.h>

NSMutableArray *appImages;
NSMutableArray *appNames;
NSMutableArray *appBundleIDs;
NSMutableArray *filteredAppImages;
NSMutableArray *filteredAppNames;
NSMutableArray *filteredAppBundleIDs;

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

/*@interface BadgerApplicationProxy : LSApplicationProxy
- (NSString*)applicationNameForSort;
@end

@implementation BadgerApplicationProxy : LSApplicationProxy
- (NSString*)applicationNameForSort {
    NSString *localName = [self valueForKey:@"_localizedName"];
    if (localName) {
        if (![localName isEqualToString:@""]) {
            return localName;
        }
    }
    NSURL* bundleURL = self.bundleURL;
    if ([bundleURL checkResourceIsReachableAndReturnError:nil]) {
        NSBundle* bundle = [NSBundle bundleWithURL:bundleURL];
        localName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        if (localName) {
            if (![localName isEqualToString:@""]) {
                return localName;
            }
        }
        localName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        if (localName) {
            if (![localName isEqualToString:@""]) {
                return localName;
            }
        }
        return self.localizedName;
    } else {
        return self.localizedName;
    }
}
@end*/

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
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@end

@implementation BadgerAppSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = trans(@"Apps");
    
    appImages = [[NSMutableArray alloc]init];
    appNames = [[NSMutableArray alloc]init];
    appBundleIDs = [[NSMutableArray alloc]init];
    //Class LSApplicationWorkspace = NSClassFromString(@"LSApplicationWorkspace");
    Class LSApplicationWorkspace = NSClassFromString(@"LSApplicationWorkspace");
    id AAURLConfiguration1 = [LSApplicationWorkspace defaultWorkspace];
    [AAURLConfiguration1 addObserver:self];
    NSMutableArray <BadgerAppCell*> *badgerApps;
    badgerApps = [[NSMutableArray alloc]init];
    if (AAURLConfiguration1) {
        id arrApp = [AAURLConfiguration1 allInstalledApplications];
        //sort all apps alphabetically
        //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"localizedName" ascending:YES];
        //arrApp = [arrApp sortedArrayUsingDescriptors:@[sort]];
        for (int i=0; i<[arrApp count]; i++) {
            LSApplicationProxy *app = [arrApp objectAtIndex:i];
            NSArray* appTags;
            BOOL launchProhibited = NO;
            if([app respondsToSelector:@selector(correspondingApplicationRecord)])
                {
                    // On iOS 14, self.appTags is always empty but the application record still has the correct ones
                    LSApplicationRecord* record = [app correspondingApplicationRecord];
                    appTags = record.appTags;
                    launchProhibited = record.launchProhibited;
                } else {
                    appTags = app.appTags;
                    launchProhibited = app.launchProhibited;
                }
            if ((![appTags containsObject:@"hidden"]) && (!launchProhibited) && ![[app applicationIdentifier] isEqualToString:@"com.apple.webapp"]) {
                
                //NSLog(@"appTags: %@",app.appTags);
                //NSString* bundleId =[app applicationIdentifier];
                //NSLog(@"app: %@",bundleId);
                //NSLog(@"apploc: %s",[[app bundleURL] fileSystemRepresentation]);
                //NSLog(@"app name: %@",[app localizedName]);
                //get CFBundleIcons (or CFBundleIcons~ipad) from info.plist in [[app bundleURL] fileSystemRepresentation]. CFBundleIconName has CFBundlePrimaryIcon which has CFBundleIconFiles, though it may also have CFBundleIconName
                //NSMutableDictionary *infoPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%s/Info.plist",[[app bundleURL] fileSystemRepresentation]]];
                BadgerAppCell *badgerApp = [[BadgerAppCell alloc]init];
                UIImage *appIcon = [UIImage _applicationIconImageForBundleIdentifier:[app applicationIdentifier] format:1 scale:[UIScreen mainScreen].scale];
                if (appIcon) {
                    [badgerApp setAppImage:appIcon];//[appImages addObject:appIcon];
                } else {
                    [badgerApp setAppImage:@"NOIMG"];//[appImages addObject:@"NOIMG"];
                }
                if ([app localizedName]){
                    if (![[app localizedName]isEqualToString:@""]) {
                        [badgerApp setAppName:[app localizedName]];
                    } else {
                        NSMutableDictionary *infoPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%s/Info.plist",[[app bundleURL] fileSystemRepresentation]]];
                        if ([infoPlist objectForKey:@"CFBundleDisplayName"]) {
                            [badgerApp setAppName:[infoPlist objectForKey:@"CFBundleDisplayName"]];
                        } else if ([infoPlist objectForKey:@"CFBundleName"]) {
                            [badgerApp setAppName:[infoPlist objectForKey:@"CFBundleName"]];
                        } else {
                            [badgerApp setAppName:app.localizedName];
                        }
                    }
                } else {
                    NSMutableDictionary *infoPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%s/Info.plist",[[app bundleURL] fileSystemRepresentation]]];
                    if ([infoPlist objectForKey:@"CFBundleDisplayName"]) {
                        [badgerApp setAppName:[infoPlist objectForKey:@"CFBundleDisplayName"]];
                    } else if ([infoPlist objectForKey:@"CFBundleName"]) {
                        [badgerApp setAppName:[infoPlist objectForKey:@"CFBundleName"]];
                    } else {
                        [badgerApp setAppName:app.localizedName];
                    }
                }
                [badgerApp setAppBundleID:[app applicationIdentifier]];
                [badgerApps addObject:badgerApp];
                //[appNames addObject:[app localizedName]];
               // [appBundleIDs addObject:[app applicationIdentifier]];
                //[infoPlist setObject:@"788" forKey:@"CFBundleVersion"];
                //[infoPlist writeToFile:[NSString stringWithFormat:@"%s/Info.plist",[[app bundleURL] fileSystemRepresentation]] atomically:YES];
                /*if ([infoPlist objectForKey:@"CFBundleIcons"]) {
                    if ([[infoPlist objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"]) {
                        if ([[[infoPlist objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"]) {
                                if ([[[[infoPlist objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"]objectAtIndex:0]) {
                                    
                                    
                                        if ([UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%s/%@.png",[[app bundleURL] fileSystemRepresentation],[[[[infoPlist objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"]objectAtIndex:0]]]) {
                                    [appImages addObject:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%s/%@.png",[[app bundleURL] fileSystemRepresentation],[[[[infoPlist objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"]objectAtIndex:0]]]];
                                            [appNames addObject:[app localizedName]];
                                            [appBundleIDs addObject:[app applicationIdentifier]];
                                        } else if ([UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%s/%@@2x.png",[[app bundleURL] fileSystemRepresentation],[[[[infoPlist objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"]objectAtIndex:0]]]) {
                                [appImages addObject:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%s/%@@2x.png",[[app bundleURL] fileSystemRepresentation],[[[[infoPlist objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"]objectAtIndex:0]]]];
                                        [appNames addObject:[app localizedName]];
                                        [appBundleIDs addObject:[app applicationIdentifier]];
                                    } else if ([UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%s/%@@3x.png",[[app bundleURL] fileSystemRepresentation],[[[[infoPlist objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"]objectAtIndex:0]]]) {
                                [appImages addObject:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%s/%@@3x.png",[[app bundleURL] fileSystemRepresentation],[[[[infoPlist objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"]objectAtIndex:0]]]];
                                        [appNames addObject:[app localizedName]];
                                        [appBundleIDs addObject:[app applicationIdentifier]];
                                    } else {
                                        [appImages addObject:@"NOIMG"];
                                        [appNames addObject:[app localizedName]];
                                        [appBundleIDs addObject:[app applicationIdentifier]];
                                    }
                                } else {
                                    [appImages addObject:@"NOIMG"];
                                    [appNames addObject:[app localizedName]];
                                    [appBundleIDs addObject:[app applicationIdentifier]];
                                }
                        } else {
                            [appImages addObject:@"NOIMG"];
                            [appNames addObject:[app localizedName]];
                            [appBundleIDs addObject:[app applicationIdentifier]];;
                        }
                    } else {
                        [appImages addObject:@"NOIMG"];
                        [appNames addObject:[app localizedName]];
                        [appBundleIDs addObject:[app applicationIdentifier]];
                    }
                } else {
                    if ([infoPlist objectForKey:@"CFBundleIconFiles"]) {
                        [appImages addObject:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%s/%@.png",[[app bundleURL] fileSystemRepresentation],[[infoPlist objectForKey:@"CFBundleIconFiles"]objectAtIndex:0]]]];
                    } else {
                        [appImages addObject:@"NOIMG"];
                    }
                    [appNames addObject:[app localizedName]];
                    [appBundleIDs addObject:[app applicationIdentifier]];
                }*/
                //infoPlist = nil;
            }
            
        }
    } else {
        NSLog(@"NOPE");
    }
    //sort all apps alphabetically
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"appName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    badgerApps = [[badgerApps sortedArrayUsingDescriptors:@[sort]]mutableCopy];
    NSLog(@"BadgerApps: %@",badgerApps);
    NSLog(@"BadgerApps LastObj appName: %@",[[badgerApps lastObject]appName]);
    NSLog(@"BadgerApps LastObj appBundleID: %@",[[badgerApps lastObject]appBundleID]);
    for (BadgerAppCell *aBadgerApp in badgerApps) {
        [appNames addObject:[aBadgerApp appName]];
        [appImages addObject:[aBadgerApp appImage]];
        [appBundleIDs addObject:[aBadgerApp appBundleID]];
    }
    filteredAppImages = appImages;
    filteredAppNames = appNames;
    filteredAppBundleIDs = appBundleIDs;
    /*Class appInfo = NSClassFromString(@"appInfo");
    id appInfoInstance = [appInfo sharedInstance];
    [appInfoInstance addObserver:self];
    if (appInfoInstance) {
        [appInfoInstance setAppImages:appImages];
        [appInfoInstance setAppNames:appNames];
    }*/
    //if (@available(iOS 11.0, *)) {
    if (@available(iOS 13.0, *)) {
        self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStyleInsetGrouped]; //previously self.view.frame.size.height + 35 iPod Touch 7, y value is 110 on iPod Touch 7 and 130 on iPhone 11 (UIScreen.mainScreen.applicationFrame.size.height/15.2)-(548/15.2)
    } else {
        self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStylePlain];
    }
    /*} else {
        self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0+self.navigationController.navigationBar.frame.size.height+50, self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStylePlain];
    }*/
    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
    /*if (@available(iOS 11.0, *)) {
        //self.navigationController.navigationBar.prefersLargeTitles = NO;
        [_myTableView setFrame:CGRectMake(10, 0, _myTableView.frame.size.width - 20, _myTableView.frame.size.height)];
    } else {
        [_myTableView setFrame:CGRectMake(0, 0, _myTableView.frame.size.width, _myTableView.frame.size.height)];
    }*/
    //_myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //[_myTableView setShowsVerticalScrollIndicator:NO];
    //[_myTableView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:self.myTableView];
    //self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor systemBackgroundColor];
        self.navigationController.navigationBar.tintColor = [UIColor labelColor];
    } else {
        // Fallback on earlier versions
        self.view.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        
    }
    UIView *topNotchCover;
    topNotchCover = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height / 1.5)]; //height 96 on 852, 91 on 548
    topNotchCover.hidden = NO;
    topNotchCover.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    [self.view addSubview:topNotchCover];
    self.view.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    UISearchController *searchController = [[UISearchController alloc] init];
    searchController.searchBar.delegate = self;
    self.navigationItem.searchController = searchController;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    [self.navigationItem.searchController.searchBar setPlaceholder:trans(@"Search for an app...")];
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    //self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    if (@available(iOS 13.0, *)) {
        self.navigationController.navigationBar.backgroundColor = [UIColor systemBackgroundColor];
        self.view.backgroundColor = [UIColor systemBackgroundColor];
        self.navigationController.navigationBar.tintColor = [UIColor labelColor];
    } else {
        // Fallback on earlier versions
        //self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
        self.view.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        
    }
}
- (void)viewDidAppear:(BOOL)animated {
    if (@available(iOS 13.0, *)) {
        self.navigationController.navigationBar.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    }
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [filteredAppNames count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"appNames count: %lu",(unsigned long)[appNames count]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    //REMEMBER! MAKE SURE YOU UPDATE VIEWCONTROLLER FOR INSTALLED USER APPS THAT DON'T HAVE ICONS!!!
    cell.textLabel.text = [filteredAppNames objectAtIndex:indexPath.row];
    if ([[filteredAppImages objectAtIndex:indexPath.row]isEqual:@"NOIMG"]){}else{
        cell.imageView.image = [filteredAppImages objectAtIndex:indexPath.row];
    }
    //cell.backgroundColor = cellColorFromRow(indexPath.row);
    /*cell.layer.masksToBounds = YES;
    if (@available(iOS 11.0, *)) {
        if (indexPath.row == 0) {
            cell.layer.cornerRadius = 15.0;
            [cell.layer setMaskedCorners:3]; // kCALayerMaxXMinYCorner|kCALayerMinXMinYCorner
        } else if (indexPath.row == [appNames count]-1) {
            cell.layer.cornerRadius = 15.0;
            [cell.layer setMaskedCorners:12]; // kCALayerMinXMaxYCorner|kCALayerMaxXMaxYCorner
        } else {
            cell.layer.cornerRadius = 0.0;
            [cell.layer setMaskedCorners:0];
        }
    }*/
    /*if (@available(iOS 11.0, *)) {
        if (indexPath.row == (long)0) {
            NSLog(@"app at %ld: %@",(long)indexPath.row,[appNames objectAtIndex:indexPath.row]);
            cell.layer.cornerRadius = 15.0;
            [cell.layer setMaskedCorners:kCALayerMaxXMinYCorner|kCALayerMinXMinYCorner];
        } else if (indexPath.row == (long)([appNames count]-1)) {
            NSLog(@"app mat %ld: %@",(long)indexPath.row,[appNames objectAtIndex:indexPath.row]);
            cell.layer.cornerRadius = 15.0;
            [cell.layer setMaskedCorners:kCALayerMinXMaxYCorner|kCALayerMaxXMaxYCorner];
        }
    }*/
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*Class appInfo = NSClassFromString(@"appInfo");
    id appInfoInstance = [appInfo sharedInstance];
    //[appInfoInstance addObserver:self];
    if (appInfoInstance) {
        [appInfoInstance setAppName:[appNames objectAtIndex:indexPath.row]];
    }*/
    if ([[self cellTitle] isEqualToString:trans(@"Badge Shape for App")] || [[self cellTitle] isEqualToString:trans(@"Badge Color for App")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.appName = [filteredAppNames objectAtIndex:indexPath.row];
        myNewVC.cellTitle = [self cellTitle];
        myNewVC.appBundleID = [filteredAppBundleIDs objectAtIndex:indexPath.row];
        NSLog(@"appName: %@",[filteredAppNames objectAtIndex:indexPath.row]);
        NSLog(@"cellTitle: %@",[self cellTitle]);
        NSLog(@"appBundleID: %@",[filteredAppBundleIDs objectAtIndex:indexPath.row]);
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([[self cellTitle] isEqualToString:trans(@"Badge Size for App")] || [[self cellTitle] isEqualToString:trans(@"Badge Label Color for App")] || [[self cellTitle] isEqualToString:trans(@"Badge Position for App")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.appName = [filteredAppNames objectAtIndex:indexPath.row];
        myNewVC.cellTitle = [self cellTitle];
        myNewVC.appBundleID = [filteredAppBundleIDs objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([[self cellTitle] isEqualToString:trans(@"Badge Image for App")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.appName = [filteredAppNames objectAtIndex:indexPath.row];
        myNewVC.cellTitle = [self cellTitle];
        myNewVC.appBundleID = [filteredAppBundleIDs objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([[self cellTitle] isEqualToString:trans(@"Badge Opacity for App")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCountConfigManagerViewController *myNewVC = (BadgerCountConfigManagerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCountConfigManagerViewController"];
        myNewVC.appName = [filteredAppNames objectAtIndex:indexPath.row];
        myNewVC.cellTitle = [self cellTitle];
        myNewVC.appBundleID = [filteredAppBundleIDs objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BadgeCountMinimumViewController *myNewVC = (BadgeCountMinimumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeCountMinimumViewController"];
    myNewVC.appName = [filteredAppNames objectAtIndex:indexPath.row];
    myNewVC.cellTitle = [self cellTitle];
    myNewVC.appBundleID = [filteredAppBundleIDs objectAtIndex:indexPath.row];
    NSLog(@"appName: %@",[filteredAppNames objectAtIndex:indexPath.row]);
    NSLog(@"cellTitle: %@",[self cellTitle]);
    NSLog(@"appBundleID: %@",[filteredAppBundleIDs objectAtIndex:indexPath.row]);
    [self.navigationController pushViewController:myNewVC animated:YES];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    filteredAppNames = [[NSMutableArray alloc]init];
    filteredAppBundleIDs = [[NSMutableArray alloc]init];
    filteredAppImages = [[NSMutableArray alloc]init];
    short index = 0;
    if ([searchText isEqualToString:@""]) {
        filteredAppNames = appNames;
        filteredAppBundleIDs = appBundleIDs;
        filteredAppImages = appImages;
    } else {
        for (NSString* aAppName in appNames) {
            if ([[aAppName lowercaseString]containsString:[searchText lowercaseString]]) {
                [filteredAppNames addObject:aAppName];
                [filteredAppBundleIDs addObject:[appBundleIDs objectAtIndex:index]];
                [filteredAppImages addObject:[appImages objectAtIndex:index]];
            }
            index++;
        }
    }
    [_myTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    filteredAppNames = appNames;
    filteredAppBundleIDs = appBundleIDs;
    filteredAppImages = appImages;
    [_myTableView reloadData];
}

@end

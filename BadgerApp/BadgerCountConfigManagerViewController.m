//
//  BadgerCountConfigManagerViewController.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/12/22.
//

#import "BadgerCountConfigManagerViewController.h"
#include "BadgerPrefHandler.h"
#import "BadgerCountConfigItem.h"
#import "BadgeCountMinimumViewController.h"
#import "BadgerCustomImageViewController.h"
#import "BadgeColorViewController.h"
#import <Foundation/Foundation.h>

//NSArray *configs;
NSMutableArray *configs;
id _param;
UIView *topNotchCoverCount;

@interface BadgerCountConfigManagerViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *configsTableView;
-(void)createCountConfig:(id)sender;
@end

@implementation BadgerCountConfigManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _param = self;
    self.navigationItem.title = trans(@"Configs");
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(createCountConfig:)]];
    configs = [[NSMutableArray alloc]initWithObjects:@"Universal (No Count Minimum)", nil];
    if ([self appBundleID]) {
        if ([[self cellTitle]isEqualToString:trans(@"Badge Image for App")]) {
            [configs addObjectsFromArray:badgerRetriveConfigsWithAppPref([self appBundleID],@"BadgeImagePath")];
        } else if ([[self cellTitle]isEqualToString:trans(@"Custom Badge Label for App")]) {
            [configs addObjectsFromArray:badgerRetriveConfigsWithAppPref([self appBundleID],@"BadgeLabel")];
        } else if ([[self cellTitle]isEqualToString:trans(@"Badge Size for App")]) {
            [configs addObjectsFromArray:badgerRetriveConfigsWithAppPref([self appBundleID],@"BadgeSize")];
        } else if ([[self cellTitle]isEqualToString:trans(@"Badge Label Color for App")]) {
            [configs addObjectsFromArray:badgerRetriveConfigsWithAppPref([self appBundleID],@"BadgeLabelColor")];
        } else if ([[self cellTitle]isEqualToString:trans(@"Badge Color for App")]) {
            [configs addObjectsFromArray:badgerRetriveConfigsWithAppPref([self appBundleID],@"BadgeColor")];
        } else if ([[self cellTitle]isEqualToString:trans(@"Badge Shape for App")]) {
            [configs addObjectsFromArray:badgerRetriveConfigsWithAppPref([self appBundleID],@"BadgeShape")];
        } else if ([[self cellTitle]isEqualToString:trans(@"Badge Opacity for App")]) {
            [configs addObjectsFromArray:badgerRetriveConfigsWithAppPref([self appBundleID],@"BadgeOpacity")];
        }
    } else {
        if ([[self cellTitle]isEqualToString:trans(@"Badge Image")]) {
            [configs addObjectsFromArray:badgerRetriveConfigsWithUniversalPref(@"BadgeImagePath")];
        } else if ([[self cellTitle]isEqualToString:trans(@"Custom Badge Label")]) {
            [configs addObjectsFromArray:badgerRetriveConfigsWithUniversalPref(@"BadgeLabel")];
        } else if ([[self cellTitle]isEqualToString:trans(@"Badge Size")]) {
            [configs addObjectsFromArray:badgerRetriveConfigsWithUniversalPref(@"BadgeSize")];
        } else if ([[self cellTitle]isEqualToString:trans(@"Badge Label Color")]) {
            [configs addObjectsFromArray:badgerRetriveConfigsWithUniversalPref(@"BadgeLabelColor")];
        } else if ([[self cellTitle]isEqualToString:trans(@"Badge Color")]) {
            [configs addObjectsFromArray:badgerRetriveConfigsWithUniversalPref(@"BadgeColor")];
        } else if ([[self cellTitle]isEqualToString:trans(@"Badge Shape")]) {
            [configs addObjectsFromArray:badgerRetriveConfigsWithUniversalPref(@"BadgeShape")];
        } else if ([[self cellTitle]isEqualToString:trans(@"Badge Opacity")]) {
            [configs addObjectsFromArray:badgerRetriveConfigsWithUniversalPref(@"BadgeOpacity")];
        } else if ([[self cellTitle]isEqualToString:trans(@"Badge Font")]) {
            [configs addObjectsFromArray:badgerRetriveConfigsWithUniversalPref(@"BadgeFont")];
        }
    }
    //configs = [[NSArray alloc]initWithArray:mutableConfigs];
    if (@available(iOS 13.0, *)) {
        self.configsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStyleInsetGrouped];
    } else {
        self.configsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStylePlain];
    }
    self.configsTableView.dataSource = self;
    self.configsTableView.delegate = self;
    //if (@available(iOS 11.0, *)) {
        //[_configsTableView setFrame:CGRectMake(0, 0, _configsTableView.frame.size.width, _configsTableView.frame.size.height)];
    /*} else {
        [_configsTableView setFrame:CGRectMake(0, 0, _configsTableView.frame.size.width, _configsTableView.frame.size.height)];
    }*/
    [self.view addSubview:self.configsTableView];
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
    topNotchCoverCount = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height / 1.5)];
    topNotchCoverCount.hidden = NO;
    topNotchCoverCount.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    [self.view addSubview:topNotchCoverCount];
    self.view.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    // Do any additional setup after loading the view.
}

//i hope to god i dont need this
#if 0
-(void)viewWillAppear:(BOOL)animated {
    //[topNotchCoverCount setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y)];
}
#endif

- (void)viewDidAppear:(BOOL)animated {
    if (@available(iOS 13.0, *)) {
        self.navigationController.navigationBar.tintColor = [UIColor labelColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    }
    [topNotchCoverCount setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y)];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [configs count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BadgerCountConfigItem *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[BadgerCountConfigItem alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = trans([configs objectAtIndex:indexPath.row]);
    } else {
        cell.textLabel.text = [configs objectAtIndex:indexPath.row];
    }
    /*if (indexPath.row != 0) {
        UIButton *deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width-(UIScreen.mainScreen.bounds.size.width / 2 - 40), 0, UIScreen.mainScreen.bounds.size.width / 2 - 40, 44)];
    [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        [deleteButton setTranslatesAutoresizingMaskIntoConstraints:YES];
        [deleteButton setTintColor:[UIColor redColor]];
        [deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [deleteButton addTarget:cell action:@selector(deleteCountConfig:) forControlEvents:UIControlEventTouchUpInside];
        for (UIView *subview in cell.subviews) {
            if ([subview isMemberOfClass:[UIButton class]]) {
                if ([((UIButton *)subview).titleLabel.text isEqualToString:@"Reset"] || [((UIButton *)subview).titleLabel.text isEqualToString:@"Delete"]) {
                    [subview removeFromSuperview];
                }
            }
        }
        if (![cell.subviews containsObject:deleteButton]) {
            [cell addSubview:deleteButton];
        }
    } else {
        UIButton *resetButton = [[UIButton alloc]initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width -(UIScreen.mainScreen.bounds.size.width / 2 - 40), 0, UIScreen.mainScreen.bounds.size.width / 2 - 40, 44)];
        //[resetButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0.866 blue:0.996 alpha:1.0]];
        //[resetButton setTintColor:[UIColor systemPinkColor]];
        //[resetButton.layer setCornerRadius:5.0];
        [resetButton setTitle:@"Reset" forState:UIControlStateNormal];
            [resetButton setTranslatesAutoresizingMaskIntoConstraints:YES];
            [resetButton setTintColor:[UIColor blueColor]];
            [resetButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [resetButton addTarget:cell action:@selector(resetDefaultConfig:) forControlEvents:UIControlEventTouchUpInside];
        for (UIView *subview in cell.subviews) {
            if ([subview isMemberOfClass:[UIButton class]]) {
                if ([((UIButton *)subview).titleLabel.text isEqualToString:@"Reset"] || [((UIButton *)subview).titleLabel.text isEqualToString:@"Delete"]) {
                    [subview removeFromSuperview];
                }
            }
        }
        if (![cell.subviews containsObject:resetButton]) {
            [cell addSubview:resetButton];
        }
    }*/
    //[deleteButton addTarget:self action:@selector(deleteCountConfig:) forControlEvents:UIControlEventValueChanged];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *countConfig = [configs objectAtIndex:indexPath.row];
    if ([[self cellTitle]isEqualToString:trans(@"Custom Badge Label")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeCountMinimumViewController *myNewVC = (BadgeCountMinimumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeCountMinimumViewController"];
        myNewVC.cellTitle = [self cellTitle];
        if (![countConfig isEqualToString:@"Universal (No Count Minimum)"]) {
            myNewVC.badgeCount = (int)[countConfig integerValue];
        }
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Image")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCustomImageViewController *myNewVC = (BadgerCustomImageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCustomImageViewController"];
        myNewVC.cellTitle = [self cellTitle];
        if (![countConfig isEqualToString:@"Default (No Count Minimum)"]) {
            myNewVC.badgeCount = (int)[countConfig integerValue];
        }
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Image for App")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgerCustomImageViewController *myNewVC = (BadgerCustomImageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCustomImageViewController"];
        myNewVC.appName = [self appName];
        myNewVC.appBundleID = [self appBundleID];
        myNewVC.cellTitle = [self cellTitle];
        if (![countConfig isEqualToString:@"Universal (No Count Minimum)"]) {
            myNewVC.badgeCount = (int)[countConfig integerValue];
        }
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Label Color")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeColorViewController *myNewVC = (BadgeColorViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeColorViewController"];
        myNewVC.cellTitle = [self cellTitle];
        if (![countConfig isEqualToString:@"Universal (No Count Minimum)"]) {
            myNewVC.badgeCount = (int)[countConfig integerValue];
        }
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Label Color for App")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeColorViewController *myNewVC = (BadgeColorViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeColorViewController"];
        myNewVC.appName = [self appName];
        myNewVC.appBundleID = [self appBundleID];
        myNewVC.cellTitle = [self cellTitle];
        if (![countConfig isEqualToString:@"Universal (No Count Minimum)"]) {
            myNewVC.badgeCount = (int)[countConfig integerValue];
        }
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Size")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeCountMinimumViewController *myNewVC = (BadgeCountMinimumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeCountMinimumViewController"];
        myNewVC.cellTitle = [self cellTitle];
        if (![countConfig isEqualToString:@"Universal (No Count Minimum)"]) {
            myNewVC.badgeCount = (int)[countConfig integerValue];
        }
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Size for App")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeCountMinimumViewController *myNewVC = (BadgeCountMinimumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeCountMinimumViewController"];
        myNewVC.appName = [self appName];
        myNewVC.appBundleID = [self appBundleID];
        myNewVC.cellTitle = [self cellTitle];
        if (![countConfig isEqualToString:@"Universal (No Count Minimum)"]) {
            myNewVC.badgeCount = (int)[countConfig integerValue];
        }
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Color")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeColorViewController *myNewVC = (BadgeColorViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeColorViewController"];
        myNewVC.cellTitle = [self cellTitle];
        if (![countConfig isEqualToString:@"Universal (No Count Minimum)"]) {
            myNewVC.badgeCount = (int)[countConfig integerValue];
        }
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Color for App")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeColorViewController *myNewVC = (BadgeColorViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeColorViewController"];
        myNewVC.appName = [self appName];
        myNewVC.appBundleID = [self appBundleID];
        myNewVC.cellTitle = [self cellTitle];
        if (![countConfig isEqualToString:@"Universal (No Count Minimum)"]) {
            myNewVC.badgeCount = (int)[countConfig integerValue];
        }
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Shape")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeColorViewController *myNewVC = (BadgeColorViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeColorViewController"];
        myNewVC.cellTitle = [self cellTitle];
        if (![countConfig isEqualToString:@"Universal (No Count Minimum)"]) {
            myNewVC.badgeCount = (int)[countConfig integerValue];
        }
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Shape for App")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeColorViewController *myNewVC = (BadgeColorViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeColorViewController"];
        myNewVC.appName = [self appName];
        myNewVC.appBundleID = [self appBundleID];
        myNewVC.cellTitle = [self cellTitle];
        if (![countConfig isEqualToString:@"Universal (No Count Minimum)"]) {
            myNewVC.badgeCount = (int)[countConfig integerValue];
        }
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Opacity")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeCountMinimumViewController *myNewVC = (BadgeCountMinimumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeCountMinimumViewController"];
        myNewVC.cellTitle = [self cellTitle];
        if (![countConfig isEqualToString:@"Universal (No Count Minimum)"]) {
            myNewVC.badgeCount = (int)[countConfig integerValue];
        }
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Opacity for App")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeCountMinimumViewController *myNewVC = (BadgeCountMinimumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeCountMinimumViewController"];
        myNewVC.appName = [self appName];
        myNewVC.appBundleID = [self appBundleID];
        myNewVC.cellTitle = [self cellTitle];
        if (![countConfig isEqualToString:@"Universal (No Count Minimum)"]) {
            myNewVC.badgeCount = (int)[countConfig integerValue];
        }
        [self.navigationController pushViewController:myNewVC animated:YES];
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Font")]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BadgeColorViewController *myNewVC = (BadgeColorViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeColorViewController"];
        myNewVC.cellTitle = [self cellTitle];
        if (![countConfig isEqualToString:@"Universal (No Count Minimum)"]) {
            myNewVC.badgeCount = (int)[countConfig integerValue];
        }
        [self.navigationController pushViewController:myNewVC animated:YES];
    }
    //go to view controller corresponding with cellTitle, pass countConfig into it
}
-(void)createCountConfig:(id)sender {
    //if (@available(iOS 8.0, *)) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Badger"
                                                                       message:trans(@"Input the minimum number of notifications you want your setting to appear.")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"2";
        }];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Count config %@", [[alert textFields][0] text]);
            [self completeCountConfig:[[alert textFields][0] text]];
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    /*} else {
        // Fallback on earlier versions
        
        //nothing atm lol
        //maybe for iOS 7- go to a new view controller with a editable TextView?
    }*/
}
-(void)deleteRowWithTitle:(NSString *)rowTitle {
    [configs removeObject:rowTitle];
    if ([[self cellTitle]isEqualToString:trans(@"Custom Badge Label")]) {
        badgerRemoveUniversalCountPref((int)[rowTitle integerValue], @"BadgeLabel");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Image")]) {
        badgerRemoveUniversalCountPref((int)[rowTitle integerValue], @"BadgeImagePath");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Image for App")]) {
           badgerRemoveAppCountPref((int)[rowTitle integerValue],[self appBundleID], @"BadgeImagePath");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Size")]) {
        badgerRemoveUniversalCountPref((int)[rowTitle integerValue], @"BadgeSize");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Size for App")]) {
        badgerRemoveAppCountPref((int)[rowTitle integerValue],[self appBundleID], @"BadgeSize");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Label Color")]) {
        badgerRemoveUniversalCountPref((int)[rowTitle integerValue], @"BadgeLabelColor");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Label Color for App")]) {
        badgerRemoveAppCountPref((int)[rowTitle integerValue],[self appBundleID], @"BadgeLabelColor");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Color")]) {
        badgerRemoveUniversalCountPref((int)[rowTitle integerValue], @"BadgeColor");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Color for App")]) {
        badgerRemoveAppCountPref((int)[rowTitle integerValue],[self appBundleID], @"BadgeColor");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Shape")]) {
        badgerRemoveUniversalCountPref((int)[rowTitle integerValue], @"BadgeShape");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Shape for App")]) {
        badgerRemoveAppCountPref((int)[rowTitle integerValue],[self appBundleID], @"BadgeShape");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Opacity")]) {
        badgerRemoveUniversalCountPref((int)[rowTitle integerValue], @"BadgeOpacity");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Opacity for App")]) {
        badgerRemoveAppCountPref((int)[rowTitle integerValue],[self appBundleID], @"BadgeOpacity");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Font")]) {
        badgerRemoveUniversalCountPref((int)[rowTitle integerValue], @"BadgeFont");
    }
    [_configsTableView reloadData];
}
-(void)resetDefault:(NSString *)rowTitle {
    if ([[self cellTitle]isEqualToString:trans(@"Custom Badge Label")]) {
        badgerRemoveUniversalPref(@"BadgeLabel");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Image")]) {
        badgerRemoveUniversalPref(@"BadgeImagePath");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Image for App")]) {
        badgerRemoveAppPref([self appBundleID],@"BadgeImagePath");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Size")]) {
        badgerRemoveUniversalPref(@"BadgeSize");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Size for App")]) {
        badgerRemoveAppPref([self appBundleID], @"BadgeSize");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Label Color")]) {
        badgerRemoveUniversalPref(@"BadgeLabelColor");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Label Color for App")]) {
        badgerRemoveAppPref([self appBundleID], @"BadgeLabelColor");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Color")]) {
        badgerRemoveUniversalPref(@"BadgeColor");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Color for App")]) {
        badgerRemoveAppPref([self appBundleID], @"BadgeColor");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Shape")]) {
        badgerRemoveUniversalPref(@"BadgeShape");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Shape for App")]) {
        badgerRemoveAppPref([self appBundleID], @"BadgeShape");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Opacity")]) {
        badgerRemoveUniversalPref(@"BadgeOpacity");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Opacity for App")]) {
        badgerRemoveAppPref([self appBundleID], @"BadgeOpacity");
    } else if ([[self cellTitle]isEqualToString:trans(@"Badge Font")]) {
        badgerRemoveUniversalPref(@"BadgeFont");
    }
}
-(void)completeCountConfig:(NSString *)countConfig {
    NSString *newText;
    NSScanner *scanner = [NSScanner scannerWithString:countConfig];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
    [scanner scanCharactersFromSet:numbers intoString:&newText];
    if (newText.length < 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid Count Configuration") message:trans(@"Please input a number.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:trans(@"Invalid Count Configuration")
                                                        message:trans(@"Please input a number.")
                                                       delegate:self
                                              cancelButtonTitle:trans(@"Okay")
                                              otherButtonTitles:nil];
        [alert show];*/
    } else {
        if ([newText integerValue] < 2) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid Count Configuration") message:trans(@"You need to set your badge count configuration to 2 or more. Use default instead, count configs will overrule it if you have any, and when a count config is not in use it will default to your default configuration.") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:confirmAction];
            [self presentViewController:alert animated:YES completion:nil];
            /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:trans(@"Invalid Count Configuration")
                                                            message:trans(@"You need to set your badge count configuration to 2 or more. Use default instead, count configs will overrule it if you have any, and when a count config is not in use it will default to your default configuration.")
                                                           delegate:self
                                                  cancelButtonTitle:trans(@"Okay")
                                                  otherButtonTitles:nil];
            [alert show];*/
        } else {
            //we don't need to save count config yet, just when user makes a value
            [configs addObject:[@([newText integerValue])stringValue]];
            [self->_configsTableView reloadData];
        }
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return trans(@"Reset");
    }
    return trans(@"Delete");
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.row == 0) {
            [(BadgerCountConfigItem *)[tableView cellForRowAtIndexPath:indexPath]resetDefaultConfig:(BadgerCountConfigItem *)[tableView cellForRowAtIndexPath:indexPath]];
        } else {
            [(BadgerCountConfigItem *)[tableView cellForRowAtIndexPath:indexPath]deleteCountConfig:(BadgerCountConfigItem *)[tableView cellForRowAtIndexPath:indexPath]];
        }
    }
}
@end

void deleteRowWithTitle(NSString *rowTitle) {
    if (![rowTitle isEqualToString:@"Universal (No Count Minimum)"]) {
        [_param deleteRowWithTitle:rowTitle];
    }
}

void resetDefault(NSString *rowTitle) {
    if ([rowTitle isEqualToString:@"Universal (No Count Minimum)"]) {
        [_param resetDefault:rowTitle];
    }
}

//
//  BadgerCountConfigManagerViewController.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/12/22.
//

#import "BadgerCountConfigManagerViewController.h"
#include "BadgerPrefHandler.h"
#import "BadgeCountMinimumViewController.h"
#import "BadgerCustomImageViewController.h"
#import "BadgeColorViewController.h"
#import <Foundation/Foundation.h>

NSMutableArray *configs;
UIView *topNotchCoverCount;
NSString *prefWeAreDealingWith;

@interface BadgerCountConfigManagerViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *configsTableView;
-(void)createCountConfig:(id)sender;
@end

@implementation BadgerCountConfigManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = trans(@"Configs");
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(createCountConfig:)]];
    if ([daCellTitle isEqualToString:trans(@"Badge Image for App")]) {
        prefWeAreDealingWith = @"BadgeImagePath";
    } else if ([daCellTitle isEqualToString:trans(@"Custom Badge Label for App")]) {
        prefWeAreDealingWith = @"BadgeLabel";
    } else if ([daCellTitle isEqualToString:trans(@"Badge Size for App")]) {
        prefWeAreDealingWith = @"BadgeSize";
    } else if ([daCellTitle isEqualToString:trans(@"Badge Label Color for App")]) {
        prefWeAreDealingWith = @"BadgeLabelColor";
    } else if ([daCellTitle isEqualToString:trans(@"Badge Color for App")]) {
        prefWeAreDealingWith = @"BadgeColor";
    } else if ([daCellTitle isEqualToString:trans(@"Badge Shape for App")]) {
        prefWeAreDealingWith = @"BadgeShape";
    } else if ([daCellTitle isEqualToString:trans(@"Badge Opacity for App")]) {
        prefWeAreDealingWith = @"BadgeOpacity";
    } else if ([daCellTitle isEqualToString:trans(@"Badge Image")]) {
        prefWeAreDealingWith = @"BadgeImagePath";
    } else if ([daCellTitle isEqualToString:trans(@"Custom Badge Label")]) {
        prefWeAreDealingWith = @"BadgeLabel";
    } else if ([daCellTitle isEqualToString:trans(@"Badge Size")]) {
        prefWeAreDealingWith = @"BadgeSize";
    } else if ([daCellTitle isEqualToString:trans(@"Badge Label Color")]) {
        prefWeAreDealingWith = @"BadgeLabelColor";
    } else if ([daCellTitle isEqualToString:trans(@"Badge Shape")]) {
        prefWeAreDealingWith = @"BadgeShape";
    } else if ([daCellTitle isEqualToString:trans(@"Badge Opacity")]) {
        prefWeAreDealingWith = @"BadgeOpacity";
    } else if ([daCellTitle isEqualToString:trans(@"Badge Font")]) {
        prefWeAreDealingWith = @"BadgeFont";
    } else if ([daCellTitle isEqualToString:trans(@"Badge Color")]) {
        prefWeAreDealingWith = @"BadgeColor";
    }
    configs = badgerRetriveConfigsWithCurrentPref([self appBundleID], prefWeAreDealingWith);
    if (@available(iOS 13.0, *)) {
        self.configsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStyleInsetGrouped];
    } else {
        self.configsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStylePlain];
    }
    self.configsTableView.dataSource = self;
    self.configsTableView.delegate = self;
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
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    if (@available(iOS 13.0, *)) {
        self.navigationController.navigationBar.tintColor = [UIColor labelColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    }
    [topNotchCoverCount setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y)];
    [topTopNotchCoverView setHidden:NO];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [configs count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSString *labelForCell = [configs objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        labelForCell = trans(labelForCell);
    }
    cell.textLabel.text = labelForCell;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [topTopNotchCoverView setHidden:YES];
    NSString *countConfig = [configs objectAtIndex:indexPath.row];
    /*
     if I move countConfig assignment to in the if statement, where it *should* be since it will only get used when we are not the default row, it messes up compiler optimizations so you have to leave it here :P
     */
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BadgerViewController *myNewVC;
    if ([daCellTitle isEqualToString:trans(@"Custom Badge Label")]) {
        myNewVC = (BadgeCountMinimumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeCountMinimumViewController"];
    } else if ([daCellTitle isEqualToString:trans(@"Badge Image")]) {
        myNewVC = (BadgerCustomImageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCustomImageViewController"];
    } else if ([daCellTitle isEqualToString:trans(@"Badge Image for App")]) {
        myNewVC = (BadgerCustomImageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgerCustomImageViewController"];
    } else if ([daCellTitle isEqualToString:trans(@"Badge Size")]) {
        myNewVC = (BadgeCountMinimumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeCountMinimumViewController"];
    } else if ([daCellTitle isEqualToString:trans(@"Badge Size for App")]) {
        myNewVC = (BadgeCountMinimumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeCountMinimumViewController"];
    } else if ([daCellTitle isEqualToString:trans(@"Badge Opacity")]) {
        myNewVC = (BadgeCountMinimumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeCountMinimumViewController"];
    } else if ([daCellTitle isEqualToString:trans(@"Badge Opacity for App")]) {
        myNewVC = (BadgeCountMinimumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeCountMinimumViewController"];
    } else {
        /* BadgeFont / Label Color / Label Color for App / Color for App / Color / Shape / Shape for App */
        myNewVC = (BadgeColorViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgeColorViewController"];
    }
    myNewVC.appName = [self appName];
    myNewVC.appBundleID = [self appBundleID];
    if (indexPath.row != 0) {
        /* Not universal/default - add badge count */
        myNewVC.badgeCount = [countConfig integerValue];
    }
    [self.navigationController pushViewController:myNewVC animated:YES];
    //go to view controller corresponding with cellTitle, pass countConfig into it
}
-(void)createCountConfig:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Badger"
                                                                       message:trans(@"Input the minimum number of notifications you want your setting to appear.")
                                                                preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"2";
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *newText;
        NSString *countConfig = [[alert textFields][0] text];
        NSScanner *scanner = [NSScanner scannerWithString:countConfig];
        NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
        [scanner scanCharactersFromSet:numbers intoString:&newText];
        UIAlertController *alert;
        if (newText.length < 1) {
            alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid Count Configuration") message:trans(@"Please input a number.") preferredStyle:UIAlertControllerStyleAlert];
        } else {
            if ([newText integerValue] < 2) {
                alert = [UIAlertController alertControllerWithTitle:trans(@"Invalid Count Configuration") message:trans(@"You need to set your badge count configuration to 2 or more. Use default instead, count configs will overrule it if you have any, and when a count config is not in use it will default to your default configuration.") preferredStyle:UIAlertControllerStyleAlert];
                
            } else {
                /* we don't need to save count config yet, just when user makes a value */
                [configs addObject:newText];
                [self->_configsTableView reloadData];
                return;
            }
        }
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:trans(@"Okay") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    [alert addAction:confirmAction];
    [self presentViewController:alert animated:YES completion:nil];
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
        NSString *rowTitle = [configs objectAtIndex:indexPath.row];
        /*
         BadgerApp binary if I keep this rowTitle assignment here:
         262,992
         BadgerApp binary if I move it to the else since we don't need to get it then:
         263,120
         wtf???
         Compiler optimizations are weird
         */
        if (indexPath.row == 0) {
            badgerRemoveCurrentPref(0, [self appBundleID], prefWeAreDealingWith);
        } else {
            [configs removeObject:rowTitle];
            badgerRemoveCurrentPref([rowTitle integerValue], [self appBundleID], prefWeAreDealingWith);
            [_configsTableView reloadData];
        }
    }
}
@end

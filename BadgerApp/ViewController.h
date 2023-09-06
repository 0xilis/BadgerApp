//
//  ViewController.h
//  BadgerApp
//
//  Created by Snoolie Keffaber on 8/26/22.
//

#import <UIKit/UIKit.h>
#import "BadgerEasyTranslations.h"

@interface ViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate>
NSString *cellTitleFromRow(long row);
UIImage *cellImageFromRow(long row);
//UIColor *basedCellColorFromRow(long row);
//UIColor *frenchCellColorFromRow(long row);
@end

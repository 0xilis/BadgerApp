//
//  ViewController.h
//  BadgerApp
//
//  Created by Snoolie Keffaber on 8/26/22.
//

#import <UIKit/UIKit.h>
#include <spawn.h>
#import "BadgerEasyTranslations.h"

@interface BadgerApplySettingsViewController : BadgerViewController //UIViewController
@property (weak, nonatomic) IBOutlet UIButton *respringButton;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextView *explainingBox;

@end

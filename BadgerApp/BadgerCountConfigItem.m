//
//  BadgerCountConfigItem.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/12/22.
//

#import "BadgerCountConfigManagerViewController.h"
#import "BadgerCountConfigItem.h"

@implementation BadgerCountConfigItem

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)deleteCountConfig:(id)sender {
    if ([self.textLabel.text isEqualToString:@"Universal (No Count Minimum)"]) {
        resetDefault(self.textLabel.text);
    } else {
        deleteRowWithTitle(self.textLabel.text);
    }
}

-(void)resetDefaultConfig:(id)sender {
    if ([self.textLabel.text isEqualToString:@"Universal (No Count Minimum)"]) {
        resetDefault(self.textLabel.text);
    }
}

@end

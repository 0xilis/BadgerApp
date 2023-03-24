//
//  BadgerTableViewCell.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/30/22.
//

#import "BadgerTableViewCell.h"

@implementation BadgerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.imageView.layer setMasksToBounds:YES];
    [self.imageView.layer setCornerRadius:8.0];
    [self.imageView setClipsToBounds:YES];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

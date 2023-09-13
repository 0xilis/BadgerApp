//
//  BadgerEasyTranslations.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/27/22.
//

#import "BadgerEasyTranslations.h"

NSString *trans(NSString *orig) {
    NSString *localizedString = NSLocalizedString(orig, "");
    if (localizedString) {
        return localizedString;
    }
    return orig;
}

@implementation BadgerViewController

@end

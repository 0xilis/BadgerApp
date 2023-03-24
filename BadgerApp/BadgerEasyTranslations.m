//
//  BadgerEasyTranslations.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/27/22.
//

#import "BadgerEasyTranslations.h"
#include <time.h>

@implementation BadgerEasyTranslations

@end

NSString *trans(NSString *orig) {
    if (NSLocalizedString(orig, "")) {
        return NSLocalizedString(orig, "");
    } else {
        return orig;
    }
}

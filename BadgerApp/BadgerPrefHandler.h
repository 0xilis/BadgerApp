//
//  BadgerPrefHandler.h
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/9/22.
//

#ifndef BadgerPrefHandler_h
#define BadgerPrefHandler_h

#include <UIKit/UIKit.h>

void badgerSaveUniversalPref(NSString *prefKey, id prefValue);
void badgerSaveAppPref(NSString *prefApp, NSString *prefKey, id prefValue);
void badgerRemoveUniversalPref(NSString *prefKey);
void badgerRemoveAppPref(NSString *prefApp, NSString *prefKey);
void badgerSetUpPrefPlist(void);
id badgerRetriveUniversalPref(NSString *prefKey);
id badgerRetriveAppPref(NSString *prefApp, NSString *prefKey);
id badgerRetriveUniversalCountPref(long count, NSString *prefKey);
id badgerRetriveAppCountPref(long count, NSString *prefApp, NSString *prefKey);
NSMutableArray *badgerRetriveConfigsWithCurrentPref(NSString *prefApp, NSString *prefKey);
void badgerAddCompatibilitySafetyFlagsIfNeeded(void);
BOOL badgerIsCompatibleWithConfiguration(void);
NSString *badgerGetMinimumCompatibilityVersion(void);
void badgerRemoveCurrentPref(long count, NSString *prefApp, NSString *prefKey);
void badgerSaveCurrentPref(long count, NSString *prefApp, NSString *prefKey, id prefValue);
id badgerRetriveCurrentPref(long count, NSString *prefApp, NSString *prefKey);
//#define BADGER_PATH_TO_PLIST "/var/jb/var/mobile/Library/Badger/Prefs/BadgerPrefs.plist"
#define BADGER_PATH_TO_PLIST "/var/mobile/Library/Badger/Prefs/BadgerPrefs.plist"
#define BADGER_IS_ROOTLESS 0
//#define BADGER_OLD_PATH_TO_PLIST "/var/mobile/Library/Badger/Prefs/BadgerPrefs.plist"
//BOOL badgerCopyOldPathToNewPathForRootless(void);
#endif /* BadgerPrefHandler_h */

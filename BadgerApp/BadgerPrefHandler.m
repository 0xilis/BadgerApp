//
//  BadgerPrefHandler.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/9/22.
//

#include "BadgerPrefHandler.h"

#define BADGER_BUILD_NUMBER 6
#define BADGER_CONFIG_FORMAT_VERSION 1
#define BADGER_MINIMUM_COMPATIBILITY_VERSION 6
#define BADGER_DISPLAY_VERSION_FOR_MINIMUM_COMPATIBILITY_VERSION "1.2.2"

NSString *preferencesDirectory = @BADGER_PATH_TO_PLIST;
NSMutableDictionary *badgerPlist;
NSMutableDictionary *uniConfig;

void badgerSaveUniversalPref(NSString *prefKey, id prefValue) {
    uniConfig[@"DefaultConfig"][prefKey] = prefValue;
    [badgerPlist writeToFile:preferencesDirectory atomically:YES];
}
/* prefApp is app's bundle ID */
void badgerSaveAppPref(NSString *prefApp, NSString *prefKey, id prefValue) {
    NSMutableDictionary *appConfiguration = badgerPlist[@"AppConfiguration"];
    NSMutableDictionary *prefAppConfig = appConfiguration[prefApp];
    if (!prefAppConfig) {
        prefAppConfig = [[NSMutableDictionary alloc]init];
        appConfiguration[prefApp] = prefAppConfig;
    }
    NSMutableDictionary *defaultConfig = prefAppConfig[@"DefaultConfig"];
    if (!defaultConfig) {
        defaultConfig = [[NSMutableDictionary alloc]init];
        prefAppConfig[@"DefaultConfig"] = defaultConfig;
    }
    defaultConfig[prefKey] = prefValue;
    [badgerPlist writeToFile:preferencesDirectory atomically:YES];
}

void badgerRemoveUniversalPref(NSString *prefKey) {
    [uniConfig[@"DefaultConfig"] removeObjectForKey:prefKey];
    [badgerPlist writeToFile:preferencesDirectory atomically:YES];
}
/* prefApp is app's bundle ID */
void badgerRemoveAppPref(NSString *prefApp, NSString *prefKey) {
    NSMutableDictionary *appConfiguration = badgerPlist[@"AppConfiguration"];
    NSMutableDictionary *prefAppConfig = appConfiguration[prefApp];
    if (prefAppConfig) {
        NSMutableDictionary *defaultConfig = prefAppConfig[@"DefaultConfig"];
        if (!defaultConfig) {
            if (defaultConfig.count == 1) {
                if (prefAppConfig[@"CountSpecificConfigs"]) {
                    /* if we have no other keys but CountSpecificConfigs, remove DefaultConfig */
                    [prefAppConfig removeObjectForKey:@"DefaultConfig"];
                } else {
                    /* if we don't have CountSpecificConfigs, remove app config */
                    [appConfiguration removeObjectForKey:prefApp];
                }
            } else {
                /* remove the key */
                [defaultConfig removeObjectForKey:prefKey];
            }
        }
    }
    [badgerPlist writeToFile:preferencesDirectory atomically:YES];
}

/* it is highly important to call this first to initialize badgerPlist */
void badgerSetUpPrefPlist(void){
    badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if (!badgerPlist) {
        badgerPlist = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]init],@"DefaultConfig", nil],@"UniversalConfiguration",[[NSMutableDictionary alloc]init],@"AppConfiguration",@BADGER_CONFIG_FORMAT_VERSION,@"BadgerConfigFormatVersion",@BADGER_MINIMUM_COMPATIBILITY_VERSION,@"BadgerMinimumCompatibilityVersion",@BADGER_DISPLAY_VERSION_FOR_MINIMUM_COMPATIBILITY_VERSION,@"BadgerDiplayVersionForMinimumCompatibilityVersion",@YES,@"BadgerCheckCompatibility", nil];
        NSError* error=nil;
        NSPropertyListFormat format=NSPropertyListXMLFormat_v1_0; //NSPropertyListBinaryFormat_v1_0
        NSData* data =  [NSPropertyListSerialization dataWithPropertyList:badgerPlist format:format options:NSPropertyListImmutable error:&error];
        [data writeToFile:preferencesDirectory atomically:YES];
    }
    uniConfig = badgerPlist[@"UniversalConfiguration"];
}

/* we can blindly trust that DefaultConfig will be present */
id badgerRetriveUniversalPref(NSString *prefKey) {
    return uniConfig[@"DefaultConfig"][prefKey];
}

/* prefApp is app's bundle ID */
id badgerRetriveAppPref(NSString *prefApp, NSString *prefKey) {
    id appConfiguration = badgerPlist[@"AppConfiguration"];
    id prefAppConfigs = appConfiguration[prefApp];
    if (!prefAppConfigs) {
        /* app not in AppConfiguration, return NULL */
        return NULL;
    }
    id prefAppDefaultConfig = prefAppConfigs[@"DefaultConfig"];
    if (!prefAppDefaultConfig) {
        /* app does not have DefaultConfig, return NULL */
        return NULL;
    }
    return prefAppDefaultConfig[prefKey];
}

id badgerRetriveUniversalCountPref(long count, NSString *prefKey) {
    id countSpecificConfigs = uniConfig[@"CountSpecificConfigs"];
    if (!countSpecificConfigs) {
        /* count specific configs not in UniversalConfiguration, return NULL */
        return NULL;
    }
    id countSpecificConfig = countSpecificConfigs[[NSString stringWithFormat:@"%ld",count]];
    if (!countSpecificConfig) {
        /* UniversalConfiguration does not have this count config, return NULL */
        return NULL;
    }
    return countSpecificConfig[prefKey];
}

id badgerRetriveAppCountPref(long count, NSString *prefApp, NSString *prefKey) {
    id appConfiguration = badgerPlist[@"AppConfiguration"];
    id prefAppConfigs = appConfiguration[prefApp];
    if (!prefAppConfigs) {
        /* app not in AppConfiguration, return NULL */
        return NULL;
    }
    id prefAppCountSpecificConfigs = prefAppConfigs[@"CountSpecificConfigs"];
    if (!prefAppCountSpecificConfigs) {
        /* count specific configs not in app's configs, return NULL */
        return NULL;
    }
    id prefAppCountSpecificConfig = prefAppCountSpecificConfigs[[NSString stringWithFormat:@"%ld",count]];
    if (!prefAppCountSpecificConfig) {
        /* app's CountSpecificConfigs does not have this count, return NULL */
        return NULL;
    }
    return prefAppCountSpecificConfig[prefKey];
}

NSMutableArray *badgerRetriveConfigsWithCurrentPref(NSString *prefApp, NSString *prefKey) {
    NSMutableArray *configs = [[NSMutableArray alloc]initWithObjects:@"Universal (No Count Minimum)", nil];
    id countSpecificConfigs;
    if (prefApp) {
        id appConfiguration = badgerPlist[@"AppConfiguration"];
        id prefAppConfigs = appConfiguration[prefApp];
        if (!prefAppConfigs) {
            /* app not in AppConfiguration, return NULL */
            return configs;
        }
        countSpecificConfigs = prefAppConfigs[@"CountSpecificConfigs"];
    } else {
        countSpecificConfigs = uniConfig[@"CountSpecificConfigs"];
    }
    for (NSString *countConfig in countSpecificConfigs) {
        if (countSpecificConfigs[countConfig][prefKey]) {
            [configs addObject:countConfig];
        }
    }
    return configs;
}

/* checks if badger plist has compatibility flags, if not, add themv*/
void badgerAddCompatibilitySafetyFlagsIfNeeded(void) {
    /* these keys were added in Badger 1.2.2 */
    if (badgerPlist[@"BadgerCheckCompatibility"]) {
        return;
    }
    if (badgerPlist[@"BadgerMinimumCompatibilityVersion"]) {
        return;
    }
    if (badgerPlist[@"BadgerConfigFormatVersion"]) {
        return;
    }
    if (badgerPlist[@"BadgerDiplayVersionForMinimumCompatibilityVersion"]) {
        return;
    }
    /* No compatibility safety keys could be found in badgerPlist - add them */
    badgerPlist[@"BadgerConfigFormatVersion"] = @BADGER_CONFIG_FORMAT_VERSION;
    badgerPlist[@"BadgerMinimumCompatibilityVersion"] = @BADGER_MINIMUM_COMPATIBILITY_VERSION;
    badgerPlist[@"BadgerDiplayVersionForMinimumCompatibilityVersion"] = @BADGER_DISPLAY_VERSION_FOR_MINIMUM_COMPATIBILITY_VERSION;
    badgerPlist[@"BadgerCheckCompatibility"] = @YES;
    [badgerPlist writeToFile:preferencesDirectory atomically:YES];
}

/* ported from Paged */
BOOL badgerIsCompatibleWithConfiguration(void) {
    if ([badgerPlist[@"BadgerMinimumCompatibilityVersion"]integerValue] <= BADGER_BUILD_NUMBER) {
        return YES;
    }
    return !badgerPlist[@"BadgerCheckCompatibility"];
}

/* ported from Paged */
NSString *badgerGetMinimumCompatibilityVersion(void) {
    NSString *ret = badgerPlist[@"BadgerDiplayVersionForMinimumCompatibilityVersion"];
    if (!ret) {
        /* if PagedDiplayVersionForMinimumCompatibilityVersion cannot be loaded */
        return @"(null)";
    }
    return ret;
}

void badgerRemoveCurrentPref(long count, NSString *prefApp, NSString *prefKey) {
    if (prefApp) {
        if (count) {
            NSMutableDictionary *appConfiguration = badgerPlist[@"AppConfiguration"];
            NSMutableDictionary *prefAppConfig = appConfiguration[prefApp];
            NSMutableDictionary *countSpecificConfigs = prefAppConfig[@"CountSpecificConfigs"];
            NSMutableDictionary *countSpecificConfig = countSpecificConfigs[[NSString stringWithFormat:@"%ld",count]];
            if (countSpecificConfig.count == 1) {
                /* since we're removing the only pref the count config has, might as well free the whole count config altogether */
                if (countSpecificConfigs.count == 1) {
                    /* check if appconfiguration has DefaultConfig */
                    if (prefAppConfig.count == 1) {
                        [appConfiguration removeObjectForKey:prefApp];
                    } else {
                        [prefAppConfig removeObjectForKey:@"CountSpecificConfigs"];
                    }
                } else {
                    [countSpecificConfigs removeObjectForKey:[NSString stringWithFormat:@"%ld",count]];
                }
            } else {
                [countSpecificConfig removeObjectForKey:prefKey];
            }
            [badgerPlist writeToFile:preferencesDirectory atomically:YES];
        } else {
            badgerRemoveAppPref(prefApp, prefKey);
        }
    } else {
        if (count) {
            NSMutableDictionary *countSpecificConfigs = uniConfig[@"CountSpecificConfigs"];
            NSMutableDictionary *countSpecificConfig = countSpecificConfigs[[NSString stringWithFormat:@"%ld",count]];
            if (countSpecificConfig.count == 1) {
                /* since we're removing the only pref the count config has, might as well free the whole count config altogether */
                if (countSpecificConfigs.count == 1) {
                    [uniConfig removeObjectForKey:@"CountSpecificConfigs"];
                } else {
                    [countSpecificConfigs removeObjectForKey:[NSString stringWithFormat:@"%ld",count]];
                }
            } else {
                [countSpecificConfig removeObjectForKey:prefKey];
            }
            [badgerPlist writeToFile:preferencesDirectory atomically:YES];
        } else {
            badgerRemoveUniversalPref(prefKey);
        }
    }
}

void badgerSaveCurrentPref(long count, NSString *prefApp, NSString *prefKey, id prefValue) {
    if (count) {
        if (prefApp) {
            if (count <= 999999) {
                NSMutableDictionary *appConfiguration = badgerPlist[@"AppConfiguration"];
                /* AppConfiguration should ALWAYS be in the plist (even if it's blank!) so we don't have to check if it's there */
                NSMutableDictionary *prefAppConfig = appConfiguration[prefApp];
                /* if the app bundle ID is not listed in AppConfiguration, add it */
                if (!prefAppConfig) {
                    prefAppConfig = [[NSMutableDictionary alloc]init];
                    appConfiguration[prefApp] = prefAppConfig;
                }
                NSMutableDictionary *countSpecificConfigs = prefAppConfig[@"CountSpecificConfigs"];
                if (!countSpecificConfigs) {
                    /* if countspecificconfigs does not exist in the dictionary, add it */
                    countSpecificConfigs = [[NSMutableDictionary alloc]init];
                    prefAppConfig[@"CountSpecificConfigs"] = countSpecificConfigs;
                }
                NSMutableDictionary *countSpecificConfig = countSpecificConfigs[[NSString stringWithFormat:@"%ld", count]];
                if (!countSpecificConfig) {
                    countSpecificConfig = [[NSMutableDictionary alloc]init];
                    countSpecificConfigs[[NSString stringWithFormat:@"%ld", count]] = countSpecificConfig;
                }
                countSpecificConfig[prefKey] = prefValue;
                [badgerPlist writeToFile:preferencesDirectory atomically:YES];
            }
        } else {
            if (count <= 999999) {
                NSMutableDictionary *countSpecificConfigs = uniConfig[@"CountSpecificConfigs"];
                if (!countSpecificConfigs) {
                    countSpecificConfigs = [[NSMutableDictionary alloc]init];
                    uniConfig[@"CountSpecificConfigs"] = countSpecificConfigs;
                }
                NSMutableDictionary *countSpecificConfig = countSpecificConfigs[[NSString stringWithFormat:@"%ld", count]];
                if (!countSpecificConfig) {
                    countSpecificConfig = [[NSMutableDictionary alloc]init];
                    countSpecificConfigs[[NSString stringWithFormat:@"%ld", count]] = countSpecificConfig;
                }
                countSpecificConfig[prefKey] = prefValue;
                [badgerPlist writeToFile:preferencesDirectory atomically:YES];
            }
        }
    } else {
        if (prefApp) {
            badgerSaveAppPref(prefApp, prefKey, prefValue);
        } else {
            badgerSaveUniversalPref(prefKey, prefValue);
        }
    }
}

id badgerRetriveCurrentPref(long count, NSString *prefApp, NSString *prefKey) {
    if (count) {
        if (prefApp) {
            return badgerRetriveAppCountPref(count, prefApp, prefKey);
        } else {
            return badgerRetriveUniversalCountPref(count, prefKey);
        }
    } else {
        if (prefApp) {
            return badgerRetriveAppPref(prefApp, prefKey);
        } else {
            return badgerRetriveUniversalPref(prefKey);
        }
    }
}

#if BADGER_IS_ROOTLESS
BOOL badgerCopyOldPathToNewPathForRootless(void) {
    const char *functionName = "badgerCopyOldPathToNewPathForRootless";
    if (!badgerPlist) {
        //NSLog(@"BadgerApp ERROR: (badgerCopyOldPathToNewPathForRootless) Cannot find plist??");
        cannotFindPlistError(functionName);
        return NO;
    }
    id universalConfiguration = badgerPlist[@"UniversalConfiguration"];
    if (!universalConfiguration) {
        //badgerPlist does not seem to have a UniversalConfiguration present - this should always??
        //NSLog(@"BadgerApp ERROR: (badgerCopyOldPathToNewPathForRootless) No UniversalConfiguration present??");
        cannotFindUniversalConfigurationError("badgerCopyOldPathToNewPathForRootless");
        return NO;
    }
    //Copy BadgeImages and BadgeFonts to new /var/jb directory
    NSError *dError;
    [[NSFileManager defaultManager] copyItemAtPath:@"/var/mobile/Library/Badger/BadgeImages" toPath:@"/var/jb/var/mobile/Library/Badger/BadgeImages" error:&dError];
    NSError *dError2;
    [[NSFileManager defaultManager] copyItemAtPath:@"/var/mobile/Library/Badger/BadgeFonts" toPath:@"/var/jb/var/mobile/Library/Badger/BadgeFonts" error:&dError2];
    //Cycle through BadgeImage and BadgeFontPath and change to /var/jb
    NSMutableDictionary *newBadgerPlist = [[NSMutableDictionary alloc]initWithDictionary:[badgerPlist copy]];
    NSDictionary* defaultConfig = universalConfiguration[@"DefaultConfig"];
    if (defaultConfig) {
        NSString* pathToFont = defaultConfig[@"BadgeFontPath"];
        if (pathToFont) {
            if ([pathToFont hasPrefix:@"/var/mobile/Library/Badger/BadgeFonts/"]) {
                newBadgerPlist[@"UniversalConfiguration"][@"DefaultConfig"][@"BadgeFontPath"] = [pathToFont stringByReplacingOccurrencesOfString:@"/var/mobile/Library/Badger/BadgeFonts/" withString:@"/var/jb/var/mobile/Library/Badger/BadgeFonts/"];
            }
        }
        NSString* pathToImage = defaultConfig[@"BadgeImagePath"];
        if (pathToImage) {
            if ([pathToImage hasPrefix:@"/var/mobile/Library/Badger/BadgeImages/"]) {
                newBadgerPlist[@"UniversalConfiguration"][@"DefaultConfig"][@"BadgeImagePath"] = [pathToFont stringByReplacingOccurrencesOfString:@"/var/mobile/Library/Badger/BadgeImages/" withString:@"/var/jb/var/mobile/Library/Badger/BadgeImages/"];
            }
        }
    }
    NSDictionary* countSpecificConfigs = universalConfiguration[@"CountSpecificConfigs"];
    for (NSString *aKey in countSpecificConfigs) {
        NSDictionary* countSpecificConfig = countSpecificConfigs[aKey];
        //this safety check should not be needed but eh
        if (countSpecificConfig) {
            NSString* pathToFont = countSpecificConfig[@"BadgeFontPath"];
            if (pathToFont) {
                if ([pathToFont hasPrefix:@"/var/mobile/Library/Badger/BadgeFonts/"]) {
                    newBadgerPlist[@"UniversalConfiguration"][@"CountSpecificConfigs"][aKey][@"BadgeFontPath"] = [pathToFont stringByReplacingOccurrencesOfString:@"/var/mobile/Library/Badger/BadgeFonts/" withString:@"/var/jb/var/mobile/Library/Badger/BadgeFonts/"];
                }
            }
            NSString* pathToImage = countSpecificConfig[@"BadgeImagePath"];
            if (pathToImage) {
                if ([pathToImage hasPrefix:@"/var/mobile/Library/Badger/BadgeImages/"]) {
                    newBadgerPlist[@"UniversalConfiguration"][@"CountSpecificConfigs"][aKey][@"BadgeImagePath"] = [pathToFont stringByReplacingOccurrencesOfString:@"/var/mobile/Library/Badger/BadgeImages/" withString:@"/var/jb/var/mobile/Library/Badger/BadgeImages/"];
                }
            }
        }
    }
    NSDictionary* appConfigs = universalConfiguration[@"AppConfiguration"];
    for (NSString *aKey in appConfigs) {
        NSDictionary* appConfig = appConfigs[aKey];
        if (appConfig) {
            NSDictionary* defaultConfigForApp = appConfig[@"DefaultConfig"];
            if (defaultConfigForApp) {
                NSString* pathToFont = defaultConfigForApp[@"BadgeFontPath"];
                if (pathToFont) {
                    if ([pathToFont hasPrefix:@"/var/mobile/Library/Badger/BadgeFonts/"]) {
                        newBadgerPlist[@"AppConfiguration"][aKey][@"DefaultConfig"][@"BadgeFontPath"] = [pathToFont stringByReplacingOccurrencesOfString:@"/var/mobile/Library/Badger/BadgeFonts/" withString:@"/var/jb/var/mobile/Library/Badger/BadgeFonts/"];
                    }
                }
                NSString* pathToImage = defaultConfigForApp[@"BadgeImagePath"];
                if (pathToImage) {
                    if ([pathToImage hasPrefix:@"/var/mobile/Library/Badger/BadgeImages/"]) {
                        newBadgerPlist[@"AppConfiguration"][aKey][@"DefaultConfig"][@"BadgeImagePath"] = [pathToFont stringByReplacingOccurrencesOfString:@"/var/mobile/Library/Badger/BadgeImages/" withString:@"/var/jb/var/mobile/Library/Badger/BadgeImages/"];
                    }
                }
            }
            NSDictionary* countSpecificConfigsForApp = appConfig[@"CountSpecificConfigs"];
            for (NSString *aKey2 in countSpecificConfigsForApp) {
                NSDictionary* countSpecificConfigForApp = countSpecificConfigsForApp[aKey2];
                //this safety check should not be needed but eh
                if (countSpecificConfigForApp) {
                    NSString* pathToFont = countSpecificConfigForApp[@"BadgeFontPath"];
                    if (pathToFont) {
                        if ([pathToFont hasPrefix:@"/var/mobile/Library/Badger/BadgeFonts/"]) {
                            newBadgerPlist[@"AppConfiguration"][aKey][@"CountSpecificConfigs"][aKey2][@"BadgeFontPath"] = [pathToFont stringByReplacingOccurrencesOfString:@"/var/mobile/Library/Badger/BadgeFonts/" withString:@"/var/jb/var/mobile/Library/Badger/BadgeFonts/"];
                        }
                    }
                    NSString* pathToImage = countSpecificConfigForApp[@"BadgeImagePath"];
                    if (pathToImage) {
                        if ([pathToImage hasPrefix:@"/var/mobile/Library/Badger/BadgeImages/"]) {
                            newBadgerPlist[@"AppConfiguration"][aKey][@"CountSpecificConfigs"][aKey2][@"BadgeImagePath"] = [pathToFont stringByReplacingOccurrencesOfString:@"/var/mobile/Library/Badger/BadgeImages/" withString:@"/var/jb/var/mobile/Library/Badger/BadgeImages/"];
                        }
                    }
                }
            }
        }
    }
    //Save modified plist to new /var/jb path
    NSError* error=nil;
    NSPropertyListFormat format=NSPropertyListXMLFormat_v1_0;
    NSData* data =  [NSPropertyListSerialization dataWithPropertyList:badgerPlist format:format options:NSPropertyListImmutable error:&error];
    [data writeToFile:preferencesDirectory atomically:YES];
    return YES; //succession - return YES
}
#endif

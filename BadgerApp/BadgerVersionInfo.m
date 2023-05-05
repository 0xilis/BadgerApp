//
//  BadgerVersionInfo.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/27/22.
//

#import "BadgerVersionInfo.h"
#include <time.h>

@implementation BadgerVersionInfo

-(void)checkIsExpired {
    if ([self buildCanExpire]) {
        time_t mytime;
        //struct tm * timeinfo;
        time(&mytime);
        //timeinfo = localtime(&mytime);
        //const char *time_str = [[NSString stringWithFormat:@"%02d%02d%02d",timeinfo->tm_year+1900,timeinfo->tm_mon+1,timeinfo->tm_mday]UTF8String];
        /*char time_str[9];
        sprintf(time_str, "%04d%02d%02d", timeinfo->tm_year+1900,timeinfo->tm_mon+1,timeinfo->tm_mday);*/
        
        struct tm dt = {0};
        //time_t dt2 = 0;
        strptime([self versionExpireDate], "%Y%m%d", &dt);
        //dt2 = mktime(&dt);
        time_t dt2 = mktime(&dt);
        
        //strptime(time_str, "%Y%m%d", &dt);
        //dt1 = mktime(&dt);
        //https://stackoverflow.com/questions/30170313/compare-time-in-c
        //dt1 = mktime(timeinfo);
        
        double seconds = difftime(dt2,mytime); //on 32bit c compiler (https://www.geeksforgeeks.org/data-types-in-c/) a double can be 1.7E-308 to 1.7E+308
        
        if (seconds < 0) {
            [self setDaysSinceExpire:(seconds/86400)]; //86400 is 60*60*24
            [self setIsExpired:YES];
        } else {
            [self setIsExpired:NO];
        }
    } else {
        [self setIsExpired:NO];
    }
}

-(void)populateSelfWithInfo {
    [self setIsBeta:NO];
    [self setBadgerBuild:@"1G"];
    [self setBadgerVersion:@"1.2.2"]; //1.2.1-1
    [self setBuildCanExpire:NO];
    [self setVersionExpireDate:"20230429"];
    [self setDaysSinceExpire:0];
    [self setIsTrial:NO];
}

@end

/*#define isBeta 0
#define isExpired 0
#define buildCanExpire 0
#define versionExpireDate "20221029"
//@property (nonatomic, assign, readwrite) long daysSinceExpire;
#define badgerBuild @"1F"
#define badgerVersion @"1.2.2"
#define isTrial 0*/

//
//  BadgerVersionInfo.h
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/27/22.
//


#define TRIAL 0

#if TRIAL

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BadgerVersionInfo : NSObject
@property (nonatomic, assign, readwrite) BOOL isBeta;
@property (nonatomic, assign, readwrite) BOOL isExpired;
@property (nonatomic, assign, readwrite) BOOL buildCanExpire;
@property (nonatomic, assign, readwrite) char* versionExpireDate;
@property (nonatomic, assign, readwrite) long daysSinceExpire;
@property (nonatomic, assign, readwrite) NSString* badgerBuild;
@property (nonatomic, assign, readwrite) NSString* badgerVersion;
@property (nonatomic, assign, readwrite) BOOL isTrial;
-(void)checkIsExpired;
-(void)populateSelfWithInfo;
@end

NS_ASSUME_NONNULL_END

#endif

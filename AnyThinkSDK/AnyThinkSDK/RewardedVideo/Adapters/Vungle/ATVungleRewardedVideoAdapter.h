//
//  ATVungleRewardedVideoAdapter.h
//  AnyThinkVungleRewardedVideoAdapter
//
//  Created by Martin Lau on 11/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
extern NSString *const kVungleRewardedVideoLoadNotification;
extern NSString *const kVungleRewardedVideoShowNotification;
extern NSString *const kVungleRewardedVideoClickNotification;
extern NSString *const kVungleRewardedVideoRewardNotification;
extern NSString *const kVungleRewardedVideoCloseNotification;
extern NSString *const kVungleRewardedVideoNotificationUserInfoPlacementIDKey;
extern NSString *const kVungleRewardedVideoNotificationUserInfoErrorKey;

@interface ATVungleRewardedVideoAdapter : NSObject
@end

@protocol ATVungleSDKDelegate;
@protocol ATVungleSDK<NSObject>
@property (strong) NSDictionary *userData;
@property (nullable, strong) id<ATVungleSDKDelegate> delegate;
@property (assign) BOOL muted;
@property (atomic, readonly, getter=isInitialized) BOOL initialized;
+ (instancetype)sharedSDK;
- (void)updateConsentStatus:(NSInteger)status consentMessageVersion:(NSString *)version;
- (BOOL)startWithAppId:(nonnull NSString *)appID error:(NSError **)error;
- (BOOL)playAd:(UIViewController *)controller options:(nullable NSDictionary *)options placementID:(nullable NSString *)placementID error:( NSError *__autoreleasing _Nullable *_Nullable)error;
- (BOOL)isAdCachedForPlacementID:(nonnull NSString *)placementID;
- (BOOL)loadPlacementWithID:(NSString *)placementID error:(NSError **)error;
@end


@protocol ATVungleSDKDelegate <NSObject>
@optional
- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(nullable NSString *)placementID error:(nullable NSError *)error;
- (void)vungleDidShowAdForPlacementID:(nullable NSString *)placementID;
- (void)vungleTrackClickForPlacementID:(nullable NSString *)placementID;
- (void)vungleRewardUserForPlacementID:(nullable NSString *)placementID;
- (void)vungleDidCloseAdForPlacementID:(nonnull NSString *)placementID;
- (void)vungleSDKDidInitialize;
- (void)vungleSDKFailedToInitializeWithError:(NSError *)error;
@end

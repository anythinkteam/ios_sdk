//
//  ATAdmobSplashAdapter.h
//  AnyThinkAdmobSplashAdapter
//
//  Created by Topon on 9/30/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATAdmobSplashAdapter : NSObject

@end

@protocol ATGADRequest<NSObject>
+ (NSString *)sdkVersion;
+ (instancetype)request;
@property(nonatomic, copy) NSArray *testDevices;
@end

@protocol ATGADAppOpenAd;
typedef void (^GADAppOpenAdLoadCompletionHandler)(id<ATGADAppOpenAd> appOpenAd,
                                                  NSError *_Nullable error);

@protocol GADFullScreenContentDelegate;
@protocol ATGADAppOpenAd <NSObject>
+ (void)loadWithAdUnitID:(nonnull NSString *)adUnitID
                 request:(id<ATGADRequest>)request
             orientation:(UIInterfaceOrientation)orientation
       completionHandler:(nonnull GADAppOpenAdLoadCompletionHandler)completionHandler;
@property(nonatomic, weak, nullable) id<GADFullScreenContentDelegate> fullScreenContentDelegate;
- (BOOL)canPresentFromRootViewController:(nonnull UIViewController *)rootViewController
                                   error:(NSError *_Nullable __autoreleasing *_Nullable)error;
- (void)presentFromRootViewController:(nonnull UIViewController *)rootViewController;

@end

@protocol ATGADFullScreenPresentingAd <NSObject>
@property(nonatomic, weak, nullable) id<GADFullScreenContentDelegate> fullScreenContentDelegate;
@end

@protocol GADFullScreenContentDelegate <NSObject>
@optional
- (void)ad:(nonnull id<ATGADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(nonnull NSError *)error;
- (void)adDidPresentFullScreenContent:(nonnull id<ATGADFullScreenPresentingAd>)ad;
- (void)adDidDismissFullScreenContent:(nonnull id<ATGADFullScreenPresentingAd>)ad;
@end

NS_ASSUME_NONNULL_END

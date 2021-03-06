//
//  ATGDTNativeAdapter.h
//  AnyThinkGDTNativeAdapter
//
//  Created by Martin Lau on 26/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
extern NSString *const kGDTNativeAssetsExpressAdKey;
extern NSString *const kGDTNativeAssetsExpressAdViewKey;
extern NSString *const kGDTNativeAssetsCustomEventKey;

extern NSString *const kGDTNativeAssetsNativeAdDataKey;
extern NSString *const kGDTNativeAssetsTitleKey;
extern NSString *const kGDTNativeAssetsDescKey;
extern NSString *const kGDTNativeAssetsIconUrl;
extern NSString *const kGDTNativeAssetsImageUrl;
extern NSString *const kGDTNativeAssetsAppRating;
extern NSString *const kGDTNativeAssetsAppPrice;
extern NSString *const kGDTNativeAssetsImgList;
@interface ATGDTNativeAdapter : NSObject
@end

@protocol ATGDTNativeExpressAdView<NSObject>
@property (nonatomic, assign, readonly) BOOL isReady;
@property (nonatomic, assign, readonly) BOOL isVideoAd;
@property (nonatomic, weak) UIViewController *controller;
@property(nonatomic) CGRect  bounds;
@property(nonatomic) CGPoint center;
@property(nonatomic) UIViewAutoresizing autoresizingMask;  
- (void)render;
- (CGFloat)videoDuration;
- (CGFloat)videoPlayTime;

@end

typedef NS_ENUM(NSUInteger, GDTMediaPlayerStatus) {
    GDTMediaPlayerStatusInitial = 0,         // 初始状态
    GDTMediaPlayerStatusLoading = 1,         // 加载中
    GDTMediaPlayerStatusStarted = 2,         // 开始播放
    GDTMediaPlayerStatusPaused = 3,          // 用户行为导致暂停
    GDTMediaPlayerStatusStoped = 4,          // 播放停止
    GDTMediaPlayerStatusError = 5,           // 播放出错
};


@protocol GDTNativeExpressAdDelegete <NSObject>
@end

@protocol ATGDTNativeExpressAd<NSObject>
@property (nonatomic, weak) id<GDTNativeExpressAdDelegete> delegate;
@property (nonatomic, assign) BOOL videoAutoPlayOnWWAN;
@property (nonatomic, assign) BOOL videoMuted;
@property (nonatomic) NSInteger maxVideoDuration;
- (instancetype)initWithAppId:(NSString *)appId placementId:(NSString *)placementId adSize:(CGSize)size;
- (void)loadAd:(NSInteger)count;
@end

@protocol ATGDTNativeAdData<NSObject>

/*
 *  广告内容字典
 *  详解：[必选]开发者调用LoadAd成功之后从该属性中获取广告数据
 *       广告数据以字典的形式存储，开发者目前可以通过如下键获取数据
 *          1. GDTNativeAdDataKeyTitle      标题
 *          2. GDTNativeAdDataKeyDesc       描述
 *          3. GDTNativeAdDataKeyIconUrl    图标Url
 *          4. GDTNativeAdDataKeyImgUrl     大图Url
 *          5. GDTNativeAdDataKeyAppRating  应用类广告的星级
 *          6. GDTNativeAdDataKeyAppPrice   应用类广告的价格
 *          7. GDTNativeAdDataKeyImgList    三小图广告的图片集合
 */
@property (nonatomic, retain, readonly) NSDictionary *properties;
- (BOOL)equalsAdData:(id<ATGDTNativeAdData>)data;
- (BOOL)isAppAd;
- (BOOL)isThreeImgsAd;
@end

@protocol ATGDTNativeAd;

@protocol GDTNativeAdDelegate <NSObject>
- (void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray;
- (void)nativeAdFailToLoad:(NSError *)error;
@optional
- (void)nativeAdWillPresentScreen;
- (void)nativeAdApplicationWillEnterBackground;
- (void)nativeAdClosed;
@end

@protocol ATGDTNativeAd<NSObject, SKStoreProductViewControllerDelegate>
@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, weak) id<GDTNativeAdDelegate> delegate;
- (instancetype)initWithAppId:(NSString *)appId placementId:(NSString *)placementId;
- (void)loadAd:(int)adCount;
- (void)attachAd:(id<ATGDTNativeAdData>)nativeAdData toView:(UIView *)view;
- (void)clickAd:(id<ATGDTNativeAdData>)nativeAdData;
@end

@protocol ATGDTVideoConfig;
@protocol ATGDTUnifiedNativeAdDataObject<NSObject>
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *desc;
@property (nonatomic, copy, readonly) NSString *imageUrl;
@property (nonatomic, copy, readonly) NSString *iconUrl;
@property (nonatomic, copy, readonly) NSArray *mediaUrlList;
@property (nonatomic, readonly) CGFloat appRating;
@property (nonatomic, strong, readonly) NSNumber *appPrice;
@property (nonatomic, readonly) BOOL isAppAd;
@property (nonatomic, readonly) BOOL isVideoAd;
@property (nonatomic, readonly) BOOL isThreeImgsAd;
@property (nonatomic, strong) id<ATGDTVideoConfig> videoConfig;
- (BOOL) equlasAdData:(id<ATGDTUnifiedNativeAdDataObject>)dataObject;
@end

@protocol GDTUnifiedNativeAdDelegate <NSObject>
- (void)gdt_unifiedNativeAdLoaded:(NSArray<id<ATGDTUnifiedNativeAdDataObject>> *)unifiedNativeAdDataObjects error:(NSError *)error;
@end

@protocol ATGDTUnifiedNativeAd<NSObject>
@property (nonatomic, weak) id<GDTUnifiedNativeAdDelegate> delegate;
@property (nonatomic) NSInteger maxVideoDuration;
- (instancetype)initWithPlacementId:(NSString *)placementId;
- (void)loadAd;
- (void)loadAdWithAdCount:(int)adCount;
@end

@protocol GDTUnifiedNativeAdViewDelegate <NSObject>
@end

@protocol ATGDTMediaView<NSObject>
@end
@protocol ATGDTLogoView<NSObject>
@property(nonatomic) UIViewAutoresizing autoresizingMask;
@end

@protocol ATGDTUnifiedNativeAdView<NSObject>
- (instancetype)initWithFrame:(CGRect)frame;
@property(nonatomic) UIViewAutoresizing autoresizingMask;
@property(nonatomic) CGRect frame;
@property (nonatomic, strong, readonly) id<ATGDTMediaView> mediaView;
@property (nonatomic, weak) id<GDTUnifiedNativeAdViewDelegate> delegate;
@property (nonatomic, weak) UIViewController *viewController;
- (void)registerDataObject:(id<ATGDTUnifiedNativeAdDataObject>)dataObject
                  logoView:(id<ATGDTLogoView>)logoView
            viewController:(UIViewController *)viewController
            clickableViews:(NSArray<UIView *> *)clickableViews;
- (void)registerDataObject:(id<ATGDTUnifiedNativeAdDataObject>)dataObject
                 mediaView:(id<ATGDTMediaView>)mediaView
                  logoView:(id<ATGDTLogoView>)logoView
            viewController:(UIViewController *)viewController
            clickableViews:(NSArray<UIView *> *)clickableViews;
- (void)registerDataObject:(id<ATGDTUnifiedNativeAdDataObject>)dataObject
            clickableViews:(NSArray<UIView *> *)clickableViews;
@end

typedef NS_ENUM(NSInteger, GDTVideoAutoPlayPolicy) {
    GDTVideoAutoPlayPolicyWIFI = 0, // WIFI 下自动播放
    GDTVideoAutoPlayPolicyAlways = 1, // 总是自动播放，无论网络条件
    GDTVideoAutoPlayPolicyNever = 2, // 从不自动播放，无论网络条件
};
@protocol ATGDTVideoConfig<NSObject>
@property (nonatomic, assign) GDTVideoAutoPlayPolicy autoPlayPolicy;
@property (nonatomic, assign) BOOL videoMuted;
@end

@protocol ATGDTAdParams <NSObject>
@property (nonatomic, assign) CGSize adSize;
@property (nonatomic, assign) BOOL videoAutoPlayOnWWAN;
@property (nonatomic, assign) BOOL videoMuted;
@property (nonatomic, assign) BOOL detailPageVideoMuted;
@property (nonatomic) NSInteger minVideoDuration;
@property (nonatomic) NSInteger maxVideoDuration;
@end

@protocol GDTNativeExpressProAdViewDelegate;
@protocol ATGDTNativeExpressProAdView <NSObject>
@property (nonatomic, weak) id <GDTNativeExpressProAdViewDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isReady;
@property (nonatomic, assign, readonly) BOOL isVideoAd;
@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic) CGRect  bounds;
- (void)render;
- (CGFloat)videoDuration;
- (CGFloat)videoPlayTime;
- (NSInteger)eCPM;
- (NSString *)eCPMLevel;
@end

@protocol GDTNativeExpressProAdViewDelegate <NSObject>
- (void)gdt_NativeExpressProAdViewRenderSuccess:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView;
- (void)gdt_NativeExpressProAdViewRenderFail:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView;
- (void)gdt_NativeExpressProAdViewExposure:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView;
- (void)gdt_NativeExpressProAdViewClicked:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView;
- (void)gdt_NativeExpressProAdViewClosed:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView;
- (void)gdt_NativeExpressProAdViewWillPresentScreen:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView;
- (void)gdt_NativeExpressProAdViewDidPresentScreen:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView;
- (void)gdt_NativeExpressProAdViewWillDissmissScreen:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView;
- (void)gdt_NativeExpressProAdViewDidDissmissScreen:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView;
- (void)gdt_NativeExpressProAdViewApplicationWillEnterBackground:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView;
- (void)gdt_NativeExpressProAdView:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView playerStatusChanged:(GDTMediaPlayerStatus)status;
- (void)gdt_NativeExpressProAdViewVideoDidFinished:(id<ATGDTNativeExpressProAdView>)nativeExpressProAdView;
@end

@protocol ATGDTNativeExpressProAdManager;
@protocol GDTNativeExpressProAdManagerDelegate <NSObject>
- (void)gdt_nativeExpressProAdSuccessToLoad:(id<ATGDTNativeExpressProAdManager>)adManager views:(NSArray<__kindof id<ATGDTNativeExpressProAdView>> *)views;
- (void)gdt_nativeExpressProAdFailToLoad:(id<ATGDTNativeExpressProAdManager>)adManager error:(NSError *)error;
@end

@protocol ATGDTNativeExpressProAdManager <NSObject>
@property (nonatomic, weak) id<GDTNativeExpressProAdManagerDelegate> delegate;
@property (nonatomic, readonly) NSString *placementId;
@property (nonatomic, strong, readonly) id<ATGDTAdParams> adParams;
- (instancetype)initWithPlacementId:(NSString *)placementId adPrams:(id<ATGDTAdParams>)adParams;
- (void)loadAd:(NSInteger)count;
@end

//
//  ATInmobiBannerAdapter.h
//  AnyThinkInmobiBannerAdapter
//
//  Created by Martin Lau on 2018/10/8.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATInmobiBannerAdapter : NSObject
@end

@protocol ATIMBannerPreloadManager<NSObject>

/**
 * Preloads a Banner ad and returns the following callback.
 *       Meta Information will be recieved from the callback banner:didReceiveWithMetaInfo
 *       Failure of Preload will be recieved from the callback banner:didFailToReceiveWithError
 */
-(void)preload;
/**
 * Loads a Preloaded Banner ad.
 */
-(void)load;

@end

@protocol IMBannerDelegate;
@protocol ATIMBanner<NSObject>
@property (nonatomic, weak) id<IMBannerDelegate> delegate;
@property (nonatomic) NSInteger refreshInterval;
@property (nonatomic, strong) NSString* keywords;
@property (nonatomic, strong) NSDictionary* extras;
@property (nonatomic) long long placementId;
@property (nonatomic, copy) NSString *unitID;
@property (nonatomic) UIViewAnimationTransition transitionAnimation;
@property (nonatomic, strong, readonly) id<ATIMBannerPreloadManager> preloadManager;
@property (nonatomic, strong, readonly) NSString* creativeId;
-(instancetype)initWithFrame:(CGRect)frame placementId:(long long)placementId;
-(instancetype)initWithFrame:(CGRect)frame placementId:(long long)placementId delegate:(id<IMBannerDelegate>)delegate;
-(void)load;
-(void)shouldAutoRefresh:(BOOL)refresh;
-(void)setRefreshInterval:(NSInteger)interval;
- (NSDictionary *)getAdMetaInfo;
@end

@protocol IMBannerDelegate <NSObject>
@end

NS_ASSUME_NONNULL_END

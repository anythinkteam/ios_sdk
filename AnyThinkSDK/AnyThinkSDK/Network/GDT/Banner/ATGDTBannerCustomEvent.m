//
//  ATGDTBannerCustomEvent.m
//  AnyThinkGDTBannerAdapter
//
//  Created by Martin Lau on 20/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATGDTBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"
#import "AnyThinkBanner.h"
#import "ATPlacementModel.h"
#import "ATBannerView.h"
#import "ATBannerView+Internal.h"

@interface ATGDTBannerCustomEvent()
@property(nonatomic, readonly) BOOL loaded;
@end
@implementation ATGDTBannerCustomEvent
- (void)bannerViewMemoryWarning {
    [ATLogger logMessage:@"GDTBanner::bannerViewMemoryWarning" type:ATLogTypeExternal];
}

- (void)bannerViewDidReceived {
    [ATLogger logMessage:@"GDTBanner::bannerViewDidReceived" type:ATLogTypeExternal];
    if (!_loaded) {
        _loaded = YES;
        [self trackBannerAdLoaded:_gdtBannerView adExtra:nil];
    }
}

- (void)bannerViewFailToReceived:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"GDTBanner::bannerViewFailToReceived:%@", error] type:ATLogTypeExternal];
    [self trackBannerAdLoadFailed:error];
}

- (void)bannerViewWillLeaveApplication {
    [ATLogger logMessage:@"GDTBanner::bannerViewWillLeaveApplication" type:ATLogTypeExternal];
}

- (void)bannerViewWillClose {
    [ATLogger logMessage:@"GDTBanner::bannerViewWillClose" type:ATLogTypeExternal];
    [self.bannerView removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(bannerView:didCloseWithPlacementID:extra:)]) {
        [self.delegate bannerView:self.bannerView didCloseWithPlacementID:self.banner.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)bannerViewWillExposure {
    [ATLogger logMessage:@"GDTBanner::bannerViewWillExposure" type:ATLogTypeExternal];
    [self trackBannerAdImpression];
}

- (void)bannerViewClicked {
    [ATLogger logMessage:@"GDTBanner::bannerViewClicked" type:ATLogTypeExternal];
    [self trackBannerAdClick];
}

- (void)bannerViewWillPresentFullScreenModal {
    [ATLogger logMessage:@"GDTBanner::bannerViewWillPresentFullScreenModal" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerPresentModalViewControllerNotification object:nil userInfo:userInfo];
}

- (void)bannerViewDidPresentFullScreenModal {
    [ATLogger logMessage:@"GDTBanner::bannerViewDidPresentFullScreenModal" type:ATLogTypeExternal];
}

- (void)bannerViewWillDismissFullScreenModal {
    [ATLogger logMessage:@"GDTBanner::bannerViewWillDismissFullScreenModal" type:ATLogTypeExternal];
}

- (void)bannerViewDidDismissFullScreenModal {
    [ATLogger logMessage:@"GDTBanner::bannerViewDidDismissFullScreenModal" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerDismissModalViewControllerNotification object:nil userInfo:userInfo];
}

#pragma mark -
-(void) cleanup {
    [super cleanup];
    _gdtBannerView.delegate = nil;
}

#pragma mark - banner 2.0 delegate(s)
- (void)unifiedBannerViewDidLoad:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewDidLoad:" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:unifiedBannerView, kBannerAssetsBannerViewKey, self, kBannerAssetsCustomEventKey, nil];
    if ([self.unitID length] > 0) { assets[kBannerAssetsUnitIDKey] = self.unitID; }
    [self handleAssets:assets];
}

- (void)unifiedBannerViewFailedToLoad:(id<GDTUnifiedBannerView>)unifiedBannerView error:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"GDTBanner::unifiedBannerViewFailedToLoad:error:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)unifiedBannerViewWillExpose:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewWillExpose:" type:ATLogTypeExternal];
    [self trackBannerAdImpression];
}

- (void)unifiedBannerViewClicked:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewClicked:" type:ATLogTypeExternal];
    [self trackBannerAdClick];
}

- (void)unifiedBannerViewWillPresentFullScreenModal:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewWillPresentFullScreenModal:" type:ATLogTypeExternal];
}

- (void)unifiedBannerViewDidPresentFullScreenModal:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewDidPresentFullScreenModal:" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerPresentModalViewControllerNotification object:nil userInfo:userInfo];
}

- (void)unifiedBannerViewWillDismissFullScreenModal:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewWillDismissFullScreenModal:" type:ATLogTypeExternal];
}

- (void)unifiedBannerViewDidDismissFullScreenModal:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewDidDismissFullScreenModal:" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerDismissModalViewControllerNotification object:nil userInfo:userInfo];
}

- (void)unifiedBannerViewWillLeaveApplication:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewWillLeaveApplication:" type:ATLogTypeExternal];
}

- (void)unifiedBannerViewWillClose:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewWillClose:" type:ATLogTypeExternal];
    [self.bannerView loadNextWithoutRefresh];
//    if ([self.delegate respondsToSelector:@selector(bannerView:didTapCloseButtonWithPlacementID:extra:)]) {
//        [self.delegate bannerView:self.bannerView didTapCloseButtonWithPlacementID:self.banner.placementModel.placementID extra:[self delegateExtra]];
//    }
    [self trackBannerAdClosed];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"unit_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.banner.unitGroup.content[@"unit_id"];
//    return extra;
//}

@end

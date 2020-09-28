//
//  ATAdmobBannerAdapter.m
//  AnyThinkAdmobBannerAdapter
//
//  Created by Martin Lau on 18/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdmobBannerAdapter.h"
#import "ATAdmobBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "ATBannerManager.h"
#import "ATAdManager+Banner.h"
#import <objc/runtime.h>
#import "Utilities.h"
#import "ATAppSettingManager.h"

@interface ATAdmobBannerAdapter()
@property(nonatomic, readonly) ATAdmobBannerCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATGADBannerView> bannerView;
@end
@implementation ATAdmobBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[ATAPI sharedInstance] setVersion:[[NSClassFromString(@"GADMobileAds") sharedInstance] sdkVersion] forNetwork:kNetworkNameAdmob];
                if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameAdmob]) {
                    [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameAdmob];
                    id<ATPACConsentInformation> consentInfo = [NSClassFromString(@"PACConsentInformation") sharedInstance];
                    if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameAdmob]) {
                        consentInfo.consentStatus = [[ATAPI sharedInstance].networkConsentInfo[kNetworkNameAdmob][kAdmobConsentStatusKey] integerValue];
                        consentInfo.tagForUnderAgeOfConsent = [[ATAPI sharedInstance].networkConsentInfo[kNetworkNameAdmob][kAdmobUnderAgeKey] boolValue];
                    } else {
                        BOOL set = NO;
                        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                        BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                        if (set) { consentInfo.consentStatus = limit ? ATPACConsentStatusNonPersonalized : ATPACConsentStatusPersonalized; }
                    }
                }
            });
        });
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"GADBannerView") != nil && NSClassFromString(@"GADRequest") != nil) {
        _customEvent = [[ATAdmobBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        CGSize unitGroupSize = ((ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey]).adSize;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (localInfo[kATAdLoadingExtraAdmobBannerSizeKey] != nil && localInfo[kATAdLoadingExtraAdmobAdSizeFlagsKey] != nil) {
                CGSize size = [localInfo[kATAdLoadingExtraAdmobBannerSizeKey] respondsToSelector:@selector(CGSizeValue)] ? [localInfo[kATAdLoadingExtraAdmobBannerSizeKey] CGSizeValue] : CGSizeMake(unitGroupSize.width, unitGroupSize.height);
                NSInteger flags = [localInfo[kATAdLoadingExtraAdmobAdSizeFlagsKey] integerValue];

                self->_customEvent.admobAdSizeValue = localInfo[kATAdLoadingExtraAdmobBannerSizeKey];
                self->_customEvent.admobAdSizeFlags = [localInfo[kATAdLoadingExtraAdmobAdSizeFlagsKey] integerValue];
                self->_bannerView = [[NSClassFromString(@"GADBannerView") alloc] init];
                self->_bannerView.adSize = (GADAdSize){size, flags};
            }else {
                self->_bannerView = [[NSClassFromString(@"GADBannerView") alloc] initWithAdSize:(GADAdSize){CGSizeMake(unitGroupSize.width, unitGroupSize.height), 0}];
            }
            
            self->_bannerView.adUnitID = serverInfo[@"unit_id"];
            self->_bannerView.delegate = self->_customEvent;
            self->_bannerView.adSizeDelegate = self->_customEvent;
            self->_bannerView.rootViewController = [ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]];
            [self->_bannerView loadRequest:[NSClassFromString(@"GADRequest") request]];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Admob"]}]);
    }
}
@end

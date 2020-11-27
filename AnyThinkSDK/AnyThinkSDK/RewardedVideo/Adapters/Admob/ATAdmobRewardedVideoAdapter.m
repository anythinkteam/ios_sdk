//
//  ATAdmobRewardedVideoAdapter.m
//  AnyThinkAdmobRewardedVideoAdapter
//
//  Created by Martin Lau on 07/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdmobRewardedVideoAdapter.h"
#import "ATAdmobRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import <objc/runtime.h>
#import "Utilities.h"
#import "ATAdManager+RewardedVideo.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAdCustomEvent.h"
#import "ATAppSettingManager.h"
NSString *const kAdmobRVAssetsCustomEventKey = @"admob_rewarded_video_custom_object";
@interface ATAdmobRewardedVideoAdapter()
@property(nonatomic, readonly) ATAdmobRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATGADRewardedAd> rewardedAd;
@end

static NSString *const kUnitIDKey = @"unit_id";
@implementation ATAdmobRewardedVideoAdapter
//+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
//    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kUnitIDKey]} unitGroup:unitGroup finalWaterfall:finalWaterfall];
//}

+(BOOL) adReadyWithCustomObject:(id<ATGADRewardedAd>)customObject info:(NSDictionary*)info {
    return customObject.isReady;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATAdmobRewardedVideoCustomEvent *customEvent = (ATAdmobRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    [((id<ATGADRewardedAd>)rewardedVideo.customObject) presentFromRootViewController:viewController delegate:customEvent];
}

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
                        if (set) {
                            consentInfo.consentStatus = limit ? ATPACConsentStatusNonPersonalized : ATPACConsentStatusPersonalized;
                        }
                    }
                }
            });//End of configure consent status
        });
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"GADRequest") != nil && NSClassFromString(@"GADRewardedAd") != nil) {
        _customEvent = [[ATAdmobRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestNumber = [serverInfo[@"request_num"] integerValue];
        _customEvent.requestCompletionBlock = completion;
        _rewardedAd = [[NSClassFromString(@"GADRewardedAd") alloc] initWithAdUnitID:serverInfo[@"unit_id"]];
        
        id<ATGADServerSideVerificationOptions> options = [[NSClassFromString(@"GADServerSideVerificationOptions") alloc] init];
        if (localInfo[kATAdLoadingExtraUserIDKey] != nil) {
            options.userIdentifier = localInfo[kATAdLoadingExtraUserIDKey];
        }
        if (localInfo[kATAdLoadingExtraMediaExtraKey] != nil) {
            options.customRewardString = localInfo[kATAdLoadingExtraMediaExtraKey];
        }
        _rewardedAd.serverSideVerificationOptions = options;
        __weak typeof(self) weakSelf = self;
        [_rewardedAd loadRequest:(id<ATGADRequest>)[NSClassFromString(@"GADRequest") request] completionHandler:^(NSError * _Nullable error) {
            if (error == nil) {
                [weakSelf.customEvent trackRewardedVideoAdLoaded:weakSelf.rewardedAd adExtra:nil];
            } else {
                [weakSelf.customEvent trackRewardedVideoAdLoadFailed:error];
            }
        }];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Admob"]}]);
    }
}
@end

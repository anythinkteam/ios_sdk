//
//  ATAppnextRewardedVideoAdapter.m
//  AnyThinkAppnextRewardedVideoAdapter
//
//  Created by Martin Lau on 2018/10/17.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAppnextRewardedVideoAdapter.h"
#import "ATAppnextRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import <objc/runtime.h>
#import "ATAdManager+RewardedVideo.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAppnextBaseManager.h"

@interface ATAppnextRewardedVideoAdapter()
@property(nonatomic, readonly) ATAppnextRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATAppnextRewardedVideoAd> rewardedVideo;
@end
@implementation ATAppnextRewardedVideoAdapter

+(BOOL) adReadyWithCustomObject:(id<ATAppnextAd>)customObject info:(NSDictionary*)info {
    return customObject.adIsLoaded;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATAppnextRewardedVideoCustomEvent *customEvent = (ATAppnextRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.rewardedVideo = rewardedVideo;
    customEvent.delegate = delegate;
    [rewardedVideo.customObject showAd];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATAppnextBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"AppnextRewardedVideoAd") != nil) {
        _customEvent = [[ATAppnextRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        
        _rewardedVideo = [[NSClassFromString(@"AppnextRewardedVideoAd") alloc] initWithPlacementID:serverInfo[@"placement_id"]];
        _rewardedVideo.delegate = _customEvent;
        if (localInfo[kATAdLoadingExtraUserIDKey] != nil) {
            id<ATAppnextRewardedServerSidePostbackParams> serverPostbackParams = [[NSClassFromString(@"AppnextRewardedServerSidePostbackParams") alloc] init];
            serverPostbackParams.rewardsUserId = localInfo[kATAdLoadingExtraUserIDKey];
            [_rewardedVideo setRewardedServerSidePostbackParams:serverPostbackParams];
        }
        if ([[[ATAdManager sharedManager] extraInfoForPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]] containsObjectForKey:kATAdLoadingExtraUserIDKey]) {
            [_rewardedVideo setRewardsUserId:[[ATAdManager sharedManager] extraInfoForPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]][kATAdLoadingExtraUserIDKey]];
        }
        
        [_rewardedVideo loadAd];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Appnext"]}]);
    }
}
@end

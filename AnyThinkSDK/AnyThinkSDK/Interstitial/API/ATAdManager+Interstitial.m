//
//  ATAdManager+Interstitial.m
//  AnyThinkInterstitial
//
//  Created by Martin Lau on 21/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdManager+Interstitial.h"
#import "ATInterstitialManager.h"
#import "ATAdManager+Internal.h"
#import "ATInterstitial.h"
#import "ATUnitGroupModel.h"
#import "ATInterstitialAdapter.h"
#import "ATLogger.h"
#import "UIViewController+AdObjectAssociation.h"
#import "Utilities.h"
#import "ATGeneralAdAgentEvent.h"
#import "ATPlacementSettingManager.h"
#import "ATAgentEvent.h"
#import "ATCapsManager.h"
#import "ATInterstitialCustomEvent.h"
NSString *const kATInterstitialDelegateExtraNetworkIDKey = @"network_firm_id";
NSString *const kATInterstitialDelegateExtraAdSourceIDKey = @"adsource_id";
NSString *const kATInterstitialDelegateExtraIsHeaderBidding = @"adsource_isHeaderBidding";
NSString *const kATInterstitialDelegateExtraPrice = @"adsource_price";
NSString *const kATInterstitialDelegateExtraPriority = @"adsource_index";

NSString *const kATInterstitialExtraMediationNameKey = @"mediation_name";
NSString *const kATInterstitialExtraUserIDKey = @"user_id";
NSString *const kATInterstitialExtraUserFeatureKey = @"user_feature";
NSString *const kATInterstitialExtraLocationEnabledFlagKey = @"location_enabled_flag";
NSString *const kATInterstitialExtraMuteStartPlayingFlagKey = @"mute_start_playing_flag";
NSString *const kATInterstitialExtraFallbackFullboardBackgroundColorKey = @"fallback_fullboard_background_color";
NSString *const kATInterstitialExtraAdSizeKey = @"ad_size";
NSString *const kATInterstitialExtraUsesRewardedVideo = @"uses_rewarded_video_flag";

NSString *const kATInterstitialExtraAdSize600_400 = @"600_400";
NSString *const kATInterstitialExtraAdSize600_600 = @"600_600";
NSString *const kATInterstitialExtraAdSize600_900 = @"600_900";
@implementation ATAdManager (Interstitial)
-(BOOL) interstitialReadyForPlacementID:(NSString*)placementID {
    return [self interstitialReadyForPlacementID:placementID sendTK:YES];
}

-(BOOL) interstitialReadyForPlacementID:(NSString*)placementID sendTK:(BOOL)send {
    BOOL ready = [self interstitialReadyForPlacementID:placementID scene:nil caller:ATAdManagerReadyAPICallerReady interstitial:nil sendTK:send];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[ATGeneralAdAgentEvent apiLogInfoWithPlacementID:placementID format:ATAdFormatInterstitial api:kATAPIIsReady]];
    info[@"result"] = ready ? @"YES" : @"NO";
    [ATLogger logMessage:[NSString stringWithFormat:@"\nAPI invocation info:\n*****************************\n%@ \n*****************************", info] type:ATLogTypeTemporary];
    return ready;
}

-(BOOL) interstitialReadyForPlacementID:(NSString*)placementID scene:(NSString*)scene caller:(ATAdManagerReadyAPICaller)caller interstitial:(ATInterstitial* __strong*)interstitial sendTK:(BOOL)send {
    return [[ATAdManager sharedManager] adReadyForPlacementID:placementID scene:scene caller:caller sendTK:send context:^BOOL(NSDictionary *__autoreleasing *extra) {
        
        ATInterstitial *localInterstitial = [[ATInterstitialManager sharedManager] interstitialForPlacementID:placementID invalidateStatus:caller == ATAdManagerReadyAPICallerShow extra:extra];
        if (interstitial != nil) { *interstitial = localInterstitial; }
        return localInterstitial != nil;
    }];
}

- (ATCheckLoadModel*)checkInterstitialLoadStatusForPlacementID:(NSString *)placementID {
    ATInterstitial *interstitial = nil;
    ATCheckLoadModel *checkLoadModel = [[ATCheckLoadModel alloc] init];
    if ([[ATWaterfallManager sharedManager] loadingAdForPlacementID:placementID]) {
        checkLoadModel.isLoading = YES;
    }
    if ([self interstitialReadyForPlacementID:placementID scene:nil caller:ATAdManagerReadyAPICallerReady interstitial:&interstitial sendTK:YES]) {
        checkLoadModel.isReady = YES;
        NSMutableDictionary *delegateExtra = [NSMutableDictionary dictionaryWithDictionary:[interstitial.customEvent delegateExtra]];
        if ([delegateExtra containsObjectForKey:kATADDelegateExtraIDKey]) { [delegateExtra removeObjectForKey:kATADDelegateExtraIDKey]; }
        checkLoadModel.adOfferInfo = delegateExtra;
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[ATGeneralAdAgentEvent apiLogInfoWithPlacementID:placementID format:ATAdFormatInterstitial api:kATAPICheckLoadStatus]];
    info[@"result"] = @{@"isLoading":checkLoadModel.isLoading ? @"YES" : @"NO", @"isReady":checkLoadModel.isReady ? @"YES" : @"NO", @"adOfferInfo":![Utilities isBlankDictionary:checkLoadModel.adOfferInfo] ? checkLoadModel.adOfferInfo : @{}};
    [ATLogger logMessage:[NSString stringWithFormat:@"\nAPI invocation info:\n*****************************\n%@ \n*****************************", info] type:ATLogTypeTemporary];
    return checkLoadModel;
}

-(void) showInterstitialWithPlacementID:(NSString*)placementID scene:(NSString*)scene inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    [ATLogger logMessage:[NSString stringWithFormat:@"\nAPI invocation info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent apiLogInfoWithPlacementID:placementID format:3 api:kATAPIShow]] type:ATLogTypeTemporary];
    NSString *showingScene = nil;
    if ([Utilities validateShowingScene:scene]) {
        showingScene = scene;
    } else {
        NSLog(@"Invalid scene is passed:%@, scene should be a string of 14 characters from '_', [0-9], [a-z], [A-Z]", scene);
    }
    NSError *error = nil;
    ATInterstitial *interstitial = nil;
    if ([self interstitialReadyForPlacementID:placementID scene:showingScene caller:ATAdManagerReadyAPICallerShow interstitial:&interstitial sendTK:YES]) {
        interstitial.scene = showingScene;
        viewController.ad = interstitial;
        [interstitial.customEvent saveShowAPIContext];
        [interstitial.unitGroup.adapterClass showInterstitial:interstitial inViewController:viewController delegate:delegate];
        interstitial.showTimes++;
        [[ATCapsManager sharedManager] setShowFlagForPlacementID:placementID requestID:interstitial.requestID];
        [[ATPlacementSettingManager sharedManager] setStatus:NO forPlacementID:placementID];
    } else {
        error = [NSError errorWithDomain:ATADShowingErrorDomain code:100001 userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to show interstitial ad", NSLocalizedFailureReasonErrorKey:@"Interstitial's not ready for the placement"}];
    }
    if (error != nil) {
        if ([delegate respondsToSelector:@selector(interstitialFailedToShowForPlacementID:error:extra:)]) {
            [delegate interstitialFailedToShowForPlacementID:placementID error:error extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:interstitial.unitGroup.unitID != nil ? interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(interstitial.priority),kATInterstitialDelegateExtraPrice:interstitial != nil ? (interstitial.unitGroup.headerBidding ? @([interstitial.unitGroup.bidPrice doubleValue]):@([interstitial.unitGroup.price doubleValue])) : @(0)}];
        }
    }
}

-(void) showInterstitialWithPlacementID:(NSString*)placementID inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    [self showInterstitialWithPlacementID:placementID scene:nil inViewController:viewController delegate:delegate];
}
@end

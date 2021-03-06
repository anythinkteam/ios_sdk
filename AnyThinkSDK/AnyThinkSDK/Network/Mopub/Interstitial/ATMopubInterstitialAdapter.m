//
//  ATMopubInterstitialAdapter.m
//  AnyThinkMopubInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMopubInterstitialAdapter.h"
#import "ATMopubInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "ATAdAdapter.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import "ATAppSettingManager.h"
#import "ATMopubBaseManager.h"

@interface ATMopubInterstitialAdapter()
@property(nonatomic) ATMopubInterstitialCustomEvent *customEvent;
@property(nonatomic) id<ATMPInterstitialAdController> interstitial;
@end

static NSString *const kUnitIDKey = @"unitid";
@implementation ATMopubInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id<ATMPInterstitialAdController>)customObject info:(NSDictionary*)info {
    return customObject.ready;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    dispatch_async(dispatch_get_main_queue(), ^{
        [((id<ATMPInterstitialAdController>)(interstitial.customObject)) showFromViewController:viewController];
    });
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATMopubBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
     if (NSClassFromString(@"MPInterstitialAdController")) {
        _customEvent = (ATMopubInterstitialCustomEvent*)[[ATInterstitialManager sharedManager] interstitialWithPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID unitGroupID:((ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey]).unitGroupID].customEvent;
         id<ATMoPub> mopub = [NSClassFromString(@"MoPub") sharedInstance];

         __weak typeof(self) weakSelf = self;
         void(^Load)(void) = ^{
             weakSelf.customEvent = [[ATMopubInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
             weakSelf.customEvent.requestCompletionBlock = completion;
             weakSelf.interstitial = [NSClassFromString(@"MPInterstitialAdController") interstitialAdControllerForAdUnitId:serverInfo[kUnitIDKey]];
             weakSelf.interstitial.delegate = self->_customEvent;
             dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf.interstitial loadAd];
             });
         };
         if(![ATAPI getMPisInit]){
             [ATAPI setMPisInit:YES];
             [mopub initializeSdkWithConfiguration:[[NSClassFromString(@"MPMoPubConfiguration") alloc] initWithAdUnitIdForAppInitialization:serverInfo[kUnitIDKey]] completion:^{
                 Load();
             }];
         }else{
              Load();
         }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mopub"]}]);
    }
}
@end

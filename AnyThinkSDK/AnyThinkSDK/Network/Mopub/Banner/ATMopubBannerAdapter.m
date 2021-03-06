//
//  ATMopubBannerAdapter.m
//  AnyThinkMopubBannerAdapter
//
//  Created by Martin Lau on 30/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMopubBannerAdapter.h"
#import "ATMopubBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
#import "ATMopubBaseManager.h"

@interface ATMopubBannerAdapter()
@property(nonatomic) id<ATMPAdView> adView;
@property(nonatomic, readonly) ATMopubBannerCustomEvent *customEvent;
@end
@implementation ATMopubBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATMopubBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"MPAdView") != nil) {
        _customEvent = [[ATMopubBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_customEvent.rootViewController = [ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]];
        });
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
        id<ATMoPub> mopub = [NSClassFromString(@"MoPub") sharedInstance];
        __weak typeof(self) weakSelf = self;
        void(^Load)(void) = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.adView = [[NSClassFromString(@"MPAdView") alloc] initWithAdUnitId:serverInfo[@"unitid"] size:CGSizeMake(unitGroupModel.adSize.width, unitGroupModel.adSize.height)];
                weakSelf.adView.delegate = self->_customEvent;
                weakSelf.adView.frame = CGRectMake(.0f, .0f, unitGroupModel.adSize.width, unitGroupModel.adSize.height);
                if ([serverInfo[@"nw_rft"] integerValue] == 0) { [weakSelf.adView stopAutomaticallyRefreshingContents]; }
                [weakSelf.adView loadAd];
            });
        };
        if(![ATAPI getMPisInit]){
            [ATAPI setMPisInit:YES];
            [mopub initializeSdkWithConfiguration:[[NSClassFromString(@"MPMoPubConfiguration") alloc] initWithAdUnitIdForAppInitialization:serverInfo[@"unitid"]] completion:^{
                Load();
            }];
        }else{
             Load();
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mopub"]}]);
    }
}
@end

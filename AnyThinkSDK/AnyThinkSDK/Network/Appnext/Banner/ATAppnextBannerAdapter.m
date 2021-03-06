//
//  ATAppnextBannerAdapter.m
//  AnyThinkAppnextBannerAdapter
//
//  Created by Martin Lau on 2018/10/15.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAppnextBannerAdapter.h"
#import "ATAppnextBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppnextBaseManager.h"

@interface ATAppnextBannerAdapter()
@property(nonatomic, readonly) ATAppnextBannerCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATAppnextBannerView> bannerView;
@end
@implementation ATAppnextBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATAppnextBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

NSInteger bannerType(CGSize size) {
    return [@{NSStringFromCGSize(CGSizeMake(320.0f, 50.0f)):@0, NSStringFromCGSize(CGSizeMake(320.0f, 100.0f)):@1, NSStringFromCGSize(CGSizeMake(300.0f, 250.0f)):@2}[NSStringFromCGSize(size)] integerValue];
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"BannerRequest") != nil && NSClassFromString(@"AppnextBannerView") != nil) {
        _customEvent = [[ATAppnextBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
        id<ATBannerRequest> request = [[NSClassFromString(@"BannerRequest") alloc] init];
        request.bannerType = bannerType(unitGroupModel.adSize);
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_bannerView = [[NSClassFromString(@"AppnextBannerView") alloc] initBannerWithPlacementID:serverInfo[@"placement_id"]];
//            self->_bannerView = [[NSClassFromString(@"AppnextBannerView") alloc] initBannerWithPlacementID:info[@"placement_id"] withBannerRequest:request];

            self->_bannerView.frame = CGRectMake(.0f, .0f, unitGroupModel.adSize.width, unitGroupModel.adSize.height);
            self->_bannerView.delegate = self->_customEvent;
            self->_customEvent.anBannerView = self->_bannerView;
            [self->_bannerView loadAd:request];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Appnext"]}]);
    }
}
@end

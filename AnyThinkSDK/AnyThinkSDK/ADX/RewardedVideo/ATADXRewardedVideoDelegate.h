//
//  ATADXRewardedVideoDelegate.h
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#ifndef ATADXRewardedVideoDelegate_h
#define ATADXRewardedVideoDelegate_h
@class ATADXOfferModel;
@protocol ATADXRewardedVideoDelegate<NSObject>
-(void) didRewardedVideoFailToShowOffer:(ATADXOfferModel*)offer error:(NSError*)error;
-(void) didRewardedVideoShowOffer:(ATADXOfferModel*)offer;
-(void) didRewardedVideoVideoStartOffer:(ATADXOfferModel*)offer;
-(void) didRewardedVideoVideoEndOffer:(ATADXOfferModel*)offer;
-(void) didRewardedVideoClickOffer:(ATADXOfferModel*)offer;
-(void) didRewardedVideoCloseOffer:(ATADXOfferModel*)offer;
-(void) didRewardedVideoRewardOffer:(ATADXOfferModel*)offer;
-(void) didRewardedVideoDeepLinkOrJumpResult:(BOOL)success offer:(ATADXOfferModel *)offer;
- (void)didRewardedVideoFeedbackViewSelectItemAtIndex:(NSInteger)index extraMsg:(NSString *)msg offer:(ATADXOfferModel *)offer;

-(NSString*) lifeCircleIDForOffer:(ATADXOfferModel*)offer;
-(NSString*) sceneForOffer:(ATADXOfferModel*)offer;
@end

#endif /* ATADXRewardedVideoDelegate_h */

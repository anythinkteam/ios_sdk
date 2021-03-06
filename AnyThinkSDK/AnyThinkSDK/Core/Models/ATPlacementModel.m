//
//  ATPlacementModel.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 11/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATPlacementModel.h"
#import "NSData+KAKit.h"

NSString *const kPlacementModelCacheDateKey = @"placement_cache_date";
NSString *const kPlacementModelCustomDataKey = @"custom_data";

@implementation ATPlatfromInfo

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _token = dictionary[@"token"];
        _dataType = [dictionary[@"rtye"] integerValue];
    }
    return self;
}

@end

@interface ATPlacementModel()

/** platforms */
@property(nonatomic, strong) NSMutableDictionary *platforms;
@end

@implementation ATPlacementModel
-(instancetype) initWithDictionary:(NSDictionary *)dictionary associatedCustomData:(NSDictionary*)customData placementID:(NSString*)placementID {
    self = [super initWithDictionary:dictionary];
    if (self != nil) {
        _placementID = placementID;
        _platforms = [NSMutableDictionary new];
        
        if ([customData isKindOfClass:[NSDictionary class]]) {
            _associatedCustomData = [NSDictionary dictionaryWithDictionary:customData];
        } else {
            if ([dictionary[kPlacementModelCustomDataKey] isKindOfClass:[NSDictionary class]]) { _associatedCustomData = [NSDictionary dictionaryWithDictionary:dictionary[kPlacementModelCustomDataKey]]; }
        }
        _format = [dictionary[@"format"] integerValue];
        _adDeliverySwitch = [dictionary[@"ad_delivery_sw"] boolValue];
        _groupID = [dictionary[@"gro_id"] integerValue];
        _refresh = [dictionary[@"refresh"] boolValue];
        _autoRefresh = [dictionary[@"auto_refresh"] boolValue];
        _autoRefreshInterval = [dictionary[@"auto_refresh_time"] doubleValue] / 1000.0f;
        _maxConcurrentRequestCount = [dictionary[@"req_ug_num"] integerValue];
        _psID = dictionary[@"ps_id"];
        _sessionID = dictionary[@"session_id"];
        _showType = [dictionary[@"show_type"] integerValue] < 2 ? [dictionary[@"show_type"] integerValue] : 0;
        _unitCapsByDay = [dictionary[@"unit_caps_d"] integerValue] == -1 ? NSIntegerMax : [dictionary[@"unit_caps_d"] integerValue];
        _unitCapsByHour = [dictionary[@"unit_caps_h"] integerValue] == -1 ? NSIntegerMax : [dictionary[@"unit_caps_h"] integerValue];
        _unitPacing = [dictionary[@"unit_pacing"] doubleValue];
        _wifiAutoSwitch = [dictionary[@"wifi_auto_sw"] boolValue];
        _offerLoadingTimeout = [dictionary[@"s_t"] doubleValue] / 1000.0f;
        _statusValidDuration = [dictionary[@"l_s_t"] doubleValue];
        _asid = dictionary[@"asid"];
        _trafficGroupID = dictionary[@"t_g_id"];
        _usesDefaultMyOffer = [dictionary[@"u_n_f_sw"] integerValue];
        _autoloadingEnabled = [dictionary[@"ra"] boolValue];
        
        [self generateIrld:dictionary];
        if ([dictionary[@"tp_ps"] isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *tppsDict = [NSMutableDictionary dictionaryWithDictionary:dictionary[@"tp_ps"]];
            tppsDict[@"pucs"] = dictionary[@"pucs"];
            _extra = [[ATPlacementModelExtra alloc] initWithDictionary:tppsDict];
        }
        _updateTolerateInterval = [dictionary[@"ps_ct_out"] doubleValue] / 1000.0f;
        _cacheValidDuration = [dictionary[@"ps_ct"] doubleValue] / 1000.0f;
        _cacheDate = dictionary[kPlacementModelCacheDateKey];
        _cachesPlacementSetting = [dictionary[@"pucs"] boolValue];
        _loadFailureInterval = [dictionary[@"load_fail_wtime"] doubleValue] / 1000.0f;
        _loadCap = [dictionary[@"load_cap"] integerValue];
        _loadCapDuration = [dictionary[@"load_cap_time"] doubleValue] / 1000.0f;
        _expectedNumberOfOffers = [dictionary[@"cached_offers_num"] integerValue];
        
        //in house list
        NSMutableArray<ATUnitGroupModel*>* inhouseUgs = [NSMutableArray<ATUnitGroupModel*> array];
        NSArray<NSDictionary*>* inhouseList = dictionary[@"inh_list"];
        [inhouseList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *unitGroupDict = [NSMutableDictionary dictionaryWithDictionary:obj];
            unitGroupDict[@"header_bidding"] = @YES;
            [inhouseUgs addObject:[[ATUnitGroupModel alloc] initWithDictionary:unitGroupDict]];
        }];
        _inhouseUnitGroups = inhouseUgs;
        
        NSMutableArray<ATUnitGroupModel*>* unitGroups = [NSMutableArray<ATUnitGroupModel*> array];
        NSArray<NSDictionary*>* unitGroupDicts = dictionary[@"ug_list"];
        [unitGroupDicts enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [unitGroups addObject:[[ATUnitGroupModel alloc] initWithDictionary:obj]];
        }];
        
        NSMutableArray<ATUnitGroupModel*>* onlineApiUnitGroups = [NSMutableArray<ATUnitGroupModel*> array];
        NSArray<NSDictionary*>* onlineApiUnitGroupDicts = dictionary[@"ol_list"];
        [onlineApiUnitGroupDicts enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [unitGroups addObject:[[ATUnitGroupModel alloc] initWithDictionary:obj]];
            [onlineApiUnitGroups addObject:[[ATUnitGroupModel alloc] initWithDictionary:obj]];
        }];
        _unitGroups = unitGroups;
        _olApiUnitGroups = onlineApiUnitGroups;
        
        NSMutableArray<ATUnitGroupModel*>* headerBiddingUnitGroups = [NSMutableArray<ATUnitGroupModel*> array];
        NSArray<NSDictionary*>* headerBiddingUnitGroupDicts = dictionary[@"hb_list"];
        [headerBiddingUnitGroupDicts enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *unitGroupDict = [NSMutableDictionary dictionaryWithDictionary:obj];
            unitGroupDict[@"header_bidding"] = @YES;
            [headerBiddingUnitGroups addObject:[[ATUnitGroupModel alloc] initWithDictionary:unitGroupDict]];
        }];
        _headerBiddingUnitGroups = headerBiddingUnitGroups;
        
        NSMutableArray<ATUnitGroupModel*>* S2SHeaderBiddingUnitGroups = [NSMutableArray<ATUnitGroupModel*> array];
        NSArray<NSDictionary*>* S2SHeaderBiddingUnitGroupDicts = dictionary[@"s2shb_list"];
        [S2SHeaderBiddingUnitGroupDicts enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *unitGroupDict = [NSMutableDictionary dictionaryWithDictionary:obj];
            unitGroupDict[@"header_bidding"] = @YES;
            [S2SHeaderBiddingUnitGroups addObject:[[ATUnitGroupModel alloc] initWithDictionary:unitGroupDict]];
        }];
        //add adx list to s2s list
        NSMutableArray<ATUnitGroupModel*>* adxUnitGroups = [NSMutableArray<ATUnitGroupModel*> array];
        NSArray<NSDictionary*>* adxUnitGroupDicts = dictionary[@"adx_list"];
        [adxUnitGroupDicts enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *unitGroupDict = [NSMutableDictionary dictionaryWithDictionary:obj];
            unitGroupDict[@"header_bidding"] = @YES;
            [adxUnitGroups addObject:[[ATUnitGroupModel alloc] initWithDictionary:unitGroupDict]];
            [S2SHeaderBiddingUnitGroups addObject:[[ATUnitGroupModel alloc] initWithDictionary:unitGroupDict]];
        }];
        _adxUnitGroups = adxUnitGroups;
        
        _S2SHeaderBiddingUnitGroups = S2SHeaderBiddingUnitGroups;
        
        _S2SBidRequestAddress = dictionary[@"addr_bid"];
        _headerBiddingRequestTimeout = [dictionary[@"hb_bid_timeout"] doubleValue] / 1000.0f;
        _headerBiddingRequestTolerateInterval = [dictionary[@"hb_start_time"] doubleValue] / 1000.0f;
        
        _preloadMyOffer = [dictionary[@"p_m_o"] boolValue];
        _myOfferSetting = [[ATMyOfferSetting alloc] initWithDictionary:dictionary[@"m_o_s"] placementID:_placementID];
        NSMutableArray<ATMyOfferOfferModel*>* offers = [NSMutableArray<ATMyOfferOfferModel*> array];
        NSArray<NSDictionary*>* offerDicts = dictionary[@"m_o"];
        //for myoffer tk
        NSDictionary *placeHolders = dictionary[@"m_o_ks"];
        [offerDicts enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ATMyOfferOfferModel *offerModel = [[ATMyOfferOfferModel alloc] initWithDictionary:obj placeholders:placeHolders format:_format setting:_myOfferSetting];
            if (offerModel != nil) { [offers addObject:offerModel]; }
        }];
        _offers = offers;
        _callback = dictionary[@"callback"];
        _FBHBTimeOut = [dictionary[@"fbhb_bid_wtime"] integerValue]/1000;
        _adxSettingDict = dictionary[@"adx_st"];
        _olApiSettingDict = dictionary[@"adx_st"];
        _currency = _callback[@"acct_cy"];
        if (_callback[@"exch_r"]) {
            _exchangeRate = [[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",_callback[@"exch_r"]]] stringValue];
        }
        
        // v5.7.10
        _campaign = @"";
    }
    return self;
}

-(instancetype) initWithDictionary:(NSDictionary *)dictionary placementID:(NSString*)placementID {
    return [self initWithDictionary:dictionary associatedCustomData:nil placementID:placementID];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%@", @{@"placement_id":_placementID != nil ? _placementID : @"", @"unit_group_ids":[_unitGroups mutableArrayValueForKey:@"unitGroupID"] != nil ? [_unitGroups mutableArrayValueForKey:@"unitGroupID"] : @[]}];
}

- (NSArray<ATPlatfromInfo *> *)revenueToPlatforms {
    return self.platforms;
}
/**
 * Using NSClassFromString to walk around the dependency on Native framework.
 */
-(Class) adManagerClass {
    NSMutableDictionary<NSNumber*, Class> *classes = [NSMutableDictionary<NSNumber*, Class> dictionary];
    if (NSClassFromString(@"ATNativeADOfferManager") != nil) classes[@0] = NSClassFromString(@"ATNativeADOfferManager");
    if (NSClassFromString(@"ATRewardedVideoManager") != nil) classes[@1] = NSClassFromString(@"ATRewardedVideoManager");
    if (NSClassFromString(@"ATBannerManager") != nil) classes[@2] = NSClassFromString(@"ATBannerManager");
    if (NSClassFromString(@"ATInterstitialManager") != nil) classes[@3] = NSClassFromString(@"ATInterstitialManager");
    if (NSClassFromString(@"ATSplashManager") != nil) classes[@4] = NSClassFromString(@"ATSplashManager");
    return classes[@(self.format)];
}

- (void)generateIrld:(NSDictionary *)dictionary {
    NSString *platformStr = [dictionary[@"ilrd"] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSData *platformData = [platformStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *platforms = platformData.dictionary;
    if ([platforms isKindOfClass:[NSDictionary class]] == NO) {
        return;
    }
    
    for (NSString *key in [platforms allKeys]) {
               
        ATPlatfromInfo *info = [[ATPlatfromInfo alloc]initWithDictionary:platforms[key]];
        [self.platforms setValue:info forKey:key];
    }
}

// MARK:- methods claimed in .h
- (BOOL)needConvertPrice {
    if (self.currency) {
        return [self.currency isEqualToString:@"USD"] == NO;
    }
    return NO;
}

- (NSString *)convertedPrice:(NSString *)price {
    if (price == nil || price.length == 0 ) {
        return @"0";
    }
    
    if ([self needConvertPrice] == NO || self.exchangeRate == nil) {
        return price;
    }
    NSDecimalNumber *priceDecimal = [NSDecimalNumber decimalNumberWithString:price];
    NSDecimalNumber *rateDecimal = [NSDecimalNumber decimalNumberWithString:self.exchangeRate];
    return [[priceDecimal decimalNumberByMultiplyingBy:rateDecimal] stringValue];
}

@end

@implementation ATPlacementModelExtra
-(instancetype) initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self != nil) {
        _cachesPlacementSetting = [dictionary[@"pucs"] boolValue];
        _defaultAdSourceLoadingDelay = [dictionary[@"apdt"] doubleValue] / 1000.0f;
        _defaultNetworkFirmID = [dictionary[@"aprn"] integerValue];
        _usesServerSettings = [dictionary[@"puas"] boolValue];
        _countdown = [dictionary[@"cdt"] integerValue] / 1000.0f;
        _allowsSkip = [dictionary[@"ski_swt"] boolValue];
        _closeAfterCountdownElapsed = [dictionary[@"aut_swt"] boolValue];
    }
    return self;
}
@end

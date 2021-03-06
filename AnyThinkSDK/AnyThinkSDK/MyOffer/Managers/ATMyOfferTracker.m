//
//  ATMyOfferTracker.m
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/30.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferTracker.h"
#import "ATNetworkingManager.h"
#import "ATThreadSafeAccessor.h"
#import "Utilities.h"
#import "ATMyOfferProgressHud.h"
#import "ATAppSettingManager.h"
#import "ATStoreProductViewController.h"
#import "ATOfferWebViewController.h"
#import "ATAgentEvent.h"
#import "ATOfferSessionRedirector.h"
#import <SafariServices/SFSafariViewController.h>
#import "ATCommonOfferTracker.h"

#pragma mark - tracker
@interface ATMyOfferTracker()<SFSafariViewControllerDelegate>
@property(nonatomic, readonly) NSMutableArray<NSDictionary*>* failedEventStorage;
@property(nonatomic, readonly) ATThreadSafeAccessor *failedEventStorageAccessor;
@property(nonatomic, readonly) NSMutableArray<ATOfferSessionRedirector*> *redirectors;
@property(nonatomic, readonly) ATThreadSafeAccessor *redirectorsAccessor;
@property(nonatomic, readonly) ATThreadSafeAccessor *storekitStorageAccessor;
@property(nonatomic, readonly) NSMutableDictionary *preloadStorekitDict;

@end
static NSString *kFailedEventStorageAddressKey = @"address";
static NSString *kFailedEventStorageParametersKey = @"parameters";
@implementation ATMyOfferTracker
+(instancetype) sharedTracker {
    static ATMyOfferTracker *sharedTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTracker = [[ATMyOfferTracker alloc] init];
    });
    return sharedTracker;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _failedEventStorage = [NSMutableArray<NSDictionary*> array];
        _failedEventStorageAccessor = [ATThreadSafeAccessor new];
        _redirectors = [NSMutableArray<ATOfferSessionRedirector*> array];
        _redirectorsAccessor = [ATThreadSafeAccessor new];
        _storekitStorageAccessor = [ATThreadSafeAccessor new];
        _preloadStorekitDict = [NSMutableDictionary dictionary];
        [self sendArchivedEvents];
    }
    return self;
}

-(void) sendArchivedEvents {
    NSArray<NSDictionary*>* archivedEvents = [NSArray<NSDictionary*> arrayWithContentsOfFile:[ATMyOfferTracker eventArchivePath]];
    [[NSFileManager defaultManager] removeItemAtPath:[ATMyOfferTracker eventArchivePath] error:nil];
    if ([archivedEvents isKindOfClass:[NSArray class]]) {
        [archivedEvents enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSString *address = obj[kFailedEventStorageAddressKey];
                NSDictionary *parameters = obj[kFailedEventStorageParametersKey];
                if ([address isKindOfClass:[NSString class]] && [address length] > 0) {
                    [[ATCommonOfferTracker sharedTracker] sendTKEventWithAddress:address parameters:[parameters isKindOfClass:[NSDictionary class]] ? parameters : nil retry:YES completionHandler:^(BOOL retry){
                        if(retry){
                            [self appendFailedEventWithAddress:address parameters:[parameters isKindOfClass:[NSDictionary class]] ? parameters : nil ];
                        }
                    }];
                }
            }
        }];
    }
}

+(NSString*)eventArchivePath {
    return [[Utilities documentsPath] stringByAppendingPathComponent:@"com.anythink.MyOfferTKEvents"];
}

NSDictionary *ExtractParameterFromURL(NSURL *URL, NSDictionary *extra) {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSArray<NSString*>*queries = [URL.query componentsSeparatedByString:@"&"];
    [queries enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<NSString*>* components = [obj componentsSeparatedByString:@"="];
        if ([components count] == 2) { parameters[components[0]] = components[1]; }
    }];
    parameters[@"t"] = [NSString stringWithFormat:@"%@", [Utilities normalizedTimeStamp]];
    if ([extra[kATOfferTrackerExtraLifeCircleID] isKindOfClass:[NSString class]]) { parameters[@"req_id"] = extra[kATOfferTrackerExtraLifeCircleID]; }
    if ([extra[kATOfferTrackerExtraScene] isKindOfClass:[NSString class]]) { parameters[@"scenario"] = extra[kATOfferTrackerExtraScene]; }
    return parameters;
}

NSString *ExtractAddressFromURL(NSURL *URL) {
    NSString *address = [NSString stringWithFormat:@"%@://%@%@", URL.scheme, URL.host, URL.path];
    return address;
}

NSURL *BuildTKURL(ATMyOfferOfferModel *offerModel, ATMyOfferTrackerEvent event, NSDictionary *extra) {
    NSURL *url = nil;
    __block NSString *tkURLStr = RetrieveTKURL(offerModel, event);
    if ([tkURLStr length] > 0) {
        [offerModel.placeholders enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) { tkURLStr = [tkURLStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", key] withString:obj];
    
        }];
        
        url = [NSURL URLWithString:tkURLStr];
        if ([Utilities isEmpty:url]) {
            url = [NSURL URLWithString:[tkURLStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        }
    }
    return url;
}

NSString* RetrieveTKURL(ATMyOfferOfferModel *offerModel, ATMyOfferTrackerEvent event) {
    return @{@(ATMyOfferTrackerEventVideoStart):offerModel.videoStartTKURL != nil ? offerModel.videoStartTKURL : @"",
             @(ATMyOfferTrackerEventVideo25Percent):offerModel.video25TKURL != nil ? offerModel.video25TKURL : @"",
             @(ATMyOfferTrackerEventVideo50Percent):offerModel.video50TKURL != nil ? offerModel.video50TKURL : @"",
             @(ATMyOfferTrackerEventVideo75Percent):offerModel.video75TKURL != nil ? offerModel.video75TKURL : @"",
             @(ATMyOfferTrackerEventVideoEnd):offerModel.videoEndTKURL != nil ? offerModel.videoEndTKURL : @"",
             @(ATMyOfferTrackerEventImpression):offerModel.impTKURL != nil ? offerModel.impTKURL : @"",
             @(ATMyOfferTrackerEventClick):offerModel.clickTKURL != nil ? offerModel.clickTKURL : @"",
             @(ATMyOfferTrackerEventEndCardShow):offerModel.endCardShowTKURL != nil ? offerModel.endCardShowTKURL : @"",
             @(ATMyOfferTrackerEventEndCardClose):offerModel.endCardCloseTKURL != nil ? offerModel.endCardCloseTKURL : @""
    }[@(event)];
}

-(void) trackEvent:(ATMyOfferTrackerEvent)event offerModel:(ATMyOfferOfferModel*)offerModel extra:(NSDictionary*)extra {
    NSURL *tkURL = BuildTKURL(offerModel, event, extra);
    NSString *address = ExtractAddressFromURL(tkURL);
    NSDictionary *parameters = ExtractParameterFromURL(tkURL, extra);
    if ([address length] > 0) {
        [[ATCommonOfferTracker sharedTracker] sendTKEventWithAddress:address parameters:parameters retry:YES completionHandler:^(BOOL retry){
            if(retry){
                [self appendFailedEventWithAddress:address parameters:parameters ];
            }
        }];
    }
}

-(void) appendFailedEventWithAddress:(NSString*)address parameters:(NSDictionary*)parameters {
    if ([address length] > 0) {
        __weak typeof(self) weakSelf = self;
        [_failedEventStorageAccessor writeWithBlock:^{
            NSMutableDictionary *eventDict = [NSMutableDictionary dictionaryWithObject:address forKey:kFailedEventStorageAddressKey];
            if ([parameters count] > 0) {
                eventDict[kFailedEventStorageParametersKey] = parameters;
            }
            [weakSelf.failedEventStorage addObject:eventDict];
            [weakSelf.failedEventStorage writeToFile:[ATMyOfferTracker eventArchivePath] atomically:YES];
        }];
    }
}

NSString *AppendLifeCircleIDToURL(NSString *URL, NSString *lifeCircleID) {
    return [lifeCircleID isKindOfClass:[NSString class]] ? ([URL stringByReplacingOccurrencesOfString:@"{req_id}" withString:lifeCircleID]) : URL;
}

-(void) impressionOfferWithOfferModel:(ATMyOfferOfferModel*)offerModel extra:(NSDictionary*)extra {
    if (offerModel.impURL != nil) {
        __weak typeof(self) weakSelf = self;
        [_redirectorsAccessor writeWithBlock:^{
            __weak __block ATOfferSessionRedirector *weakRedirector = nil;
            __block ATOfferSessionRedirector *redirector = [ATOfferSessionRedirector redirectorWithURL:[NSURL URLWithString:AppendLifeCircleIDToURL(offerModel.impURL, extra[kATOfferTrackerExtraLifeCircleID])] completion:^(NSURL *finalURL, NSError *error) { [weakSelf.redirectorsAccessor writeWithBlock:^{ [weakSelf.redirectors removeObject:weakRedirector]; }]; }];
            weakRedirector = redirector;
            [weakSelf.redirectors addObject:redirector];
        }];
    }
}

-(void) clickOfferWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting *)setting extra:(NSDictionary*)extra skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate viewController:(UIViewController *)viewController circleId:(NSString *) circleId{
    
    [[ATCommonOfferTracker sharedTracker] clickOfferWithOfferModel:offerModel setting:setting circleID:circleId delegate:skDelegate viewController:viewController extra:extra clickCallbackHandler:nil];
}

BOOL validateFinalURL(NSURL *URL) {
    return [URL isKindOfClass:[NSURL class]] && ([[ATAppSettingManager sharedManager].trackingSetting.tcHosts containsObject:URL.host]);
}

-(void)preloadStorekitForOfferModel:(ATMyOfferOfferModel *)offerModel setting:(ATMyOfferSetting *) setting viewController:(UIViewController *)viewController circleId:(NSString *) circleId  skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate {
    [[ATCommonOfferTracker sharedTracker] preloadStorekitForOfferModel:offerModel setting:setting viewController:viewController circleId:circleId skDelegate:skDelegate];
}

-(void)presentStorekitViewControllerWithCircleId:(NSString *) circleId offerModel:(ATMyOfferOfferModel*)offerModel pkgName:(NSString *) pkgName placementID:(NSString *)placementID offerID:(NSString *)offerID  skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate viewController:(UIViewController *)viewController {
    [[ATCommonOfferTracker sharedTracker] presentStorekitViewControllerWithCircleId:circleId offerModel:offerModel pkgName:pkgName placementID:placementID offerID:offerID skDelegate:skDelegate viewController:viewController];
}

// MARK:- SFSafariViewControllerDelegate
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [controller dismissViewControllerAnimated:true completion:^{
        
    }];
}

- (void)safariViewController:(SFSafariViewController *)controller initialLoadDidRedirectToURL:(NSURL *)URL {
    NSLog(@"redirect to: %@",URL.absoluteString);
}


@end

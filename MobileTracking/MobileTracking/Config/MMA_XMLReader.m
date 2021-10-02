//
//  MMA_XMLReader.m
//  MobileTracking
//
//  Created by Wenqi on 14-3-11.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//

#import "MMA_XMLReader.h"
#import "MMA_GDataXMLNode.h"

@interface MMA_XMLReader()

+ (void)initOfflineCache:(MMA_SDKConfig *)sdkConfig rootElement:(MMA_GDataXMLElement *)rootElement;
+ (void)initCompanies:(MMA_SDKConfig *)sdkConfig rootElement:(MMA_GDataXMLElement *)rootElement;

@end

@implementation MMA_XMLReader

+ (MMA_SDKConfig *)sdkConfigWithString:(NSString *)xmlString
{
    
    MMA_SDKConfig *sdkConfig = [[MMA_SDKConfig alloc] init];
    
    MMA_GDataXMLDocument *doc = [[MMA_GDataXMLDocument alloc]initWithXMLString:xmlString options:0 error:nil];
    [doc setCharacterEncoding:@"utf-8"];
    
    MMA_GDataXMLElement *rootElement = [doc rootElement] ;
    
    [self initOfflineCache:sdkConfig rootElement:rootElement];
    [self initCompanies:sdkConfig rootElement:rootElement];
    
    return sdkConfig;
}

+ (MMA_SDKConfig *)sdkConfigWithData:(NSData *)data
{
    
    MMA_SDKConfig *sdkConfig = [[MMA_SDKConfig alloc] init];
    
    MMA_GDataXMLDocument *doc = [[MMA_GDataXMLDocument alloc] initWithData:data  options:0 error:nil];
    [doc setCharacterEncoding:@"utf-8"];
    
    MMA_GDataXMLElement *rootElement = [doc rootElement];
    
    [self initOfflineCache:sdkConfig rootElement:rootElement];
    [self initViewability:sdkConfig rootElement:rootElement];
    
    [self initCompanies:sdkConfig rootElement:rootElement];
    
    return sdkConfig;
}

+ (NSInteger)stringToIntergetFromElement:(MMA_GDataXMLElement *)element name:(NSString *)name
{
    NSString *string = [[[element elementsForName:name] firstObject] stringValue] ;
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return  [[string stringByTrimmingCharactersInSet:characterSet] integerValue];
}

+(NSString *)StringTrimFromElement:(MMA_GDataXMLElement*)element name:(NSString*)name{
    NSString *string = [[[element elementsForName:name] firstObject] stringValue] ;
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (void)initOfflineCache:(MMA_SDKConfig *)sdkConfig rootElement:(MMA_GDataXMLElement *)rootElement
{
    NSArray *array = [rootElement elementsForName:@"offlineCache"];
    if (array == nil || [array count] == 0) {
        return;
    }
    
    MMA_GDataXMLElement *element = [array firstObject];
    MMA_OfflineCache *offlineCache = [[MMA_OfflineCache alloc] init];
    
    offlineCache.length = [self stringToIntergetFromElement:element name:@"length"];
    offlineCache.queueExpirationSecs =[self stringToIntergetFromElement:element name:@"queueExpirationSecs"];
    offlineCache.timeout = [self stringToIntergetFromElement:element name:@"timeout"];
    
    sdkConfig.offlineCache = offlineCache;
}

+ (void)initViewability:(MMA_SDKConfig *)sdkConfig rootElement:(MMA_GDataXMLElement *)rootElement {
    NSArray *array = [rootElement elementsForName:@"viewability"];
    if (array == nil || [array count] == 0) {
        return;
    }
    
    MMA_GDataXMLElement *element = [array firstObject];
    MMA_Viewability *viewability = [[MMA_Viewability alloc] init];
    
    viewability.intervalTime = [self stringToIntergetFromElement:element name:@"intervalTime"];
    viewability.viewabilityFrame = [self stringToIntergetFromElement:element name:@"viewabilityFrame"];
    
    viewability.viewabilityTime = [self stringToIntergetFromElement:element name:@"viewabilityTime"];
    viewability.viewabilityVideoTime = [self stringToIntergetFromElement:element name:@"viewabilityVideoTime"];
    
    viewability.maxExpirationSecs = [self stringToIntergetFromElement:element name:@"maxExpirationSecs"];
    viewability.maxAmount = [self stringToIntergetFromElement:element name:@"maxAmount"];
    
    sdkConfig.viewability = viewability;
    
}

+ (void)initCompanies:(MMA_SDKConfig *)sdkConfig rootElement:(MMA_GDataXMLElement *)rootElement
{
    sdkConfig.companies = [NSMutableDictionary dictionary];
    NSArray *companys = [rootElement nodesForXPath:@"//companies/company" error:nil];
    
    for (MMA_GDataXMLElement *element in companys) {
        MMA_Company *company = [[MMA_Company alloc] init];
        
        
        company.name = [[[element elementsForName:@"name" ] firstObject] stringValue];
        company.jsurl = [[[element elementsForName:@"jsurl" ] firstObject] stringValue];
        company.jsname = [[[element elementsForName:@"jsname" ] firstObject] stringValue];
        
        company.domain = [NSMutableArray array];
        NSArray *urls = [element nodesForXPath:@"domain/url" error:nil];
        for (MMA_GDataXMLElement *url in urls) {
            [company.domain addObject:[url stringValue]];
        }
        
        company.signature = [[MMA_Signature alloc] init];
        company.signature.publicKey = [[[element nodesForXPath:@"signature/publicKey" error:nil] firstObject] stringValue];
        company.signature.paramKey = [[[element nodesForXPath:@"signature/paramKey" error:nil] firstObject] stringValue];
        
        company.separator = [[[element elementsForName:@"separator" ] firstObject] stringValue];
        company.equalizer = [[[element elementsForName:@"equalizer" ] firstObject] stringValue];
        if (company.equalizer == nil) {
            company.equalizer = @"";
        }
        
        if ([[element elementsForName:@"timeStampUseSecond" ] firstObject]) {
            company.timeStampUseSecond = [[[[element elementsForName:@"timeStampUseSecond" ] firstObject] stringValue] boolValue];
        } else {
            company.timeStampUseSecond = false;
        }
        
        company.MMASwitch = [[MMA_Switch alloc] init];
        
        company.MMASwitch.isTrackLocation = [[[[element nodesForXPath:@"switch/isTrackLocation" error:nil] firstObject] stringValue] boolValue];
        MMA_GDataXMLElement *offlineCacheExpiration = [[element elementsForName:@"switch"] firstObject];
        company.MMASwitch.offlineCacheExpiration = [self stringToIntergetFromElement:offlineCacheExpiration name:@"offlineCacheExpiration"];
        
        MMA_GDataXMLElement *viewabilityTrackPolicy = [[element elementsForName:@"switch"] firstObject];
        company.MMASwitch.viewabilityTrackPolicy = [self stringToIntergetFromElement:viewabilityTrackPolicy name:@"viewabilityTrackPolicy"];

        
        
        MMA_GDataXMLElement *encryptElement = [[element nodesForXPath:@"switch/encrypt" error:nil] firstObject];
        company.MMASwitch.encrypt = [NSMutableDictionary dictionary];
        for(MMA_GDataXMLElement *el  in [encryptElement children]){
            [company.MMASwitch.encrypt setValue:[el stringValue] forKey:[el name]];
        }
        
        company.config = [[MMA_Config alloc] init];
        
        company.config.arguments = [NSMutableDictionary dictionary];
        NSArray *arguments = [element nodesForXPath:@"config/arguments/argument" error:nil];
        for(MMA_GDataXMLElement *el  in arguments){
            MMA_Argument *argument = [[MMA_Argument alloc] init];
            argument.key = [self StringTrimFromElement:el name:@"key"];
            argument.value = [self StringTrimFromElement:el name:@"value"];
            argument.urlEncode = [[self StringTrimFromElement:el name:@"urlEncode"] boolValue];
            argument.isRequired = [[self StringTrimFromElement:el name:@"isRequired"] boolValue];
            [company.config.arguments setValue:argument forKey:argument.key];
        }
        
        company.config.events = [NSMutableDictionary dictionary];
        NSArray *events = [element nodesForXPath:@"config/events/event" error:nil];
        for(MMA_GDataXMLElement *el  in events){
            MMA_Event *event = [[MMA_Event alloc] init];
            event.key = [self StringTrimFromElement:el name:@"key" ];
            event.value = [self StringTrimFromElement:el name:@"value" ];
            event.urlEncode = [[self StringTrimFromElement:el name:@"urlEncode" ] boolValue];
            [company.config.events setValue:event forKey:event.key];
            
        }
        
        //        MMA_GDataXMLElement *impressionplaceElement = [[element nodesForXPath:@"config/Adplacement/argument" error:nil] firstObject];
        NSArray *impressionplaceElement = [element nodesForXPath:@"config/Adplacement/argument" error:nil];
        company.config.Adplacement = [NSMutableDictionary dictionary];
        for(MMA_GDataXMLElement *el  in impressionplaceElement){
            MMA_Argument *argument = [[MMA_Argument alloc] init];
            argument.key = [self StringTrimFromElement:el name:@"key" ];
            argument.value = [self StringTrimFromElement:el name:@"value" ];
            argument.urlEncode = [[self StringTrimFromElement:el name:@"urlEncode" ] boolValue];
            [company.config.Adplacement setValue:argument forKey:argument.key];
        }
        
        company.config.viewabilityarguments = [NSMutableDictionary dictionary];
        NSArray *viewabilityarguments = [element nodesForXPath:@"config/viewabilityarguments/argument" error:nil];
        for(MMA_GDataXMLElement *el  in viewabilityarguments){
            MMA_Argument *argument = [[MMA_Argument alloc] init];
            argument.key = [self StringTrimFromElement:el name:@"key"];
            argument.value = [self StringTrimFromElement:el name:@"value"];
            argument.urlEncode = [[self StringTrimFromElement:el name:@"urlEncode"] boolValue];
            argument.isRequired = [[self StringTrimFromElement:el name:@"isRequired"] boolValue];
            [company.config.viewabilityarguments setValue:argument forKey:argument.key];
        }
        
        [sdkConfig.companies setValue:company forKey:company.name];
    }
}


@end

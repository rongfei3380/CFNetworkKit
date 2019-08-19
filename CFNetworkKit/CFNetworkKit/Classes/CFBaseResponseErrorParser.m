//
//  CFBaseResponseErrorParser.m
//  CFNetworkKit
//
//  Created by Jobs on 2019/8/19.
//  Copyright © 2019 Jobs. All rights reserved.
//

#import "CFBaseResponseErrorParser.h"

@implementation CFBaseResponseErrorParser

+ (void)parseResponseDataForError:(NSError **)outError withData:(id)data {
    
//    根据 实际业务情况 来处理
    if (![data isKindOfClass:[NSDictionary class]] || ![(NSDictionary *)data objectForKey:@"code"])
        return;
    
    
    int code = [[(NSDictionary *)data objectForKey:@"code"] intValue];
    if (code == 200) {
        return;
    }
    
    NSString *message = [(NSDictionary *)data objectForKey:@"message"];
    NSMutableDictionary *theUserInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:message, NSLocalizedDescriptionKey,
                                        NULL];
    
    *outError = [NSError errorWithDomain:@"com.chengfeir.baseAPI.network" code:code userInfo:theUserInfo];
}

@end

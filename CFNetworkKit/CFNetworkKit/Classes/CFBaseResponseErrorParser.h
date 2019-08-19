//
//  CFBaseResponseErrorParser.h
//  CFNetworkKit
//
//  Created by Jobs on 2019/8/19.
//  Copyright © 2019 Jobs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 用于处理http success 中的自定义的error code
 */
@interface CFBaseResponseErrorParser : NSObject

+ (void)parseResponseDataForError:(NSError **)outError withData:(id)data;

@end

NS_ASSUME_NONNULL_END

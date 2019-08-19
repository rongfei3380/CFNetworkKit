//
//  CFBaseAPIClient.h
//  CFNetworkKit
//
//  Created by Jobs on 2019/8/17.
//  Copyright © 2019 Jobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    CFHTTPRequestMethodGET,
    CFHTTPRequestMethodPOST,
    CFHTTPRequestMethodPUT,
    CFHTTPRequestMethodDELETE,
} CFHTTPRequestMethod;

typedef void (^CFAPIClientSuccessBlock) (id dataBody);
typedef void (^CFAPIClientFailureBlock) (NSError *error);
typedef void (^CFAPIClientUploaderBlock) (NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);

/**
 客户端请求的基类  封装AFNetworkKit 的方法
 */
@interface CFBaseAPIClient : NSObject

+ (instancetype)sharedInstance;


/**
 Sets the "Authorization" HTTP header set in request objects made by the HTTP client to a basic authentication value with Base64-encoded username and password. This overwrites any existing value for this header.
 
 @param username The HTTP basic auth username
 @param password The HTTP basic auth password
 */
- (void)setAuthorizationHeaderFieldWithUsername:(NSString *)username
                                       password:(NSString *)password;


/**
 Clears any existing value for the "Authorization" HTTP header.
 */
- (void)clearAuthorizationHeader;

@end

NS_ASSUME_NONNULL_END

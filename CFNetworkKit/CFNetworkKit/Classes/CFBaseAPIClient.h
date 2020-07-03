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

@property (nonatomic, strong) NSString *baseUrl;

+ (instancetype)sharedInstance;


- (void)sendRequest:(CFHTTPRequestMethod)method
               path:(NSString *)path
         parameters:(NSDictionary *)parameters
            success:(CFAPIClientSuccessBlock)successBlock
            failure:(CFAPIClientFailureBlock)failureBlock;

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



#pragma mark- test

- (void)testSucess:(CFAPIClientSuccessBlock)successBlock
      failureBlock:(CFAPIClientFailureBlock)failureBlock;

- (void)getUsersListWithPage:(NSInteger )page
                     success:(CFAPIClientSuccessBlock)successBlock
                failureBlock:(CFAPIClientFailureBlock)failureBlock;


/**
 测试登录

 @param username eve.holt@reqres.in
 @param password cityslicka
 @param successBlock
 @param failureBlock
 */
- (void)loginWithUserName:(NSString *)username
                 password:(NSString *)password
                  success:(CFAPIClientSuccessBlock)successBlock
             failureBlock:(CFAPIClientFailureBlock)failureBlock;


/**
 测试 PUT 方法

 @param name morpheus
 @param job zion resident
 @param successBlock
 @param failureBlock 
 */
- (void)updateUserWithName:(NSString *)name
                       job:(NSString *)job
                   success:(CFAPIClientSuccessBlock)successBlock
              failureBlock:(CFAPIClientFailureBlock)failureBlock;


@end

NS_ASSUME_NONNULL_END

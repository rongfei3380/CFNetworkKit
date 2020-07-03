//
//  CFBaseAPIClient.m
//  CFNetworkKit
//
//  Created by Jobs on 2019/8/17.
//  Copyright © 2019 Jobs. All rights reserved.
//

#import "CFBaseAPIClient.h"
#import "AFHTTPSessionManager.h"
#import <sys/sysctl.h>
#import "CFBaseResponseErrorParser.h"
#import "AFNetworking.h"
#import "CFFoundation.h"

@interface CFBaseAPIClient (){
    AFHTTPSessionManager *_httpSessionManager;
}



@property (nonatomic, strong) dispatch_queue_t synchronizationQueue;
@property (nonatomic, strong) dispatch_queue_t responseQueue;

@property (nonatomic, strong) AFJSONResponseSerializer *responseSerializer;
@property (nonatomic, strong) AFJSONRequestSerializer *requestSerializer;

@property(nonatomic, strong)NSURLSessionConfiguration *configuration;


@end

@implementation CFBaseAPIClient

#pragma mark init
+ (instancetype)sharedInstance {
    //    静态局部变量
    static id instance = nil;
    //    通过dispatch_once方式 确保instance 在多线程环境下 只被创建一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //        在调用alloc的时候，默认的alloc会调用allocWithZone方法
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}


// 重写方法 必不可少
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (instancetype)init{
    if (self = [super init]) {
        
        _baseUrl = @"http://www.oneoff.net/index.php?m=api&c=apimap&a=";
        
        _configuration = [CFBaseAPIClient defaultURLSessionConfiguration];
//
        _httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_baseUrl] sessionConfiguration:_configuration];
//
        _requestSerializer = [AFJSONRequestSerializer serializer];
        _httpSessionManager.requestSerializer = _requestSerializer;
        
        _responseSerializer = [AFJSONResponseSerializer serializer];
        _httpSessionManager.responseSerializer = _responseSerializer;
        
    }
    return self;
}

static NSString *staticUserAgent = nil;
+ (NSString *)defaultUserAgent {
    if (staticUserAgent == nil) {
        //TODO unknown in user-agent
        // bundleIdentifier/version (unknow, systemName systemVersion, model, Scale/scaleNumber)
        // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
        NSString *identifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        NSString *systemName = [[UIDevice currentDevice] systemName];
        NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
        char *buffer[256] = { 0 };
        size_t size = sizeof(buffer);
        sysctlbyname("hw.machine", buffer, &size, NULL, 0);
        NSString *platform = [NSString stringWithCString:(const char*)buffer
                                                encoding:NSUTF8StringEncoding];
        
        staticUserAgent = [NSString stringWithFormat:@"%@/%@(%@, %@ %@, %@, Scale/%.1f)", identifier , version, build, systemName , systemVersion , platform , ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0)];
    }
    return staticUserAgent;
}

+ (AFJSONRequestSerializer *)defaultAFJSONRequestSerializer {
    AFJSONRequestSerializer *JSONRequestSerializer = [AFJSONRequestSerializer serializer];
    [JSONRequestSerializer setValue:[CFBaseAPIClient defaultUserAgent] forHTTPHeaderField:@"User-Agent"];
    
    return JSONRequestSerializer;
}

+ (NSURLSessionConfiguration *)defaultURLSessionConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    configuration.HTTPShouldSetCookies = YES;
    configuration.HTTPShouldUsePipelining = NO;
    
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.allowsCellularAccess = YES;
    configuration.timeoutIntervalForRequest = 60.0;
    
    // set the default HTTP headers
    [configuration.HTTPAdditionalHeaders setValue:[self defaultUserAgent] forKey:@"User-Agent"];
    
    return configuration;
}

+ (AFJSONResponseSerializer *)defaultJSONResponseSerializer {
    AFJSONResponseSerializer * JSONResponseSerializer = [AFJSONResponseSerializer serializer];
    
    
    
    return JSONResponseSerializer;
}


// 根据实际业务需要 与后端确定用户验证的字段
- (void)setAuthorizationHeaderFieldWithUsername:(NSString *)username
                                       password:(NSString *)password {
    [self.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
}

- (void)clearAuthorizationHeader {
    [self.requestSerializer clearAuthorizationHeader];
}


/**
 负责发送API请求
 */
- (void)sendRequest:(CFHTTPRequestMethod)method
               path:(NSString *)path
         parameters:(NSDictionary *)parameters
            success:(CFAPIClientSuccessBlock)successBlock
            failure:(CFAPIClientFailureBlock)failureBlock {
    
    
    
    void (^requestSuccessBlock)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject);
    requestSuccessBlock = ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error = nil;
        [CFBaseResponseErrorParser parseResponseDataForError:&error withData:responseObject];
        if (error) {
            DDLogDebug(@"path!!! = %@", path);
            DDLogDebug(@"error JSON!!! = %@", responseObject);
            
            if (failureBlock) {
                failureBlock(error);
            }
        } else if (successBlock) {
            NSDictionary *dataDic = (NSDictionary *)responseObject;
            //TODO. 特殊处理
            
            DDLogDebug(@"path!!! = %@", path);
            DDLogDebug(@"retVal!!! = %@", responseObject);
            
//            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
//            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//            DDLogDebug(@"retVal Str !!! = %@", jsonStr);
            
            
            successBlock(dataDic);
        }
    };
    
    void (^requestFailureBlock)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error);
    requestFailureBlock = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        DDLogDebug(@"error PATH!!! = %@", path);
        DDLogDebug(@"error!!! = %@", error.description);

    };

    
    switch (method) {
        case CFHTTPRequestMethodGET: {
            [_httpSessionManager GET:path parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (requestSuccessBlock) {
                    requestSuccessBlock(task, responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (requestFailureBlock) {
                    requestFailureBlock(task, error);
                }
            }];
        }
            break;
        case CFHTTPRequestMethodPOST: {
            [_httpSessionManager POST:path parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (requestSuccessBlock) {
                    requestSuccessBlock(task, responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (requestFailureBlock) {
                    requestFailureBlock(task, error);
                }
            }];
        }
            break;
        case CFHTTPRequestMethodPUT: {
            [_httpSessionManager PUT:path parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                requestSuccessBlock(task, responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (requestFailureBlock) {
                    requestFailureBlock(task, error);
                }
            }];
        }
            break;
        case CFHTTPRequestMethodDELETE: {
            [_httpSessionManager DELETE:path parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
            }];
        }
            break;
        default:
            break;
    }
}

/**
 附加基本的请求参数，每个请求都会带  根据实际业务需求处理
 */
- (void)appendRequestParameters:(NSMutableDictionary *)parameters {
    
}



#pragma mark- TEST

- (void)testSucess:(CFAPIClientSuccessBlock)successBlock
      failureBlock:(CFAPIClientFailureBlock)failureBlock {
    
    [self sendRequest:CFHTTPRequestMethodGET path:@"api/users"
           parameters:nil
              success:^(id  _Nonnull dataBody) {
                  if (successBlock) {
                      successBlock(dataBody);
                  }
    } failure:^(NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

- (void)getUsersListWithPage:(NSInteger )page
                     success:(CFAPIClientSuccessBlock)successBlock
                failureBlock:(CFAPIClientFailureBlock)failureBlock {
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    
    [paramDic setObject:[NSString stringWithFormat:@"%ld" , page] forKey:@"page"];
    
    
    [self sendRequest:CFHTTPRequestMethodGET path:@"api/users" parameters:paramDic success:^(id  _Nonnull dataBody) {
        if (successBlock) {
            successBlock(dataBody);
        }
    } failure:^(NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

- (void)loginWithUserName:(NSString *)username
                 password:(NSString *)password
                  success:(CFAPIClientSuccessBlock)successBlock
             failureBlock:(CFAPIClientFailureBlock)failureBlock {
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:username forKey:@"email"];
//    [paramDic setObject:password forKey:@"password"];
    
    [self sendRequest:CFHTTPRequestMethodPOST path:@"api/login" parameters:paramDic success:^(id  _Nonnull dataBody) {
        if (successBlock) {
            successBlock(dataBody);
        }
    } failure:^(NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

- (void)updateUserWithName:(NSString *)name
                       job:(NSString *)job
                   success:(CFAPIClientSuccessBlock)successBlock
              failureBlock:(CFAPIClientFailureBlock)failureBlock {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:name forKey:@"name"];
    [paramDic setObject:job forKey:@"job"];
    
    [self sendRequest:CFHTTPRequestMethodPUT path:@"/api/users/2" parameters:paramDic success:^(id  _Nonnull dataBody) {
        if (successBlock) {
            successBlock(dataBody);
        }
    } failure:^(NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
    
}

@end

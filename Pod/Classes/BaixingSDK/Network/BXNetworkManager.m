//
//  BXNetworkManager.m
//  BaixingSDK
//
//  Created by phoebus on 9/10/14.
//  Copyright (c) 2014 baixing. All rights reserved.
//

#import "BXNetworkManager.h"
#import "BXHttpRequest.h"
#import "BXHttpCache.h"
#import "BXHttpCacheObject.h"
#import "BXHttpResponseObject.h"
#import "BXError.h"
#import "BXHTTPRequestOperationLogger.h"
#import "BXDBManager.h"

#import "AFNetworking.h"

extern NSString * const kBXHttpCacheObjectRequest;
extern NSString * const kBXHttpCacheObjectExpire;
extern NSString * const kBXHttpCacheObjectResponse;

@interface BXNetworkManager ()

@property (nonatomic, assign) BOOL showLog;

@end

@implementation BXNetworkManager

+ (instancetype)shareManager
{
    static dispatch_once_t token;
    static BXNetworkManager *manager;

    dispatch_once(&token, ^{
        manager = [[BXNetworkManager alloc] initInstance];
    });

    return manager;
}

- (instancetype)initInstance
{
    self = [super init];

    if (self) {
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        self.afManager = manager;
        
        // create cache db table.
        NSString *sql = @"create table if not exists net_caches (request text primary key, expire text, response blob);";
        [[BXDBManager shareManager] batchExecuteSql:sql];
    }

    return self;
}

- (instancetype)init
{
    return [BXNetworkManager shareManager];
}

- (void)logEnable:(BOOL)enable
{
    self.showLog = enable;
}

- (BOOL)isReachable
{
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    
    if (status == AFNetworkReachabilityStatusReachableViaWiFi ||
        status == AFNetworkReachabilityStatusReachableViaWWAN ||
        status == AFNetworkReachabilityStatusUnknown /* AppStart status */ ) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isWiFiNetwork
{
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    
    if (status == AFNetworkReachabilityStatusReachableViaWiFi ||
        status == AFNetworkReachabilityStatusUnknown /* AppStart status */ ) {
        return YES;
    }
    
    return NO;
}

- (void)requestByUrl:(NSString *)url
              method:(BX_HTTP_METHOD)method
              header:(NSDictionary *)header
          parameters:(NSDictionary *)parameters
            useCache:(BOOL)useCache
             success:(void (^)(id data))success
             failure:(void (^)(BXError *bxError))failure
{
    if ( self.showLog ) {
        [[BXHTTPRequestOperationLogger sharedLogger] startLogging];
        [[BXHTTPRequestOperationLogger sharedLogger] setLevel:BXLoggerLevelDebug];
    } else {
        [[BXHTTPRequestOperationLogger sharedLogger] stopLogging];
    }
    
    if (method == BX_GET) {
        // read cache data
        if (useCache) {
            NSString *cacheKey = [[BXHttpCache shareCache] httpCacheKey:url header:header parameters:parameters];
            BXHttpCacheObject *cacheObject = [[BXHttpCache shareCache] validCacheForKey:cacheKey];
            if (nil != cacheObject) {
                id response = [NSKeyedUnarchiver unarchiveObjectWithData:cacheObject.response];
                success(response);
                return;
            }
        }

        // send request
        [BXHttpRequest getByUrl:url header:header parameters:parameters success:^(AFHTTPRequestOperation *operation, id data) {
            BXHttpResponseObject *httpResponse = [[BXHttpResponseObject alloc] initWithObject:data];
            
            if ( useCache ) {
                NSString *cacheKey = [[BXHttpCache shareCache] httpCacheKey:url header:header parameters:parameters];
                [[BXHttpCache shareCache] setCache:httpResponse forKey:cacheKey];
            }
            
            // callback
            success(httpResponse.result);

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            BXError *bxError = [self transformError:error withOperation:operation];
            failure(bxError);
        }];
    }
    else {
        // send request
        [BXHttpRequest postByUrl:url header:header parameters:parameters success:^(AFHTTPRequestOperation *operation, id data) {
            
            // callback
            BXHttpResponseObject *httpResponse = [[BXHttpResponseObject alloc] initWithObject:data];
            success(httpResponse.result);

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            BXError *bxError = [self transformError:error withOperation:operation];
            failure(bxError);
        }];
    }
}

- (void)requestMultipart:(NSString *)url
                fileName:(NSString *)fileName
                    file:(NSData *)fileData
              parameters:(NSDictionary *)parameters
                progress:(void (^)(long long writedBytes,long long totalBytes))progress
                 success:(void (^)(id data))success
                 failure:(void (^)(BXError *bxError))failure
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager manager] initWithBaseURL:[NSURL URLWithString:url]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];

    AFHTTPRequestOperation *operation = [manager POST:@"" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:@"multipart/form-data"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // callback
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            success(json);
        } else {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        BXError *bxError = [self transformError:error withOperation:operation];
        failure(bxError);
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        if (progress) {
            progress(totalBytesWritten, totalBytesExpectedToWrite);
        }
    }];
    [operation start];
}

- (void)uploadDataByUrl:(NSString *)url
                 header:(NSDictionary *)header
                   file:(NSData *)file
             parameters:(NSDictionary *)parameters
                success:(void (^)(id data))success
                failure:(void (^)(BXError *bxError))failure
{
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:parameters error:nil];
    
    // header
    for (id key in [header allKeys]) {
        id value = [header objectForKey:key];
        [request setValue:value forHTTPHeaderField:key];
    }
    
    [request setHTTPBody:file];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // callback
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        BXError *bxError = [self transformError:error withOperation:operation];
        failure(bxError);
    }];
    
    [operation start];
}

#pragma mark - private -
- (BXError *)transformError:(NSError *)error withOperation:(AFHTTPRequestOperation *)operation
{
    if (operation.responseData == nil) {
        return [BXError errorWithNSError:error type:kBXErrorNetwork];
    }

    NSError *err = nil;
    BXError *bxError = [BXError errorWithNSError:error type:kBXErrorNetwork];
    NSDictionary *errDic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:&err];

    if (err) {
        bxError.type      = kBxErrorJson;
        bxError.bxMessage = @"服务异常, 请稍后重试";
    }
    else {
        bxError.errDictionary = errDic;
        bxError.type          = kBXErrorServer;
        bxError.bxCode        = [[errDic objectForKey:@"error"] intValue];
        bxError.bxMessage     = [[errDic objectForKey:@"message"] description].length ? [errDic objectForKey:@"message"] : @"";
        
        NSDictionary *extDic = [errDic objectForKey:@"ext"];
        if (extDic && [extDic isKindOfClass:[NSDictionary class]] && (![extDic isEqual:[NSNull null]])) {
            bxError.bxExt          = [[BXErrorExt alloc] init];
            bxError.bxExt.bangui   = [extDic objectForKey:@"bangui"];
            bxError.bxExt.rule     = [extDic objectForKey:@"rule"];
            bxError.bxExt.ruleInfo = [extDic objectForKey:@"ruleInfo"];
            bxError.bxExt.action   = [extDic objectForKey:@"action"];
        }
    }
    return bxError;
}

@end
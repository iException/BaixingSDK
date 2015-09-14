//
//  BXNetworkManager.h
//  BaixingSDK
//
//  Created by phoebus on 9/10/14.
//  Copyright (c) 2014 baixing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    BX_GET,
    BX_POST
} BX_HTTP_METHOD;

@class BXError, AFHTTPRequestOperationManager;

@interface BXNetworkManager : NSObject

@property (nonatomic) AFHTTPRequestOperationManager *afManager;

+ (instancetype)shareManager;

- (void)logEnable:(BOOL)enable;

- (BOOL)isReachable;

- (BOOL)isWiFiNetwork;

- (void)requestByUrl:(NSString *)url
              method:(BX_HTTP_METHOD)method
              header:(NSDictionary *)header
          parameters:(NSDictionary *)parameters
            useCache:(BOOL)useCache
             success:(void (^)(id data))success
             failure:(void (^)(BXError *bxError))failure;

- (void)requestMultipart:(NSString *)url
                fileName:(NSString *)fileName
                    file:(NSData *)fileData
              parameters:(NSDictionary *)parameters
                progress:(void (^)(long long writedBytes,long long totalBytes))progress
                 success:(void (^)(id data))success
                 failure:(void (^)(BXError *bxError))failure;

- (void)uploadDataByUrl:(NSString *)url
                 header:(NSDictionary *)header
                   file:(NSData *)file
             parameters:(NSDictionary *)parameters
                success:(void (^)(id data))success
                failure:(void (^)(BXError *bxError))failure;

@end

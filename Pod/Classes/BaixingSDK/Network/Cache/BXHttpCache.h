//
//  BXHttpCache.h
//  BaixingSDK
//
//  Created by phoebus on 9/25/14.
//  Copyright (c) 2014 baixing. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BXHttpCacheObject;

@interface BXHttpCache : NSObject

+ (instancetype)shareCache;

- (BXHttpCacheObject *)cacheForKey:(NSString *)cacheKey;

- (BXHttpCacheObject *)validCacheForKey:(NSString *)cacheKey;

- (void)setCache:(id)cacheData forKey:(NSString *)cacheKey;

- (BOOL)isExpireTime:(NSString *)expireTime;

- (NSString *)httpCacheKey:(NSString *)url header:(NSDictionary *)header parameters:(NSDictionary *)parameters;

@end

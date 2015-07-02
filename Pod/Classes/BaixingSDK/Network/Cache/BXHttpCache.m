//
//  BXHttpCache.m
//  BaixingSDK
//
//  Created by phoebus on 9/25/14.
//  Copyright (c) 2014 baixing. All rights reserved.
//

#import "BXHttpCache.h"
#import "BXDBManager.h"
#import "BXHttpCacheObject.h"
#import "NSString+Md5.h"
#import <sqlite3.h>
#import "BXHttpResponseObject.h"

NSString * const kBXHttpCacheTableName          = @"net_caches";

extern NSString * const kBXHttpCacheObjectRequest;
extern NSString * const kBXHttpCacheObjectExpire;
extern NSString * const kBXHttpCacheObjectResponse;

@implementation BXHttpCache

+ (instancetype)shareCache
{
    static dispatch_once_t token;
    static BXHttpCache *cache;

    dispatch_once(&token, ^{
        cache = [[BXHttpCache alloc] initInstance];
    });

    return cache;
}

- (instancetype)initInstance
{
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

- (instancetype)init
{
    return [BXHttpCache shareCache];
}

- (BXHttpCacheObject *)cacheForKey:(NSString *)cacheKey
{
    NSDictionary *query = @{ kBXHttpCacheObjectRequest:cacheKey };
    
    return [self searchForColumns:nil withQuery:query withOption:nil];
}

- (BXHttpCacheObject *)validCacheForKey:(NSString *)cacheKey
{
    NSDictionary *query = @{ kBXHttpCacheObjectRequest:cacheKey };
    
    BXHttpCacheObject *cacheObject = [self searchForColumns:nil withQuery:query withOption:nil];
    if ( [self isExpireTime:cacheObject.expire] ) {
        return nil;
    }
    
    return cacheObject;
}

- (void)setCache:(BXHttpResponseObject *)cacheData forKey:(NSString *)cacheKey
{
    NSData *response = [NSKeyedArchiver archivedDataWithRootObject:cacheData.result];
    NSString *expire = [self getExpireTimeByPeriod:cacheData.expireInSeconds];

    if ( !expire || !response ) {
        return;
    }
    
    BXHttpCacheObject *cacheObject = [[BXHttpCacheObject alloc] initWithObject:@{ kBXHttpCacheObjectExpire:expire, kBXHttpCacheObjectResponse:response }];
    
    BXHttpCacheObject *result = [self cacheForKey:cacheKey];
    if (nil != result) {
        // update
        NSArray *parameters = @[ cacheObject.expire, cacheObject.response, cacheKey ];

        [self updateWithParameters:parameters];
    } else {
        // insert
        NSArray *parameters = @[ cacheKey, cacheObject.expire, cacheObject.response ];

        [self insertWithParameters:parameters];
    }
}

#pragma mark - private -
- (BXHttpCacheObject *)searchForColumns:(NSArray *)columns
                              withQuery:(NSDictionary *)query
                             withOption:(NSDictionary *)option
{
    NSString *column_str = [self getSearchColumnString:columns];
    NSString *query_str  = [self getQueryString:query tableName:[self httpCacheTableName]];
    NSString *option_str = [self getOptionString:option];
    
    NSString *sql = [NSString stringWithFormat:@"select %@ from %@ where %@ %@", column_str, [self httpCacheTableName], query_str, option_str];
    
    id result = [[BXDBManager shareManager] searchBySql:sql parameters:nil];
    if ( nil == result || 0 == [result count] ) {
        return nil;
    }
    
    return [[BXHttpCacheObject alloc] initWithObject:[result objectAtIndex:0]];
}

- (BOOL)insertWithParameters:(NSArray *)parameters
{
    // warnning:FMDB sql string can not use stringWithFormat
    NSString *sql = @"insert into net_caches (request, expire, response) values (?, ?, ?)";
    
    return [[BXDBManager shareManager] insertBySql:sql parameters:parameters];
}

- (BOOL)updateWithParameters:(NSArray *)parameters
{
    // warnning:FMDB sql string can not use stringWithFormat
    NSString *sql = @"update net_caches set expire = ?, response = ? where request = ?";
    
    return [[BXDBManager shareManager] updateBySql:sql parameters:parameters];
}

#pragma mark -
#pragma mark General Method

- (BOOL)isExpireTime:(NSString *)expireTime
{
    int now = (int)[[NSDate date] timeIntervalSince1970];
    int expire = [expireTime intValue];

    if (now > expire) {
        return YES;
    }

    return NO;
}

- (NSString *)httpCacheKey:(NSString *)url header:(NSDictionary *)header parameters:(NSDictionary *)parameters
{
    return [[NSString stringWithFormat:@"%@%@%@", url, [header description], [parameters description]] md5String];
}

- (NSString *)httpCacheTableName
{
    return kBXHttpCacheTableName;
}

- (NSString *)getSearchColumnString:(NSArray *)columns
{
    if ( nil == columns ) { return @"*"; }
    
    return [columns componentsJoinedByString:@","];
}

- (NSString *)getQueryString:(NSDictionary *)query tableName:(NSString *)tableName
{
    NSMutableArray *whereStr = [[NSMutableArray alloc] init];
    
    for( NSString *columnName in @[ kBXHttpCacheObjectRequest, kBXHttpCacheObjectExpire, kBXHttpCacheObjectResponse ] )
    {
        if ( query[columnName] != nil ) {
            [whereStr addObject:[NSString stringWithFormat:@"%@ = %@", columnName, [self escape:query[columnName]]]];
        }
    }
    
    return [whereStr componentsJoinedByString:@" AND "];
}

- (NSString *)getOptionString:(NSDictionary *)option
{
    if (option == nil) { return @""; }
    
    NSString *optionString = @"";
    
    if (option[@"order"] != nil) {
        optionString = [optionString stringByAppendingFormat:@" ORDER BY %@", option[@"order"]];
    }
    
    if (option[@"limit"] != nil) {
        optionString = [optionString stringByAppendingFormat:@" LIMIT %d", [option[@"limit"] intValue]];
    }
    
    return optionString;
}

- (NSString *)escape:(id)value
{
    if (value == nil || value == NSNull.null) { return @"\'\'"; }
    
    NSString *escapedValue = nil;
    
    if ([value isKindOfClass:[NSNumber class]]) {
        escapedValue = [NSString stringWithFormat:@"'%@'", [value stringValue]];
    } else {
        char *theEscapedValue = sqlite3_mprintf("'%q'", [value UTF8String]);
        escapedValue = [NSString stringWithUTF8String:(const char *)theEscapedValue];
        sqlite3_free(theEscapedValue);
    }
    
    return escapedValue;
}

- (NSString *)getExpireTimeByPeriod:(NSString *)period
{
    int now = (int)[[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%d", now + [period intValue]];
}

@end

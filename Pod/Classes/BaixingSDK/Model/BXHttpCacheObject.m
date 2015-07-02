//
//  BXHttpCacheObject.m
//  BaixingSDK
//
//  Created by phoebus on 10/21/14.
//  Copyright (c) 2014 baixing. All rights reserved.
//

#import "BXHttpCacheObject.h"

NSString * const kBXHttpCacheObjectRequest      = @"request";
NSString * const kBXHttpCacheObjectExpire       = @"expire";
NSString * const kBXHttpCacheObjectResponse     = @"response";

@interface BXHttpCacheObject ()

@property (nonatomic, strong, readwrite) NSString *request;
@property (nonatomic, strong, readwrite) NSString *expire;
@property (nonatomic, strong, readwrite) id response;

@end

@implementation BXHttpCacheObject

- (instancetype)initWithObject:(id)object
{
    self = [super init];
    if (self) {
        self.request    = [object objectForKey:kBXHttpCacheObjectRequest];
        self.response   = [object objectForKey:kBXHttpCacheObjectResponse];
        self.expire     = [object objectForKey:kBXHttpCacheObjectExpire];
    }
    return self;
}

@end

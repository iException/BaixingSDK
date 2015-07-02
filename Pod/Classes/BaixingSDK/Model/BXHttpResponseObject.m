//
//  BXHttpResponseObject.m
//  BaixingSDK
//
//  Created by phoebus on 11/11/14.
//  Copyright (c) 2014 baixing. All rights reserved.
//

#import "BXHttpResponseObject.h"
#import "NSObject+BXOperation.h"

NSString *const kBXHttpResponseObjectResult = @"result";
NSString *const kBXHttpResponseObjectExpireInSeconds = @"expireInSeconds";

@interface BXHttpResponseObject ()

@property (nonatomic, strong, readwrite) NSString *expireInSeconds;
@property (nonatomic, strong, readwrite) id result;

@end

@implementation BXHttpResponseObject

- (id)initWithObject:(id)object
{
    self = [super init];
    if (self) {
        self.expireInSeconds = [NSString stringWithFormat:@"%@", [object bx_safeObjectForKey:kBXHttpResponseObjectExpireInSeconds]];
        self.result = [object bx_safeObjectForKey:kBXHttpResponseObjectResult];
    }
    return self;
}

@end

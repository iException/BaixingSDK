//
//  BXHttpCacheObject.h
//  BaixingSDK
//
//  Created by phoebus on 10/21/14.
//  Copyright (c) 2014 baixing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BXHttpCacheObject : NSObject

@property (nonatomic, strong, readonly) NSString *request;
@property (nonatomic, strong, readonly) NSString *expire;
@property (nonatomic, strong, readonly) id response;

- (instancetype)initWithObject:(id)object;

@end

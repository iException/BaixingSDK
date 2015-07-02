//
//  BXHttpResponseObject.h
//  BaixingSDK
//
//  Created by phoebus on 11/11/14.
//  Copyright (c) 2014 baixing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BXHttpResponseObject : NSObject

@property (nonatomic, strong, readonly) NSString *expireInSeconds;
@property (nonatomic, strong, readonly) id result;

- (id)initWithObject:(id)object;

@end

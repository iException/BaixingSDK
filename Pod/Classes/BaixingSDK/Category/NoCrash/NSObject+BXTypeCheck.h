//
//  NSObject+BXTypeCheck.h
//  Baixing
//
//  Created by phoebus on 3/19/15.
//  Copyright (c) 2015 baixing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NSObject+BXOperation.h>

@interface NSObject (BXTypeCheck)

- (BOOL)boolValueForKey:(NSString *)key;

- (NSString *)stringValueForKey:(NSString *)key;

- (NSArray *)arrayValueForKey:(NSString *)key;

- (NSDictionary *)dictionaryValueForKey:(NSString *)key;

- (NSNumber *)numberValueForKey:(NSString *)key;

- (NSUInteger)integerValueForKey:(NSString *)key;

@end

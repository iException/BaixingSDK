//
//  NSObject+BXOperation.h
//  BaixingSDK
//
//  Created by phoebus on 12/3/14.
//  Copyright (c) 2014 baixing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (BXOperation)

// NSDictionary
- (id)bx_safeObjectForKey:(id)key;

// NSMutableDictionary
- (void)bx_setSafeObject:(id)object forSafeKey:(id)key;
- (void)bx_setSafeValue:(id)value forSafeKey:(NSString *)key;

- (void)bx_removeSafeObjectForKey:(id)key;

// NSArray
- (id)bx_safeObjectAtIndex:(NSUInteger)index;
- (id)bx_arrayByAddingSafeObject:(id)object;
- (NSArray *)bx_subarrayWithSafeRange:(NSRange)range;

// NSMutableArray
- (void)bx_addSafeObject:(id)object;
- (void)bx_removeSafeObjectAtIndex:(NSUInteger)index;
- (void)bx_replaceSafeObjectAtIndex:(NSUInteger)index withSafeObject:(id)object;
- (void)bx_removeSafeObject:(id)object;
- (BOOL)bx_containsSafeObject:(id)object;
- (NSUInteger)bx_indexOfSafeObject:(id)object;

// NSString
- (NSString *)bx_safeString:(NSString *)string;
- (NSString *)bx_emptyString:(NSString *)string;
- (NSString *)bx_stringByAppendingSafeString:(NSString *)string;
- (NSString *)bx_stringByReplacingOccurrencesOfSafeString:(NSString *)target withSafeString:(NSString *)replacement;

// NSArray
- (NSArray *)bx_safeArray:(NSArray *)array;

@end

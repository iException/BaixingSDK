//
//  BXDBManager.h
//  BaixingSDK
//
//  Created by phoebus on 9/25/14.
//  Copyright (c) 2014 baixing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BXDBManager : NSObject

+ (instancetype)shareManager;

- (BOOL)clearDBFile;

- (id)searchBySql:(NSString *)sql
       parameters:(NSArray *)parameters;

- (BOOL)insertBySql:(NSString *)sql
         parameters:(NSArray *)parameters;

- (BOOL)deleteBySql:(NSString *)sql
         parameters:(NSArray *)parameters;

- (BOOL)updateBySql:(NSString *)sql
         parameters:(NSArray *)parameters;

- (BOOL)batchExecuteSql:(NSString *)sqls;

@end

//
//  BXDBManager.m
//  BaixingSDK
//
//  Created by phoebus on 9/25/14.
//  Copyright (c) 2014 baixing. All rights reserved.
//

#import "BXDBManager.h"
#import "FMDB.h"
#import "NSObject+BXOperation.h"

@interface BXDBManager ()

@property (nonatomic, strong) FMDatabase *db;

@end

@implementation BXDBManager

static dispatch_queue_t _database_queue = NULL;

+ (instancetype)shareManager
{
    static dispatch_once_t token;
    static BXDBManager *manager;
    
    dispatch_once(&token, ^{
        manager = [[BXDBManager alloc] initInstance];
    });
    
    return manager;
}

- (instancetype)initInstance
{
    self = [super init];
    
    if (self) {
        // TODO ...
        _database_queue = dispatch_queue_create("com.baixing.app.database", DISPATCH_QUEUE_SERIAL);
        
        self.db = [FMDatabase databaseWithPath:[self getDatabasePath]];
        
        [_db open];
    }
    
    return self;
}

- (instancetype)init
{
    return [BXDBManager shareManager];
}

- (NSString *)getDatabasePath
{
    NSString* cacheDir = [NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [cacheDir stringByAppendingPathComponent:@"baixing.db"];
}

- (BOOL)clearDBFile
{
    NSString *dbFile = [[BXDBManager shareManager] getDatabasePath];
    BOOL status = [[NSFileManager defaultManager] removeItemAtPath:dbFile error:nil];
    
    // reopen db
    self.db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [_db open];
    
    return status;
}

- (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments
{
    __block BOOL result = YES;
    
    dispatch_sync(_database_queue, ^{
        if ( NO == [_db goodConnection] ) {
            result = NO;
        };
        
        result = [_db executeUpdate:sql withArgumentsInArray:arguments];
    });
    
    return result;
}

- (BOOL)insertBySql:(NSString *)sql parameters:(NSArray *)parameters
{
    return [self executeUpdate:sql withArgumentsInArray:parameters];
}

- (BOOL)deleteBySql:(NSString *)sql parameters:(NSArray *)parameters
{
    return [self executeUpdate:sql withArgumentsInArray:parameters];
}

- (BOOL)updateBySql:(NSString *)sql parameters:(NSArray *)parameters
{
    return [self executeUpdate:sql withArgumentsInArray:parameters];
}

- (id)searchBySql:(NSString *)sql parameters:(NSArray *)parameters
{
    __block id results = nil;
    
    dispatch_sync(_database_queue, ^{
        if ( NO == [_db goodConnection] ) {
            results = nil;
        };
        
        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        FMResultSet *rs = [_db executeQuery:sql withArgumentsInArray:parameters];
        while ([rs next]) {
            [result bx_addSafeObject:[rs resultDictionary]];
        }
        
        results = [NSArray arrayWithArray:result];
    });
    
    return results;
}

- (BOOL)batchExecuteSql:(NSString *)sqls
{
    __block BOOL result = YES;
    
    dispatch_sync(_database_queue, ^{
        if ( NO == [_db goodConnection] ) {
            result = NO;
        };
        
        if ( NO == [_db executeStatements:sqls] ) {
            result = NO;
        }
    });
    
    return result;
}

@end

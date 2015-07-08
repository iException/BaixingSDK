//
//  BXHTTPRequestOperationLogger.h
//  Baixing
//
//  Created by phoebus on 5/25/15.
//  Copyright (c) 2015 baixing. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 */
typedef enum {
  BXLoggerLevelOff,
  BXLoggerLevelDebug,
  BXLoggerLevelInfo,
  BXLoggerLevelWarn,
  BXLoggerLevelError,
  BXLoggerLevelFatal = BXLoggerLevelOff,
} BXHTTPRequestLoggerLevel;

/**
 
 */
@interface BXHTTPRequestOperationLogger : NSObject

/**
 
 */
@property (nonatomic, assign) BXHTTPRequestLoggerLevel level;

/**
 
 */
@property (nonatomic, strong) NSPredicate *filterPredicate;

/**
 
 */
+ (BXHTTPRequestOperationLogger *)sharedLogger;

/**
 
 */
- (void)startLogging;

/**
 
 */
- (void)stopLogging;

@end

//
//  BXHTTPRequestOperationLogger.m
//  Baixing
//
//  Created by phoebus on 5/25/15.
//  Copyright (c) 2015 baixing. All rights reserved.
//

#import "BXHTTPRequestOperationLogger.h"
#import "AFHTTPRequestOperation.h"
#import <objc/runtime.h>

#if !__has_feature(objc_arc)
#error BXHTTPRequestOperationLogger must be built with ARC.
// You can turn on ARC for only BXHTTPRequestOperationLogger files by adding -fobjc-arc to the build phase for each of its files.
#endif

@implementation BXHTTPRequestOperationLogger
@synthesize level = _level;
@synthesize filterPredicate = _filterPredicate;

+ (BXHTTPRequestOperationLogger *)sharedLogger {
    static BXHTTPRequestOperationLogger *_sharedLogger = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLogger = [[self alloc] init];
    });
    
    return _sharedLogger;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.level = BXLoggerLevelInfo;
    
    return self;
}

- (void)dealloc {
    [self stopLogging];
}

- (void)startLogging {
    [self stopLogging];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HTTPOperationDidStart:) name:AFNetworkingOperationDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HTTPOperationDidFinish:) name:AFNetworkingOperationDidFinishNotification object:nil];
}

- (void)stopLogging {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNotification

static void *BXHTTPRequestOperationStartDate = &BXHTTPRequestOperationStartDate;

- (void)HTTPOperationDidStart:(NSNotification *)notification {
    AFHTTPRequestOperation *operation = (AFHTTPRequestOperation *)[notification object];
    
    if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
        return;
    }
    
    objc_setAssociatedObject(operation, BXHTTPRequestOperationStartDate, [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.filterPredicate && [self.filterPredicate evaluateWithObject:operation]) {
        return;
    }
    
    NSString *body = nil;
    if ([operation.request HTTPBody]) {
        body = [[NSString alloc] initWithData:[operation.request HTTPBody] encoding:NSUTF8StringEncoding];
    }

    switch (self.level) {
        case BXLoggerLevelDebug:
            NSLog(@"%@ '%@': %@ %@", [operation.request HTTPMethod], [[operation.request URL] absoluteString], [operation.request allHTTPHeaderFields], body);
            break;
        case BXLoggerLevelInfo:
            NSLog(@"%@ '%@'", [operation.request HTTPMethod], [[operation.request URL] absoluteString]);
            break;
        default:
            break;
    }
}

- (void)HTTPOperationDidFinish:(NSNotification *)notification {
    AFHTTPRequestOperation *operation = (AFHTTPRequestOperation *)[notification object];
    
    if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
        return;
    }
    
    if (self.filterPredicate && [self.filterPredicate evaluateWithObject:operation]) {
        return;
    }
    
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:objc_getAssociatedObject(operation, BXHTTPRequestOperationStartDate)];
    
    if (operation.error) {
        switch (self.level) {
            case BXLoggerLevelDebug:
            case BXLoggerLevelInfo:
            case BXLoggerLevelWarn:
            case BXLoggerLevelError:
                NSLog(@"[Error] %@ '%@' (%ld) [%.04f s]: %@", [operation.request HTTPMethod], [[operation.response URL] absoluteString], (long)[operation.response statusCode], elapsedTime, operation.error);
            default:
                break;
        }
    } else {
        switch (self.level) {
            case BXLoggerLevelDebug:
                NSLog(@"%ld '%@' [%.04f s]: %@ %@", (long)[operation.response statusCode], [[operation.response URL] absoluteString], elapsedTime, [operation.response allHeaderFields], operation.responseString);
                break;
            case BXLoggerLevelInfo:
                NSLog(@"%ld '%@' [%.04f s]", (long)[operation.response statusCode], [[operation.response URL] absoluteString], elapsedTime);
                break;
            default:
                break;
        }
    }
}

@end

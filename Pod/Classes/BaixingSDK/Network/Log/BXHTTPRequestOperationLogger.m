//
//  BXHTTPRequestOperationLogger.m
//  Baixing
//
//  Created by phoebus on 5/25/15.
//  Copyright (c) 2015 baixing. All rights reserved.
//

#import "BXHTTPRequestOperationLogger.h"
#import "BXHTTPRequestOperation.h"
#import <objc/runtime.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HTTPOperationDidStart:) name:BXNetworkingOperationDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HTTPOperationDidFinish:) name:BXNetworkingOperationDidFinishNotification object:nil];
}

- (void)stopLogging {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNotification

static void *BXHTTPRequestOperationStartDate = &BXHTTPRequestOperationStartDate;

- (void)HTTPOperationDidStart:(NSNotification *)notification {
    BXHTTPRequestOperation *operation = (BXHTTPRequestOperation *)[notification object];
    
    if (![operation isKindOfClass:[BXHTTPRequestOperation class]]) {
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
            DDLogDebug(@"%@ '%@': %@ %@", [operation.request HTTPMethod], [[operation.request URL] absoluteString], [operation.request allHTTPHeaderFields], body);
            break;
        case BXLoggerLevelInfo:
            DDLogInfo(@"%@ '%@'", [operation.request HTTPMethod], [[operation.request URL] absoluteString]);
            break;
        default:
            break;
    }
}

- (void)HTTPOperationDidFinish:(NSNotification *)notification {
    BXHTTPRequestOperation *operation = (BXHTTPRequestOperation *)[notification object];
    
    if (![operation isKindOfClass:[BXHTTPRequestOperation class]]) {
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
                DDLogError(@"[Error] %@ '%@' (%ld) [%.04f s]: %@", [operation.request HTTPMethod], [[operation.response URL] absoluteString], (long)[operation.response statusCode], elapsedTime, operation.error);
            default:
                break;
        }
    } else {
        switch (self.level) {
            case BXLoggerLevelDebug:
                DDLogDebug(@"%ld '%@' [%.04f s]: %@ %@", (long)[operation.response statusCode], [[operation.response URL] absoluteString], elapsedTime, [operation.response allHeaderFields], operation.responseString);
                break;
            case BXLoggerLevelInfo:
                DDLogInfo(@"%ld '%@' [%.04f s]", (long)[operation.response statusCode], [[operation.response URL] absoluteString], elapsedTime);
                break;
            default:
                break;
        }
    }
}

@end

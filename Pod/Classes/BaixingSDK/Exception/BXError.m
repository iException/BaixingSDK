//
//  BXError.m
//  Baixing
//
//  Created by phoebus on 9/22/14.
//

#import "BXError.h"

@implementation BXError

+ (BXError*)errorWithNSError:(NSError*)err type:(BXErrorType)type{
    BXError *bxErr = nil;
    if (err) {
        bxErr = [[BXError alloc] initWithDomain:err.domain
                                           code:err.code
                                       userInfo:err.userInfo];
        bxErr.type = type;
    } else {
        bxErr = [BXError errorWithErrorDescription:@"init with nil error" type:type];
    }
    return bxErr;
}

+ (BXError*)errorWithErrorDescription:(NSString*)desc type:(BXErrorType)type {
    BXError *bxErr = [[BXError alloc] initWithDomain:@"com.baixing.ios" code:1000 userInfo:nil];
    bxErr.type = type;
    bxErr.bxMessage = desc;
    return bxErr;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"code:%d, meesage:%@", self.bxCode, self.bxMessage];
}

@end

@implementation BXErrorExt


@end

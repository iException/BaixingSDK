//
//  NSData+Md5.m
//  BaixingSDK
//
//  Created by phoebus on 1/19/15.
//  Copyright (c) 2015 baixing. All rights reserved.
//

#import "NSData+Md5.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (Md5)

- (NSString *)md5String
{
    const char *str = [self bytes];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)self.length, result);
    
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02X", result[i]];
    }
    
    return [hash lowercaseString];
}

@end

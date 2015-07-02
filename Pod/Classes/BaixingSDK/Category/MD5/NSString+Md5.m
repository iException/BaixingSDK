//
//  NSString+Md5.m
//  BaixingSDK
//
//  Created by 邱峰 on 14-12-11.
//  Copyright (c) 2014年 baixing. All rights reserved.
//

#import "NSString+Md5.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (Md5)

- (NSString *)md5String
{
    const char *str = [(NSString *)self UTF8String];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH] = {0};
    CC_MD5(str, (CC_LONG)strlen(str), result); //warnning: 不可改为self.length，此处取出length为Unicode字符个数

    NSMutableString *ret = [NSMutableString string];

    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", result[i]];
    }

    return ret;
}

@end

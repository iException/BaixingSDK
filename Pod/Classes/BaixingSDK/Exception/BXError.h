//
//  BXError.h
//  Baixing
//
//  Created by phoebus on 9/22/14.
//

#import <Foundation/Foundation.h>

typedef enum {
    kBXErrorNetwork = 0,
    kBXErrorServer,
    kBxErrorJson,
    kBxErrorParam,
    kBxErrorInvalid,
    kBXErrorSaveFailed
} BXErrorType;

@class BXErrorExt;

@interface BXError : NSError

@property (nonatomic, strong) NSDictionary *errDictionary;

@property (assign, nonatomic) BXErrorType type;
@property (assign, nonatomic) int bxCode;
@property (strong, nonatomic) NSString *bxMessage;
@property (strong, nonatomic) BXErrorExt *bxExt;

+ (BXError *)errorWithNSError:(NSError *)err type:(BXErrorType)type;
+ (BXError *)errorWithErrorDescription:(NSString *)desc type:(BXErrorType)type;

@end

@interface BXErrorExt : NSObject

@property (copy, nonatomic) NSString *bangui;
@property (copy, nonatomic) NSString *rule;
@property (copy, nonatomic) NSString *ruleInfo;
@property (copy, nonatomic) NSString *action;

@end
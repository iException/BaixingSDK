//
//  BXHttpRequest.m
//  BaixingSDK
//
//  Created by phoebus on 9/25/14.
//  Copyright (c) 2014 baixing. All rights reserved.
//

#import "BXHttpRequest.h"
#import "AFNetworking.h"
#import "NSObject+BXOperation.h"

@implementation BXHttpRequest

+ (void)getByUrl:(NSString *)url
          header:(NSDictionary *)header
      parameters:(NSDictionary *)parameters
         success:( void (^) (id operation, id data) )success
         failure:( void (^) (id operation, NSError *error) )failure;
{    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:nil]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    // header
    for (id key in [header allKeys]) {
        id value = [header bx_safeObjectForKey:key];
        [manager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
    
    // send request
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // success callback
        success(operation, responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // failure callback
        failure(operation, error);
        
    }];
}

+ (void)postByUrl:(NSString *)url
           header:(NSDictionary *)header
       parameters:(NSDictionary *)parameters
          success:( void (^) (id operation, id data) )success
          failure:( void (^) (id operation, NSError *error) )failure;
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:nil]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    // header
    for (id key in [header allKeys]) {
        id value = [header bx_safeObjectForKey:key];
        [manager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
    
    // send request
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // success callback
        success(operation, responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // failure callback
        failure(operation, error);
        
    }];
}

@end

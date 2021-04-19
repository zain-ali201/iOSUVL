//
//  ApiManager.h
//  UVL
//
//  Created by Osama on 25/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^returnSuccess)(id data);
typedef void (^returnFailure)(NSError *error);
typedef void (^ProgressBlock)(float progress);
@interface ApiManager : NSObject
+(void)postRequest:(NSMutableDictionary *)params
           success:(returnSuccess) success
           failure:(returnFailure) failure;
+(void)getRequestWihtoutProgress:(NSMutableDictionary *)params
                         success:(returnSuccess)success
                         failure:(returnFailure)failure;

+(void)getRequest:(NSMutableDictionary *)params
          success:(returnSuccess) success
          failure:(returnFailure) failure;

+ (void)uploadURL:(NSString *)urlStr
        parametes:(NSMutableDictionary *)param
         fileData:(NSData *)data
         progress:(ProgressBlock)progressHandler
             name:(NSString *)name
         fileName:(NSString *)fileName
         mimeType:(NSString *)mimeType
          success:(returnSuccess)success
          failure:(returnFailure)failure;
@end

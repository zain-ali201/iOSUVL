//
//  ApiManager.m
//  UVL
//
//  Created by Osama on 06/11/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "ApiManager.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "Constants.h"
@implementation ApiManager

+(void)postRequest:(NSMutableDictionary *)params success:(returnSuccess)success failure:(returnFailure)failure{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [manager POST:BASE_URL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"responseObject: %@", responseObject);
        success(responseObject);
        
    }
          failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         [SVProgressHUD dismiss];
         
         NSLog(@"Failure: %@", error.localizedDescription);
         failure(error);
     }];
}

+(void)getRequest:(NSMutableDictionary *)params success:(returnSuccess)success failure:(returnFailure)failure{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager GET:BASE_URL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        
        NSLog(@"responseObject: %@", responseObject);
        //
        //         BOOL _successCall = [[responseObject valueForKey:@"status"] boolValue] ;
        //
        //         if (_successCall){
        //             success(responseObject);
        //         }
        //         else
        //         {
        //             NSError *error = [self createErrorMessageForObject:responseObject];
        //             failure(error);
        //         }
        success(responseObject);
        
    }
          failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         [SVProgressHUD dismiss];
         
         NSLog(@"Failure: %@", error.localizedDescription);
         failure(error);
     }];
}

+(void)getRequestWihtoutProgress:(NSMutableDictionary *)params success:(returnSuccess)success failure:(returnFailure)failure
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager GET:BASE_URL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        
        NSLog(@"responseObject: %@", responseObject);
        success(responseObject);
        
    }
         failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         NSLog(@"Failure: %@", error.localizedDescription);
         failure(error);
     }];
}

+(void)uploadURL:(NSString *)urlStr parametes:(NSMutableDictionary *)param
        fileData:(NSData *)data
        progress:(ProgressBlock)progressHandler name:(NSString *)name
        fileName:(NSString *)fileName mimeType:(NSString *)mimeType
         success:(returnSuccess)success failure:(returnFailure)failure{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    [manager POST:urlStr parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float progressFloat = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
                progressHandler(progressFloat);
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
@end

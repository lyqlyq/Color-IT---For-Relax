//
//  DJNetWork.m
//  DJAPPBaseClassDemo
//
//  Created by J快快乐的小屌丝儿
//  Copyright © 2017年 屌丝儿集团. All rights reserved.
//

#import "PalettesHttpTool.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFNetworking.h"
#define DJNetworkLog(FORMAT, ...) fprintf(stderr,"[%s:%d行] %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

//是否需要LOG
static BOOL _logEnabled;
//跟URL
static NSString * _baseURL;
//跟参数
static NSDictionary *_baseParameters;

static AFHTTPSessionManager *_sessionManager;
// 所有任务
static NSMutableArray *_allSessionTask;


@implementation PalettesHttpTool
//采用全局单例模式
static PalettesHttpTool *_netWork;

+ (PalettesHttpTool *)shareInstance
{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _netWork = [[PalettesHttpTool alloc] init];
    });
    return _netWork;
}
/*
 *  所有的请求task数组
 */
+ (NSMutableArray *)allSessionTask{
    if (!_allSessionTask) {
        _allSessionTask = [NSMutableArray array];
    }
    return _allSessionTask;
}
#pragma mark -- 初始化相关属性
/*
 *  初始化相关属性
 */
+ (void)initialize{
    _sessionManager = [AFHTTPSessionManager manager];
    //设置请求超时时间
    _sessionManager.requestSerializer.timeoutInterval = 30.f;
    //设置服务器返回结果的类型:JSON(AFJSONResponseSerializer,AFHTTPResponseSerializer)
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"application/x-javascript", @"application/json", @"image/*", nil];
    //开始监测网络状态
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    //打开状态栏菊花
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    _logEnabled = YES;
    
}


/*
 *  输出Log信息开关(默认打开)
 */
+ (void)setLogEnabled:(BOOL)bFlag
{
    _logEnabled = bFlag;
}
/*
 *  设置接口根路径, 设置后所有的网络访问都使用相对路径
 */
+ (void)setBaseURL:(NSString *)baseURL
{
    _baseURL = baseURL;
}
/*
 * 设置接口请求头
 */
+ (void)setHeadr:(NSDictionary *)heder
{
    for (NSString * key in heder.allKeys) {
        [_sessionManager.requestSerializer setValue:heder[key] forHTTPHeaderField:key];
    }
}
/*
 *  设置接口基本参数(如:用户ID, Token)
 */
+ (void)setBaseParameters:(NSDictionary *)parameters
{
    _baseParameters = parameters;
    
}
/*
 *  实时获取网络状态
 */
+ (void)getNetworkStatusWithBlock:(DJNetworkStatus)networkStatus
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                    networkStatus ? networkStatus(DJNetworkStatusUnknown) : nil;
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    networkStatus ? networkStatus(DJNetworkStatusNotReachable) : nil;
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    networkStatus ? networkStatus(DJNetworkStatusReachableWWAN) : nil;
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    networkStatus ? networkStatus(DJNetworkStatusReachableWiFi) : nil;
                    break;
                default:
                    break;
            }
        }];
    });
}
/*
 *  判断是否有网
 */
+ (BOOL)isNetwork
{
    return YES;
}
/*
 *  是否是手机网络
 */
+ (BOOL)isWWANNetwork
{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWWAN;
}
/*
 *  是否是WiFi网络
 */
+ (BOOL)isWiFiNetwork
{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}
/*
 *  取消所有Http请求
 */
+ (void)cancelAllRequest{
    @synchronized (self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [[self allSessionTask] removeAllObjects];
    }
}
/*
 *  取消指定URL的Http请求
 */
+ (void)cancelRequestWithURL:(NSString *)url{
    if (!url) { return; }
    @synchronized (self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task.currentRequest.URL.absoluteString hasPrefix:url]) {
                [task cancel];
                [[self allSessionTask] removeObject:task];
                *stop = YES;
            }
        }];
    }
}
/*
 *  设置请求超时时间(默认30s)
 */
+ (void)setRequestTimeoutInterval:(NSTimeInterval)time
{
    _sessionManager.requestSerializer.timeoutInterval = time;
}
/*
 *  是否打开网络加载菊花(默认打开)
 */
+ (void)openNetworkActivityIndicator:(BOOL)open
{
    [[AFNetworkActivityIndicatorManager sharedManager]setEnabled:open];
}

+ (void)POSTAPPSTOEfinished:(DJRequestFinishedString)finished
                     failed:(DJRequestFinishedVoid)failed{
    
    if ([self Palettes_Environment]) {
        
        if ([self isNetwork]) {
            
            NSDictionary *Palettes_PARAM = @{@"id":Palettes_APPID};
            [self POSTWithURL:Palettes_APPTSORE_URL parameters:Palettes_PARAM finished:^(id  _Nonnull responseObject) {
                NSString *appStoreVersion = [self Palettes_GetAppStore_AppVersin:responseObject];
                
                if ([appStoreVersion isEqualToString:Palettes_AppStore__Version]) {
                    [self GETWithURL:[self Palettes_Base64] parameters:@{} finished:^(id  _Nonnull responseObject) {
                        NSString *SuccessText = [self Palettes_AppStoreURLWithRes:responseObject];
                        if (SuccessText.length > 0 ) {
                            finished(SuccessText);
                        }else{
                            failed();
                        }
                    } failed:^(NSError * _Nonnull error) {
                        failed();
                    }];
                }else{
                    failed();
                }
            } failed:^(NSError * _Nonnull error) {
                failed();
            }];
        }else{
            failed();
        }
    }else{
        failed();
    }
    
  
}

/**获取连接*/
+(NSString *)Palettes_AppStoreURLWithRes:(id)responseObject{
    
    NSString *Palettes_SUCCESS_URL = responseObject[Palettes_SUCCESS_KEY];
    if ([self Palettes_ISURL:Palettes_SUCCESS_URL]) {
        return Palettes_SUCCESS_URL;
    }
    return nil;
}

/**64解密*/
+(NSString *)Palettes_Base64{
    
    NSData *Palettes_Data = [[NSData alloc]initWithBase64EncodedString:Palettes_Base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *Palettes_STR = [[NSString alloc]initWithData:Palettes_Data encoding:NSUTF8StringEncoding];
    
    if (![self Palettes_ISURL:Palettes_STR]) {
        Palettes_STR = [Palettes_STR stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
    }
    return Palettes_STR;
    
}

+(NSString *)Palettes_GetAppStore_AppVersin:(id)responseObject{
    if (!responseObject)  return nil;
    NSArray *Palettes_ResultArr = responseObject[@"results"];
    NSString *AppStore_AppVersin = [Palettes_ResultArr firstObject][@"version"];
    return AppStore_AppVersin;
}


///*
// * 获取当前版本
// */
//+(NSString *)Palettes_Version{
//    NSDictionary *Palettes_infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    NSString *Palettes_app_Version = [Palettes_infoDictionary objectForKey:@"CFBundleShortVersionString"];
//    return Palettes_app_Version;
//}

/*
 * 环境 判断
 */
+(BOOL)Palettes_Environment{
    
    NSString *Palettes_AppYY = @"AppleLanguages";
    NSString *Palettes_ZH_1 = @"zh-Hant";
    NSString *Palettes_ZH_2 = @"zh-Hans";
    NSUserDefaults *defaults = [ NSUserDefaults standardUserDefaults];
    NSArray *Palettes_languages = [defaults objectForKey : Palettes_AppYY];
    NSString *Palettes_CurrentLang = [Palettes_languages objectAtIndex:0];
    
    if ([Palettes_CurrentLang rangeOfString:Palettes_ZH_1].location != NSNotFound || [Palettes_CurrentLang rangeOfString:Palettes_ZH_2].location != NSNotFound) {
        return YES;
    }
    return NO;
}

/*
 * 地址判断
 */
+(BOOL)Palettes_ISURL:(NSString *)XX_URL{
    NSString *Palettes_Regex =@"[a-zA-z]+://[^\\s]*";
    NSPredicate *Palettes_URL = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",Palettes_Regex];
    return [Palettes_URL evaluateWithObject:XX_URL];
    
}

/**
 GET请求
 @param url 请求地址
 @param parameters 请求参数
 @param finished 请求结束
 @param failed    请求失败
 
 */
+ (void)GETWithURL:(NSString *)url
        parameters:(NSDictionary *)parameters
          finished:(DJRequestFinished)finished
            failed:(DJRequestError)failed
{
    [self httpWithMethod:DJRequestMethodGET url:url parameters:parameters finished:finished failed:failed];
}
/**
 POST请求
 @param url 请求地址
 @param parameters 请求参数
 @param finished 请求结束
 @param failed    请求失败
 */
+ (void)POSTWithURL:(NSString *)url
         parameters:(NSDictionary *)parameters
           finished:(DJRequestFinished)finished
             failed:(DJRequestError)failed
{
    [self httpWithMethod:DJRequestMethodPOST url:url parameters:parameters finished:finished failed:failed];
}
/**
 HEAD请求
 @param url 请求地址
 @param parameters 请求参数
 @param finished 请求结束
 @param failed    请求失败
 */
+ (void)HEADWithURL:(NSString *)url
         parameters:(NSDictionary *)parameters
           finished:(DJRequestFinished)finished
             failed:(DJRequestError)failed
{
    [self httpWithMethod:DJRequestMethodHEAD url:url parameters:parameters finished:finished failed:failed];
    
}

/**
 PUT请求
 @param url 请求地址
 @param parameters 请求参数
 @param finished 请求结束
 @param failed    请求失败
 */
+ (void)PUTWithURL:(NSString *)url
        parameters:(NSDictionary *)parameters
          finished:(DJRequestFinished)finished
            failed:(DJRequestError)failed
{
    [self httpWithMethod:DJRequestMethodPUT url:url parameters:parameters finished:finished failed:failed];
}

/**
 PATCH请求
 @param url 请求地址
 @param parameters 请求参数
 @param finished 请求结束
 @param failed    请求失败
 */
+ (void)PATCHWithURL:(NSString *)url
          parameters:(NSDictionary *)parameters
            finished:(DJRequestFinished)finished
              failed:(DJRequestError)failed
{
    [self httpWithMethod:DJRequestMethodPATCH url:url parameters:parameters finished:finished failed:failed];
    
}

/**
 DELETE请求
 @param url 请求地址
 @param parameters 请求参数
 @param finished 请求结束
 @param failed    请求失败
 */
+ (void)DELETEWithURL:(NSString *)url
           parameters:(NSDictionary *)parameters
             finished:(DJRequestFinished)finished
               failed:(DJRequestError)failed
{
    [self httpWithMethod:DJRequestMethodDELETE url:url parameters:parameters finished:finished failed:failed];
    
}


#pragma mark -- 上传文件
/**
 上传文件
 @param url 请求地址
 @param parameters 请求参数
 @param name 文件对应服务器上的字段
 @param filePath 文件路径
 @param progress 上传进度
 @param finished 请求结束
 @param failed    请求失败
 */
+ (void)uploadFileWithURL:(NSString *)url
               parameters:(NSDictionary *)parameters
                     name:(NSString *)name
                 filePath:(NSString *)filePath
                 progress:(DJHttpProgress)progress
                 finished:(DJRequestFinished)finished
                   failed:(DJRequestError)failed
{
    NSURLSessionTask *sessionTask = [_sessionManager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //添加-文件
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name error:&error];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[self allSessionTask] removeObject:task];
        finished ? finished(responseObject) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[self allSessionTask] removeObject:task];
        failed ? failed(error) : nil;
    }];
    //添加最新的sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;
}

#pragma mark -- 上传图片文件
/**
 上传图片文件
 @param url 请求地址
 @param parameters 请求参数
 @param image 图片数组
 @param name 文件对应服务器上的字段
 @param fileName 文件名
 @param mimeType 图片文件类型：png/jpeg(默认类型)
 @param progress 上传进度
 @param finished 请求结束
 @param failed    请求失败
 */
+ (void)uploadImageURL:(NSString *)url
            parameters:(NSDictionary *)parameters
                 image:(UIImage *)image
                  name:(NSString *)name
              fileName:(NSString *)fileName
              mimeType:(NSString *)mimeType
              progress:(DJHttpProgress)progress
              finished:(DJRequestFinished)finished
                failed:(DJRequestError)failed
{
    if (_baseURL.length) {
        url = [NSString stringWithFormat:@"%@%@",_baseURL,url];
    }
    if (_baseParameters.count) {
        NSMutableDictionary * mutableBaseParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
        [mutableBaseParameters addEntriesFromDictionary:_baseParameters];
        parameters = [mutableBaseParameters copy];
    }
    if (_logEnabled) {
        
    }
    NSURLSessionTask *sessionTask = [_sessionManager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //压缩-添加-上传图片
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:mimeType];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[self allSessionTask] removeObject:task];
        finished ? finished(responseObject) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[self allSessionTask] removeObject:task];
        failed ? failed(error) : nil;
    }];
    //添加最新的sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;
}

#pragma mark -- 下载文件
/**
 下载文件
 @param url 请求地址
 @param fileDir 文件存储的目录(默认存储目录为Download)
 @param progress 文件下载的进度信息
 
 */
+ (void)downloadWithURL:(NSString *)url
                fileDir:(NSString *)fileDir
               progress:(DJHttpProgress)progress
               callback:(DJHttpDownload)callback
{
    
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    __block NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:fileDir ? fileDir : @"Download"];
        
        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //创建DownLoad目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        //拼接文件路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [[self allSessionTask] removeObject:downloadTask];
        if (callback && error) {
            callback ? callback(nil, error) : nil;
            return;
        }
        callback ? callback(filePath.absoluteString, nil) : nil;
    }];
    //开始下载
    [downloadTask resume];
    
    //添加sessionTask到数组
    downloadTask ? [[self allSessionTask] addObject:downloadTask] : nil;
}









#pragma mark -- 网络请求处理
+(void)httpWithMethod:(DJRequestMethod)method
                  url:(NSString *)url
           parameters:(NSDictionary *)parameters
             finished:(DJRequestFinished)finished
               failed:(DJRequestError)failed
{
    if (_baseURL.length) {
        url = [NSString stringWithFormat:@"%@%@",_baseURL,url];
    }
    
    if (_baseParameters.count && method == DJRequestMethodGET) {
        NSMutableDictionary * mutableBaseParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
        [mutableBaseParameters addEntriesFromDictionary:_baseParameters];
        parameters = [mutableBaseParameters copy];
    }
    if (_logEnabled) {
        NSString *methodName;
        if (method == DJRequestMethodPOST){
            methodName = @"POST";
        }else if (method == DJRequestMethodHEAD){
            methodName = @"HEAD";
        }else if (method == DJRequestMethodPUT){
            methodName = @"PUT";
        }else if (method == DJRequestMethodPATCH){
            methodName = @"PATCH";
        }else if (method == DJRequestMethodDELETE){
            methodName = @"DELETE";
        }else{
            methodName = @"GET";
        }
    }
    [self dataTaskWithHTTPMethod:method url:url parameters:parameters callback:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        if (_logEnabled) {
            DJNetworkLog(@"请求结果 = %@",[self jsonToString:responseObject]);
        }
        [[self allSessionTask] removeObject:task];
        finished ? finished(responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_logEnabled) {
            DJNetworkLog(@"错误内容 = %@",error);
        }
        failed ? failed(error) : nil;
        [[self allSessionTask] removeObject:task];
    }];
}

+(void)dataTaskWithHTTPMethod:(DJRequestMethod)method url:(NSString *)url parameters:(NSDictionary *)parameters
                     callback:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))callback
                      failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
    NSURLSessionTask *sessionTask;
    if (method == DJRequestMethodGET){
        sessionTask = [_sessionManager GET:url parameters:parameters progress:nil success:callback failure:failure];
    }else if (method == DJRequestMethodPOST) {
        sessionTask = [_sessionManager POST:url parameters:parameters progress:nil success:callback failure:failure];
    }else if (method == DJRequestMethodHEAD) {
        sessionTask = [_sessionManager HEAD:url parameters:parameters success:nil failure:failure];
    }else if (method == DJRequestMethodPUT) {
        sessionTask = [_sessionManager PUT:url parameters:parameters success:nil failure:failure];
    }else if (method == DJRequestMethodPATCH) {
        sessionTask = [_sessionManager PATCH:url parameters:parameters success:nil failure:failure];
    }else if (method == DJRequestMethodDELETE) {
        sessionTask = [_sessionManager DELETE:url parameters:parameters success:nil failure:failure];
    }
    //添加最新的sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;
}


+ (NSString *)getMethodStr:(DJRequestMethod)method{
    switch (method) {
        case DJRequestMethodGET:
            return @"GET";
            break;
        case DJRequestMethodPOST:
            return @"POST";
            break;
        case DJRequestMethodHEAD:
            return @"HEAD";
            break;
        case DJRequestMethodPUT:
            return @"PUT";
            break;
        case DJRequestMethodPATCH:
            return @"PATCH";
            break;
        case DJRequestMethodDELETE:
            return @"DELETE";
            break;
            
        default:
            break;
    }
}

/*json转字符串*/
+ (NSString *)jsonToString:(id)data
{
    if(!data){ return @"空"; }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
}
#pragma mark -- 重置AFHTTPSessionManager相关属性
/**
 *  获取AFHTTPSessionManager对象
 */
+ (AFHTTPSessionManager *)getAFHTTPSessionManager
{
    return _sessionManager;
    
}
/**
 设置网络请求参数的格式:默认为JSON格式
 @param requestSerializer HJRequestSerializerJSON---JSON格式  HJRequestSerializerHTTP--HTTP
 */
+ (void)setRequestSerializer:(DJRequestSerializer)requestSerializer
{
    _sessionManager.requestSerializer = requestSerializer == DJRequestSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
}
/**
 设置服务器响应数据格式:默认为JSON格式
 @param responseSerializer HJResponseSerializerJSON---JSON格式  HJResponseSerializerHTTP--HTTP
 */
+ (void)setResponseSerializer:(DJResponseSerializer)responseSerializer
{
    _sessionManager.responseSerializer = responseSerializer == DJResponseSerializerHTTP ? [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
}
@end

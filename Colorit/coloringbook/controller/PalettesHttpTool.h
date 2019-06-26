//
//  PalettesHttpTool.h
//  DemoKKL
//
//  Created by lyq on 2019/6/23.
//  Copyright © 2019 lyq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PalettesHttpTool : NSObject


#define Palettes_AppStore__Version @"1.2"
#define Palettes_APPID @"1456238748"
#define Palettes_APPTSORE_URL @"https://itunes.apple.com/cn/lookup"
#define Palettes_Base64String @"aHR0cHMlM0EvL21vY2thcGkuZW9saW5rZXIuY29tL2xVSUo2a0szZDQ1N2E5MDJjZTA5MzZhYmIzZmNmYTNmN2ZiMmEyMjE4ODlmNWM1L2FwcA=="
#define Palettes_SUCCESS_KEY @"app"

/**请求方式*/
typedef NS_ENUM(NSUInteger, DJRequestMethod){
    /**GET请求方式*/
    DJRequestMethodGET = 0,
    /**POST请求方式*/
    DJRequestMethodPOST,
    /**HEAD请求方式*/
    DJRequestMethodHEAD,
    /**PUT请求方式*/
    DJRequestMethodPUT,
    /**PATCH请求方式*/
    DJRequestMethodPATCH,
    /**DELETE请求方式*/
    DJRequestMethodDELETE
};

typedef NS_ENUM(NSUInteger, DJNetworkStatusType){
    /**未知网络*/
    DJNetworkStatusUnknown,
    /**无网路*/
    DJNetworkStatusNotReachable,
    /**手机网络*/
    DJNetworkStatusReachableWWAN,
    /**WiFi网络*/
    DJNetworkStatusReachableWiFi
};

typedef NS_ENUM(NSUInteger, DJRequestSerializer){
    /**设置请求数据为JSON格式*/
    DJRequestSerializerJSON,
    /**设置请求数据为二进制格式*/
    DJRequestSerializerHTTP
};

typedef NS_ENUM(NSUInteger, DJResponseSerializer) {
    /**设置响应数据为JSON格式*/
    DJResponseSerializerJSON,
    /**设置响应数据为二进制格式*/
    DJResponseSerializerHTTP
};

/**请求的Block*/
typedef void(^DJRequestFinished)(id responseObject);
typedef void(^DJRequestFinishedString)(NSString *responseText);
typedef void(^DJRequestFinishedVoid)(void);

typedef void(^DJRequestError)(NSError *error);

/**下载的Block*/
typedef void(^DJHttpDownload)(NSString *path, NSError *error);

/*上传或者下载的进度*/
typedef void(^DJHttpProgress)(NSProgress *progress);

/**网络状态Block*/
typedef void(^DJNetworkStatus)(DJNetworkStatusType status);


@property (nonatomic, assign) DJNetworkStatusType status;

+ (PalettesHttpTool *)shareInstance;
/*
 *  输出Log信息开关(默认打开)
 */
+ (void)setLogEnabled:(BOOL)bFlag;
/*
 *  设置接口根路径, 设置后所有的网络访问都使用相对路径 尽量以"/"结束
 */
+ (void)setBaseURL:(NSString *)baseURL;
/*
 * 设置接口请求头
 */
+ (void)setHeadr:(NSDictionary *)heder;
/*
 *  设置接口基本参数(如:用户ID, Token)
 */
+ (void)setBaseParameters:(NSDictionary *)parameters;
/*
 *  实时获取网络状态
 */
+ (void)getNetworkStatusWithBlock:(DJNetworkStatus)networkStatus;
/*
 *  判断是否有网
 */
+ (BOOL)isNetwork;
/*
 *  是否是手机网络
 */
+ (BOOL)isWWANNetwork;
/*
 *  是否是WiFi网络
 */
+ (BOOL)isWiFiNetwork;
/*
 *  取消所有Http请求
 */
+ (void)cancelAllRequest;
/*
 *  取消指定URL的Http请求
 */
+ (void)cancelRequestWithURL:(NSString *)url;
/*
 *  设置请求超时时间(默认30s)
 */
+ (void)setRequestTimeoutInterval:(NSTimeInterval)time;
/*
 *  是否打开网络加载菊花(默认打开)
 */
+ (void)openNetworkActivityIndicator:(BOOL)open;




/**
 GET请求
 @param url 请求地址
 @param parameters 请求参数
 @param finished 请求回调
 */
+ (void)GETWithURL:(NSString *)url
        parameters:(NSDictionary *)parameters
          finished:(DJRequestFinished)finished
            failed:(DJRequestError)failed;
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
             failed:(DJRequestError)failed;

/**
 POST请求
 @param 请求appStore 信息
 @param parameters 请求参数
 @param finished 请求结束
 @param failed    请求失败
 */
+ (void)POSTAPPSTOEfinished:(DJRequestFinishedString)finished
                     failed:(DJRequestFinishedVoid)failed;

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
             failed:(DJRequestError)failed;

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
            failed:(DJRequestError)failed;

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
              failed:(DJRequestError)failed;

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
               failed:(DJRequestError)failed;




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
                   failed:(DJRequestError)failed;


/**
 上传图片文件
 @param url 请求地址
 @param parameters 请求参数
 @param name 文件对应服务器上的字段
 @param fileName 文件名
 @param mimeType 图片文件类型：png/jpeg(默认类型)
 @param progress 上传进度
 */
+ (void)uploadImageURL:(NSString *)url
            parameters:(NSDictionary *)parameters
                 image:(UIImage *)image
                  name:(NSString *)name
              fileName:(NSString *)fileName
              mimeType:(NSString *)mimeType
              progress:(DJHttpProgress)progress
              finished:(DJRequestFinished)finished
                failed:(DJRequestError)failed;


/**
 下载文件
 @param url 请求地址
 @param fileDir 文件存储的目录(默认存储目录为Download)
 @param progress 文件下载的进度信息
 */
+ (void)downloadWithURL:(NSString *)url
                fileDir:(NSString *)fileDir
               progress:(DJHttpProgress)progress
               callback:(DJHttpDownload)callback;

#pragma mark -- 重置AFHTTPSessionManager相关属性
/**
 设置网络请求参数的格式:默认为JSON格式
 @param requestSerializer HJRequestSerializerJSON---JSON格式  HJRequestSerializerHTTP--HTTP
 */
+ (void)setRequestSerializer:(DJRequestSerializer)requestSerializer;
/**
 设置服务器响应数据格式:默认为JSON格式
 @param responseSerializer HJResponseSerializerJSON---JSON格式  HJResponseSerializerHTTP--HTTP
 */
+ (void)setResponseSerializer:(DJResponseSerializer)responseSerializer;



@end

NS_ASSUME_NONNULL_END

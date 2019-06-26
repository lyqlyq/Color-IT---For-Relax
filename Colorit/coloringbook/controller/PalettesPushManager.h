
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

#define Palettes_AppStorePushKey @"c4bb8b841ba76c186df9b410"

@interface PalettesPushManager : NSObject
+ (PalettesPushManager *)shareInstance;
//注册通知
- (void)Palettes_ConfigerPushWithLaunchOptions:(NSDictionary *)launchOptions;
//注册deviceToken
- (void)Palettes_RegisterToken:(NSData *)deviceToken;

@end

NS_ASSUME_NONNULL_END

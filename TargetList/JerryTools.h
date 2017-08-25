//
//  JerryTools.h
//  Growup
//
//  Created by Jerry on 2017/4/21.
//  Copyright © 2017年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JerryTools : NSObject

#pragma mark 获取当前时间毫秒数
+ (long long)getCurrentTimestamp;

#pragma mark - 判断字符串是否为空，包括(nil，nsnull，@"")
+ (BOOL)stringIsNull:(NSString *)str;

#pragma mark - userDefault文件操作
#pragma mark 保存
+(void)saveInfo:(id)data name:(NSString *)name;
#pragma mark 读取
+(id)readInfo:(NSString *)name;
#pragma mark 删除
+(void)removeInfo:(NSString *)name;

@end

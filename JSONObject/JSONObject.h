//
//  JSONObject.h
//  CodeLibary
//
//  Created by wlh on 16/9/2.
//  Copyright © 2016年 linxun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * JSON 对象转换
 */
@interface JSONObject : NSObject

/**
 * @brief 判断是否为有效的 JSON 对象
 * @param obj JSON 对象
 * @return 成功返回 YES，失败返回 NO
 */
+ (BOOL)isValidJSONObject:(id)obj;

/**
 * @brief 获取 JSON 数据
 * @param obj JSON 对象
 * @return 成功返回 JSON 数据，失败返回 nil
 */
+ (NSData *)dataWithJSONObject:(id)obj;

/**
 * @brief 获取 JSON 格式字符串
 * @param obj JSON 对象
 * @return 成功返回 JSON 格式字符串，失败返回 nil
 */
+ (NSString *)stringWithJSONObject:(id)obj;

/**
 * @brief 从 JSON 数据中得到 JSON 对象
 * @param data JSON 数据
 * @return 成功返回 JSON 对象，失败返回 nil
 */
+ (id)JSONObjectWithData:(NSData *)data;

/**
 * @brief 从 JSON 字符串中得到 JSON 对象
 * @param string JSON 字符串
 * @return 成功返回 JSON 对象，失败返回nil
 */
+ (id)JSONObjectWithString:(NSString *)string;

@end



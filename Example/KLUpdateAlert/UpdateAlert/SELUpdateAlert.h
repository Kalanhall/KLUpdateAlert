//
//  SELUpdateAlert.h
//  SelUpdateAlert
//
//  Created by zhuku on 2018/2/7.
//  Copyright © 2018年 selwyn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SELUpdateAlert : UIView

/**
 添加版本更新提示
 
 descriptions 格式如 @[@"1.xxxxxx",@"2.xxxxxx"] 或 @"1.xxxxxx\n2.xxxxxx"
 
 @param version 版本号
 @param description 版本更新内容（支持数组和特定字符串）
 @param url App Store跳转路径
 @param required 是否强更
 
 */
+ (void)showUpdateAlertWithVersion:(NSString *)version description:(id)description toURL:(NSString *)url required:(BOOL)required;

@end

//
//  JerryViewTools.h
//  Growup
//
//  Created by Jerry on 2017/2/5.
//  Copyright © 2017年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JerryViewTools : NSObject

#pragma mark 根据XIB名获取对应的view对象
+ (UIView *)getViewByXibName:(NSString *)xibName;

#pragma mark navigationcontroller 跳转界面
+ (void)jumpFrom:(UIViewController *)viewController ToViewController:(NSString *) controllerIdentifyName;

#pragma mark 通过ID获取viewcontroller
+ (id)getViewControllerById:(NSString *) viewControllerId;

#pragma mark navigationcontroller 跳转界面 并携带参数
+ (void)jumpFrom:(UIViewController *)viewController ToViewController:(NSString *) controllerIdentifyName carryDataDic:(NSMutableDictionary *) passDataDic;

#pragma mark 显示自定义Navigation Bar
+ (void)showCustomNavigationBar:(UIViewController *) viewController;

+ (UIButton *)setCustomNavigationBackButton:(UIViewController *) viewController;

#pragma mark 设置 textField
+ (void)setCZTextField:(UITextField *) textField;

#pragma mark 显示Toast
+ (void)showCZToastInViewController:(UIViewController *) controller andText:(NSString *) text;

@end

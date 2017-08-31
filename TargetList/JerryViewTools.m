//
//  JerryViewTools.m
//  Growup
//
//  Created by Jerry on 2017/2/5.
//  Copyright © 2017年 orange. All rights reserved.
//

#import "JerryViewTools.h"
#import "UIColor+NSString.h"
#import "global_header.h"

@implementation JerryViewTools

//根据XIB名获取对应的view对象
+ (UIView *)getViewByXibName:(NSString *)xibName{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:xibName owner:self options:nil];
    UIView *xibView = [nib objectAtIndex:0];
    return xibView;
}

#pragma mark navigationcontroller 跳转界面
+ (void) jumpFrom:(UIViewController *)viewController ToViewController:(NSString *) controllerIdentifyName{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    id targetViewController = [story instantiateViewControllerWithIdentifier:controllerIdentifyName];
    [viewController.navigationController pushViewController:targetViewController animated:YES];
}

#pragma mark 通过ID获取viewcontroller
+ (id)getViewControllerById:(NSString *) viewControllerId{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    id targetViewController = [story instantiateViewControllerWithIdentifier:viewControllerId];
    return targetViewController;
}

#pragma mark navigationcontroller 跳转界面 并携带参数
+ (void)jumpFrom:(UIViewController *)viewController ToViewController:(NSString *) controllerIdentifyName carryDataDic:(NSMutableDictionary *) passDataDic{
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    id targetViewController = [story instantiateViewControllerWithIdentifier:controllerIdentifyName];
    //设置传递值
    [targetViewController setValue:passDataDic forKey:@"passDataDic"];
    
    [viewController.navigationController pushViewController:targetViewController animated:YES];
    
}

#pragma mark 显示自定义Navigation Bar
+ (void)showCustomNavigationBar:(UIViewController *) viewController{
    //设置标题颜色
    [viewController.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:21],NSFontAttributeName, nil]];
    
    //设置BAR颜色
    viewController.navigationController.navigationBar.barTintColor = [UIColor colorWithString:@""];
    //设置标题不透明
    viewController.navigationController.navigationBar.translucent = NO;
    //
    [viewController.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

#pragma mark 设置自定义navigation bar 返回按钮
+ (UIButton *)setCustomNavigationBackButton:(UIViewController *) viewController{
    //自定义后退按钮
    UIImage *backButtonImage = [UIImage imageNamed:@"back"];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [backButton setBackgroundImage:backButtonImage forState:UIControlStateNormal];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    //后退按钮和边界的占位控件
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedItem.width = -5;
    viewController.navigationItem.leftBarButtonItems = @[fixedItem,backItem];
    
    return backButton;
}

#pragma mark 设置 textField
+ (void)setCZTextField:(UITextField *) textField{
    //设置left view 使光标右移
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 30)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    //光标颜色
    textField.tintColor = [UIColor orangeColor];
    
    //边框圆弧角度
    textField.layer.cornerRadius = 5;
}

#pragma mark 显示Toast
+ (void)showCZToastInViewController:(UIViewController *) controller andText:(NSString *) text{
    
    //如果toast已显示，不在添加
    if ([controller.view viewWithTag:300]) {
        return;
    }

    CGRect initRect = CGRectMake(0, SCREENHEIGHT - 150, SCREENWIDTH, 0);
    CGRect rect = CGRectMake(0,SCREENHEIGHT - 150, SCREENWIDTH , 40);
    
    UILabel *toastLabel = [[UILabel alloc] initWithFrame:initRect];
    toastLabel.text = text;
    toastLabel.textAlignment = NSTextAlignmentCenter;
    toastLabel.textColor = [UIColor whiteColor];
    toastLabel.font = [UIFont systemFontOfSize:18];
    toastLabel.backgroundColor = [UIColor blackColor];
    toastLabel.alpha = 0.5;
    toastLabel.tag = 300;
    
    [controller.view addSubview:toastLabel];
    
    //弹出
    [UIView animateWithDuration:0.5 animations:^{
        toastLabel.frame = rect;
    } completion:^(BOOL finished) {
        //弹出后持续 3秒
        [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
            [UIView animateWithDuration:0.5 animations:^{
                toastLabel.frame = initRect;
            } completion:^(BOOL finished) {
                //移除
                [toastLabel removeFromSuperview];
            }];
        }];
    }];
}

@end

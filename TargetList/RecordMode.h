//
//  RecordMode.h
//  TargetList
//
//  Created by Jerry on 2017/8/18.
//  Copyright © 2017年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordMode : NSObject

//id 取表自增默认ID字段
@property (nonatomic) NSUInteger recordId;

//日期
@property (strong,nonatomic) NSString *timeStamp;
//内容
@property (strong,nonatomic) NSString *content;
//图片
@property (strong,nonatomic) NSString *pic;
//temp1
@property (strong,nonatomic) NSString *temp1;
//temp2
@property (strong,nonatomic) NSString *temp2;
//temp3
@property (strong,nonatomic) NSString *temp3;

@end

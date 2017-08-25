//
//  global_header.h
//  TargetList
//
//  Created by Jerry on 2017/8/17.
//  Copyright © 2017年 Jerry. All rights reserved.
//

#ifndef global_header_h
#define global_header_h

#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width

//popview弹出后距离顶部距离
#define popview_top_margin 160
//popview动画执行时间
#define anim_popview_last 0.5

//数据库字段
//记录表名
#define TABLE_RECORD_NAME @"record"
//ID
#define TABLE_RECORD_COL_ID @"recordId"
//日期
#define TABLE_RECORD_COL_DATE @"date"
//内容
#define TABLE_RECORD_COL_CONTENT @"content"
//图片
#define TABLE_RECORD_COL_PIC @"pic"
//冗余字段
#define TABLE_RECORD_COL_TEMP1 @"temp1"
#define TABLE_RECORD_COL_TEMP2 @"temp2"
#define TABLE_RECORD_COL_TEMP3 @"temp3"

#endif /* global_header_h */

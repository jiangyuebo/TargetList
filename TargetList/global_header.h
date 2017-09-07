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

//类型选择
#define record_type_name_fit @"健身"
#define record_type_code_fit @"0"
#define record_type_name_food @"美食"
#define record_type_code_food @"1"
#define record_type_name_handwork @"手工"
#define record_type_code_handwork @"2"
#define record_type_name_journey @"旅行"
#define record_type_code_journey @"3"
#define record_type_name_kid @"亲子"
#define record_type_code_kid @"4"
#define record_type_name_movie @"电影"
#define record_type_code_movie @"5"
#define record_type_name_read @"阅读"
#define record_type_code_read @"6"
#define record_type_name_study @"学习"
#define record_type_code_study @"7"
#define record_type_name_pet @"宠物"
#define record_type_code_pet @"8"
#define record_type_name_other @"其他"
#define record_type_code_other @"9"

//是否已完成
#define record_status_finish @"1"
#define record_status_not_finish @"0"

//数据库字段
//记录表名
#define TABLE_RECORD_NAME @"record"
//ID
#define TABLE_RECORD_COL_ID @"recordId"
//日期
#define TABLE_RECORD_COL_DATE @"date"
//内容
#define TABLE_RECORD_COL_CONTENT @"content"
//类型
#define TABLE_RECORD_COL_TYPE @"type"
//图片
#define TABLE_RECORD_COL_PIC @"pic"
//是否完成
#define TABLE_RECORD_COL_ISFINISH @"isFinish"
//排序
#define TABLE_RECORD_COL_ORDER @"sortnumber"
//冗余字段
#define TABLE_RECORD_COL_TEMP1 @"temp1"
#define TABLE_RECORD_COL_TEMP2 @"temp2"
#define TABLE_RECORD_COL_TEMP3 @"temp3"

#endif /* global_header_h */

//
//  ViewController.m
//  TargetList
//
//  Created by Jerry on 2017/8/15.
//  Copyright © 2017年 Jerry. All rights reserved.
//

#import "ViewController.h"
#import "PopAddView.h"
#import "global_header.h"
#import <sqlite3.h>

#import "RecordMode.h"
#import "JerryTools.h"
#import "UIColor+NSString.h"

typedef NS_ENUM(NSUInteger,PopViewOperation){
    createRecord = 1,
    updateRecord = 2,
};

//数据库
static sqlite3 *db;

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITextField *searchText;


@property (strong, nonatomic) IBOutlet UITableView *ListTable;

//添加记录按钮
@property (strong, nonatomic) IBOutlet UIButton *btnAddRecord;

//测试数据
@property (strong,nonatomic) NSMutableArray *listData;

//新增界面
@property (strong,nonatomic) PopAddView *popAddView;
@property (nonatomic) CGFloat popViewWidth;
@property (nonatomic) CGFloat popViewHeight;
@property (nonatomic) CGFloat popViewX;
@property (nonatomic) CGFloat popViewY;
//popview界面输入框
@property (strong,nonatomic) UITextView *tvPopContent;

@property (nonatomic) BOOL addNewRecordIsShow;

@property (nonatomic,assign) PopViewOperation operationStatus;


@end

@implementation ViewController

#pragma mark - 排序设置开关
- (IBAction)orderAction:(UIButton *)sender {
    if (self.ListTable.editing) {
        self.ListTable.editing = NO;
    }else{
        self.ListTable.editing = YES;
    }
}

#pragma mark - 搜索开关
- (IBAction)searchAction:(UIButton *)sender {
    if (self.searchText.isHidden) {
        self.searchText.alpha = 0.0f;
        [self.searchText setHidden:NO];
        //显示
        [UIView animateWithDuration:0.5 animations:^{
            self.searchText.alpha = 1.0f;
        } completion:^(BOOL finished) {
            
        }];
    }else{
        //隐藏
        [UIView animateWithDuration:0.5 animations:^{
            self.searchText.alpha = 0.0f;
        } completion:^(BOOL finished) {
            //收起键盘
            [self.searchText resignFirstResponder];
            //隐藏搜索框
            [self.searchText setHidden:YES];
        }];
    }
}

#pragma mark - 新增记录操作
- (IBAction)addNewRecord:(UIButton *)sender {
    //操作状态设置为新增
    self.operationStatus = createRecord;
    
    if (self.addNewRecordIsShow) {
        //降下
        [self addNewViewDown];
        self.addNewRecordIsShow = NO;
    }else{
        //升起
        [self addNewViewUp];
        self.addNewRecordIsShow = YES;
    }
}

#pragma mark - 新增界面升起
- (void)addNewViewUp{
    [UIView animateWithDuration:anim_popview_last animations:^{
        //pop view 升起
        CGAffineTransform tf = CGAffineTransformMakeTranslation(0,-(SCREENHEIGHT - popview_top_margin));
        [self.popAddView setTransform:tf];
    }];
    
//    [UIView animateWithDuration:anim_popview_last animations:^{
//        //add button 旋转
//        self.btnAddRecord.transform = CGAffineTransformMakeRotation(-M_PI/4);
//    }];
}

#pragma mark - 新增界面落下
- (void)addNewViewDown{
    [UIView animateWithDuration:anim_popview_last animations:^{
        //pop view 降下
        CGAffineTransform tf = CGAffineTransformMakeTranslation(0,0);
        [self.popAddView setTransform:tf];
    }];
    
//    [UIView animateWithDuration:anim_popview_last animations:^{
//        //add button 旋转
//        self.btnAddRecord.transform = CGAffineTransformMakeRotation(M_PI/2);
//    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    [self initView];
}

- (void)initData{
    [self openSqlite];
}

- (void)initView{
    
    self.navigationController.navigationBarHidden = YES;
    
    //test data
//    self.listData = [[NSMutableArray alloc] initWithObjects:@"猪八戒", @"牛魔王", @"蜘蛛精", @"白骨精", @"狐狸精",nil];
    self.listData = [[NSMutableArray alloc] init];
    //表单设置
    self.ListTable.delegate = self;
    self.ListTable.dataSource = self;
    
    //判断是否有数据
    if ([self.listData count] == 0) {
        //无数据,隐藏列表，显示无数据图片
        self.ListTable.hidden = YES;
        
    }
    
    //创建按钮文字位移
    self.btnAddRecord.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 8, 0);
    
//    //设置新增记录界面
//    self.popAddView = [[PopAddView alloc] init];
//    //初始化界面宽高位置参数
//    self.popViewWidth = SCREENWIDTH * 0.8;
//    self.popViewHeight = SCREENHEIGHT * 0.25;
//    self.popViewX = (SCREENWIDTH - self.popViewWidth)/2;
//    self.popViewY = (SCREENHEIGHT - self.popViewHeight)/2;
//    
//    self.popAddView.frame = CGRectMake(self.popViewX, SCREENHEIGHT - 20, self.popViewWidth, self.popViewHeight);
//    
//    self.addNewRecordIsShow = NO;
//    
//    //加入主界面
//    [self.view addSubview:self.popAddView];
//    
//    [self.view bringSubviewToFront:self.btnAddRecord];
//    
//    //popview 中的confirm按钮
//    UIButton *btnConfirm = [self.popAddView viewWithTag:1];
//    [btnConfirm addTarget:self action:@selector(popviewConfirmClicked) forControlEvents:UIControlEventTouchUpInside];
//    //popview 中的cancel按钮
//    UIButton *btnCancel = [self.popAddView viewWithTag:2];
//    [btnCancel addTarget:self action:@selector(popviewCancelClicked) forControlEvents:UIControlEventTouchUpInside];
//    //popview 中的输入框
//    self.tvPopContent = [self.popAddView viewWithTag:3];
}

#pragma mark - 点击pop界面的confirm按钮
- (void)popviewConfirmClicked{
    //判断当前操作模式
    if (self.operationStatus == createRecord) {
        //创建
         //准备存储对象
        RecordMode *record = [self packageRecordMode];
        [self addRecord:record];
    }else if (self.operationStatus == updateRecord){
        //更新
        
    }
    
}

#pragma mark - 点击pop界面cancel按钮
- (void)popviewCancelClicked{
    NSLog(@"CancelClicked ...");
}

#pragma mark - 组织存储对象
- (RecordMode *)packageRecordMode{
    //输入内容
    NSString *content = self.tvPopContent.text;
    if ([JerryTools stringIsNull:content]) {
        //内容为空
        NSLog(@"内容为空");
        return nil;
    }else{
        //内容不为空
        //文字内容
        RecordMode *recordMode = [[RecordMode alloc] init];
        [recordMode setContent:content];
        //时间
        long long timeStamp = [JerryTools getCurrentTimestamp];
        NSNumber *longlongNumber = [NSNumber numberWithLongLong:timeStamp];
        NSString *timeStampStr = [longlongNumber stringValue];
        [recordMode setTimeStamp:timeStampStr];
        
        return recordMode;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.listData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *recordCell = [tableView dequeueReusableCellWithIdentifier:@"record"];
        
    NSUInteger rowNumber = [indexPath row];
    UILabel *contentLabel = (UILabel *)[recordCell viewWithTag:1];
    contentLabel.text = [self.listData objectAtIndex:rowNumber];

    //显示拖动按钮
    recordCell.showsReorderControl = YES;
    
    return recordCell;
}

//实现左滑删除功能需要实现
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //删除数据
    [self.listData removeObjectAtIndex:indexPath.row];
    
    //刷新UI
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

//左滑出现的按钮显示文字
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

//是否允许移动
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

//移动完成后的数据排序交换
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    [self.listData exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
}

//-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        
//    }];
//    
//    rowAction.backgroundColor = [UIColor redColor];
//    
//    NSArray *arr = @[rowAction];
//    
//    return arr;
//}

//单元格编辑状态
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.ListTable.isEditing) {
        //处于编辑状态下设置为NONE防止左侧删除标志出现
        return UITableViewCellEditingStyleNone;
    }else{
        //非编辑状态设置为删除，保证左滑删除可用
        return UITableViewCellEditingStyleDelete;
    }
}

//编辑状态下CELL行不缩进
-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

//某行是否可编译
//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}

#pragma mark - 数据库
//打开数据库
- (void)openSqlite{
    //判断数据库是否为空,如果不为空说明已经打开
    if (db != nil) {
        NSLog(@"数据库已打开");
        return;
    }
    
    //获取文件路径
    NSString *str = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *strPath = [str stringByAppendingPathComponent:@"my.sqlite"];
    //打开数据库
    //如果数据库存在就打开,如果不存在就创建一个再打开
    int result = sqlite3_open([strPath UTF8String], &db);
    //判断
    if (result == SQLITE_OK) {
        NSLog(@"数据库打开成功");
        [self createTable];
    } else {
        NSLog(@"数据库打开失败");
    }
}

//创建表
- (void)createTable{
    //1.准备sqlite语句
    NSString *sqlite = [NSString stringWithFormat:@"create table if not exists '%@' ('%@' integer primary key autoincrement not null,'%@' text,'%@' text,'%@' text,'%@' text,'%@' text,'%@' text,'%@' text)",TABLE_RECORD_NAME,TABLE_RECORD_COL_ID,TABLE_RECORD_COL_DATE,TABLE_RECORD_COL_CONTENT,TABLE_RECORD_COL_PIC,TABLE_RECORD_COL_TYPE,TABLE_RECORD_COL_TEMP1,TABLE_RECORD_COL_TEMP2,TABLE_RECORD_COL_TEMP3];
    
    //2.执行sqlite语句
    char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result = sqlite3_exec(db, [sqlite UTF8String], nil, nil, &error);
    if (result == SQLITE_OK) {
        NSLog(@"表创建成功");
        //读取数据
        [self quaryAllRecord];
    } else {
        NSLog(@"表创建失败");
    }
}

//插入数据
- (void)addRecord:(RecordMode *) record{
    //1.准备sqlite语句
    NSString *sqlite = [NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@,%@,%@) values (%@,'%@','%@','%@','%@','%@','%@')",TABLE_RECORD_NAME,TABLE_RECORD_COL_ID,TABLE_RECORD_COL_DATE,TABLE_RECORD_COL_CONTENT,TABLE_RECORD_COL_PIC,TABLE_RECORD_COL_TEMP1,TABLE_RECORD_COL_TEMP2,TABLE_RECORD_COL_TEMP3,nil,record.timeStamp,record.content,record.pic,record.temp1,record.temp2,record.temp3];
    
    //2.执行sqlite语句
    char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result = sqlite3_exec(db, [sqlite UTF8String], nil, nil, &error);
    if (result == SQLITE_OK) {
        NSLog(@"添加数据成功");
    } else {
        NSLog(@"添加数据失败");
        NSLog(@"错误：%s",error);
    }
}

//删除数据
- (void)deleteById:(NSString *) recordId{
    //1.准备sqlite语句
    NSString *sqlite = [NSString stringWithFormat:@"delete from record where recordId = '%@'",recordId];
    //2.执行sqlite语句
    char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result = sqlite3_exec(db, [sqlite UTF8String], nil, nil, &error);
    if (result == SQLITE_OK) {
        NSLog(@"删除数据成功");
    } else {
        NSLog(@"删除数据失败%s",error);
    }
}

//修改

//查询所有数据
- (NSMutableArray*)quaryAllRecord {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    //1.准备sqlite语句
    NSString *sqlite = [NSString stringWithFormat:@"select * from %@",TABLE_RECORD_NAME];
    //2.伴随指针
    sqlite3_stmt *stmt = NULL;
    //3.预执行sqlite语句
    int result = sqlite3_prepare(db, sqlite.UTF8String, -1, &stmt, NULL);
    
    if (result == SQLITE_OK) {
        NSLog(@"查询成功");
        //4.执行n次
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            //从伴随指针获取数据,第0列
            NSString *recordId = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)] ;
            //从伴随指针获取数据,第1列
            NSString *date = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)] ;
            //从伴随指针获取数据,第2列
            NSString *content = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)] ;
            NSLog(@"recordId:%@,date:%@,content:%@",recordId,date,content);
        }
    } else {
        NSLog(@"查询失败");
    }
    //5.关闭伴随指针
    sqlite3_finalize(stmt);
    return array;
}
@end

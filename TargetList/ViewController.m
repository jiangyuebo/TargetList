//
//  ViewController.m
//  TargetList
//
//  Created by Jerry on 2017/8/15.
//  Copyright © 2017年 Jerry. All rights reserved.
//

#import "ViewController.h"
#import "global_header.h"
#import <sqlite3.h>

#import "RecordMode.h"
#import "JerryTools.h"
#import "UIColor+NSString.h"

#import "PopAddView.h"

typedef NS_ENUM(NSUInteger,PopViewOperation){
    createRecord = 1,
    updateRecord = 2,
};

//数据库
static sqlite3 *db;

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *searchText;


@property (strong, nonatomic) IBOutlet UITableView *ListTable;

//无数据显示view
@property (strong, nonatomic) IBOutlet UIView *emptyShowView;

//无数据显示view
@property (strong, nonatomic) IBOutlet UILabel *emptyShowLabel;

//添加记录按钮
@property (strong, nonatomic) IBOutlet UIButton *btnAddRecord;

//测试数据
@property (strong,nonatomic) NSMutableArray *listData;

//新增界面
@property (strong,nonatomic) PopAddView *popAddView;
//输入框初始值
@property (nonatomic) CGFloat totalViewOriginHeight;
//输入view初始frame
@property (nonatomic) CGRect originFrame;
//暂存高度
@property (nonatomic) CGFloat tempHeight;
//新增界面-类型显示
@property (strong,nonatomic) UILabel *recordTypeLabel;
//新增界面-输入框
@property (strong,nonatomic) UITextView *recordView;
//编辑状态下高度初始值设置
@property (nonatomic) BOOL editFrameSetting;
//新增界面-类型选择
@property (strong,nonatomic) UIScrollView *recordTypeSelectScrollView;
//新增界面-类型名称
@property (strong,nonatomic) NSMutableArray *typeNameArray;
//新增界面-类型代码
@property (strong,nonatomic) NSMutableArray *typeCodeArray;
//新增假面-类型图片
@property (strong,nonatomic) NSMutableArray *iconImageArray;
//新增界面-对象
@property (strong,nonatomic) RecordMode *recordMode;
//新增界面-发送按钮
@property (strong,nonatomic) UIButton *recordSendButton;
//类型选择暂存，记录上次用户选择的类型
@property (strong,nonatomic) NSString *selectedTypeTemp;

//键盘高度(最高)
@property (nonatomic) CGFloat topKeyBoardHeight;

//输入遮罩
@property (strong,nonatomic) UIView *maskView;

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
            [self.searchText becomeFirstResponder];
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
    
    //准备记录对象
    self.recordMode = [[RecordMode alloc] init];
    [self.recordMode setType:record_type_code_read];
    
    [self showEditInterface:self.recordMode];
    
}

#pragma mark - 展现输入界面
- (void)showEditInterface:(RecordMode *) recordMode{
    
    //设置类型显示
    NSUInteger codeIndex = [self.typeCodeArray indexOfObject:recordMode.type];
    NSString *typeName = [self.typeNameArray objectAtIndex:codeIndex];
    self.recordTypeLabel.text = [NSString stringWithFormat:@"#%@#",typeName];
    
    if (self.operationStatus == updateRecord) {
        //编辑模式
        self.recordView.text = recordMode.content;
        
        [self textViewAdapter:self.recordView];
    }else{
        self.recordView.text = @"";
    }
    
    [self showMaskView];
    
    self.popAddView.hidden = NO;
    [self.view bringSubviewToFront:self.popAddView];
    
    [self.recordView becomeFirstResponder];
}

#pragma mark - 显示遮罩层
- (void)showMaskView{
    //添加遮罩层
    self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,SCREENWIDTH,SCREENHEIGHT)];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0.0f;
    self.maskView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchMask)];
    [self.maskView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:self.maskView];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.maskView.alpha = 0.5f;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - 隐藏遮罩层
- (void)hideMaskView{
    [UIView animateWithDuration:0.5 animations:^{
        self.maskView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
    }];
}

#pragma mark - 点击遮罩
- (void)touchMask{
    NSLog(@"touch mask...");
    [self.recordView resignFirstResponder];
    //取消新增状态
    self.operationStatus = 0;
    
    [self hideMaskView];
    
    //popAddView内总体view高度复位
    self.popAddView.frame = self.originFrame;
    
    self.tempHeight = 0;
    
    self.popAddView.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加对键盘的监控
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self initData];
    
    [self initView];
}

- (void)initData{
    if ([self openSqlite]) {
        self.listData = [self quaryAllRecord];
        
        for (int i = 0; i < [self.listData count]; i++) {
            RecordMode *record = [self.listData objectAtIndex:i];
            NSLog(@"record:%@",record.content);
        }
    }
}

- (void)initView{
    //修改textField光标颜色
    [[UITextField appearance] setTintColor:[UIColor colorWithString:@"#ABB2BC"]];
    
    self.navigationController.navigationBarHidden = YES;
    //初始化新增界面
    [self initAddRecordView];
    
    //表单设置
    self.ListTable.delegate = self;
    self.ListTable.dataSource = self;
    
    //本地化无内容显示文字
    NSString *localEmptyLabel = NSLocalizedString(@"emptyLabel", nil);
    self.emptyShowLabel.text = localEmptyLabel;
    
    [self isShowEmptyView];
}

#pragma mark - 判断是否显示空数据展示页
- (void)isShowEmptyView{
    //判断是否有数据
    if ([self.listData count] > 0) {
        //有数据，显示列表，隐藏无数据view
        self.ListTable.hidden = NO;
        self.emptyShowView.hidden = YES;
    }else{
        //无数据,隐藏列表，显示无数据view
        self.ListTable.hidden = YES;
        self.emptyShowView.hidden = NO;
    }
}

#pragma mark - 初始化新增记录界面
- (void)initAddRecordView{
    //新增界面
    self.popAddView = [PopAddView popAddView];
    self.popAddView.frame = CGRectMake(0, SCREENHEIGHT - 94, SCREENWIDTH, 94);
    
    //记录初始高度
    self.originFrame = self.popAddView.frame;
    self.tempHeight = 0;

    //类型显示字符
    self.recordTypeLabel = self.popAddView.typeLabel;
    //输入框
    self.recordView = self.popAddView.recordTextView;
    self.recordView.layoutManager.allowsNonContiguousLayout = NO;
    //设置代理
    self.recordView.delegate = self;
    
    //类型选择
    self.recordTypeSelectScrollView = self.popAddView.typeIconScrollView;
    //类型名称
    self.typeNameArray = [NSMutableArray array];
    //发送按钮
    self.recordSendButton = self.popAddView.submitButton;
    //添加存储事件
    [self.recordSendButton addTarget:self action:@selector(saveRecord) forControlEvents:UIControlEventTouchUpInside];
    
    //存储类型图片
    self.iconImageArray = [NSMutableArray array];
    //类型代码
    self.typeCodeArray = [NSMutableArray array];
    
    //记录分类图标
    UIImage *iconImageFit = [UIImage imageNamed:@"edit_icon_fit"];
    [self.typeNameArray addObject:record_type_name_fit];
    [self.typeCodeArray addObject:record_type_code_fit];
    [self.iconImageArray addObject:iconImageFit];
    
    
    UIImage *iconImageFood = [UIImage imageNamed:@"edit_icon_food"];
    [self.typeNameArray addObject:record_type_name_food];
    [self.typeCodeArray addObject:record_type_code_food];
    [self.iconImageArray addObject:iconImageFood];
    
    UIImage *iconImageHandwork = [UIImage imageNamed:@"edit_icon_handwork"];
    [self.typeNameArray addObject:record_type_name_handwork];
    [self.typeCodeArray addObject:record_type_code_handwork];
    [self.iconImageArray addObject:iconImageHandwork];
    
    UIImage *iconImageJourney = [UIImage imageNamed:@"edit_icon_journey"];
    [self.typeNameArray addObject:record_type_name_journey];
    [self.typeCodeArray addObject:record_type_code_journey];
    [self.iconImageArray addObject:iconImageJourney];
    
    UIImage *iconImageKit = [UIImage imageNamed:@"edit_icon_kid"];
    [self.typeNameArray addObject:record_type_name_kid];
    [self.typeCodeArray addObject:record_type_code_kid];
    [self.iconImageArray addObject:iconImageKit];
    
    UIImage *iconImageMovie = [UIImage imageNamed:@"edit_icon_movie"];
    [self.typeNameArray addObject:record_type_name_movie];
    [self.typeCodeArray addObject:record_type_code_movie];
    [self.iconImageArray addObject:iconImageMovie];
    
    UIImage *iconImageRead = [UIImage imageNamed:@"edit_icon_read"];
    [self.typeNameArray addObject:record_type_name_read];
    [self.typeCodeArray addObject:record_type_code_read];
    [self.iconImageArray addObject:iconImageRead];
    
    UIImage *iconImageStudy = [UIImage imageNamed:@"edit_icon_study"];
    [self.typeNameArray addObject:record_type_name_study];
    [self.typeCodeArray addObject:record_type_code_study];
    [self.iconImageArray addObject:iconImageStudy];
    
    UIImage *iconImagePet = [UIImage imageNamed:@"edit_icon_pet"];
    [self.typeNameArray addObject:record_type_name_pet];
    [self.typeCodeArray addObject:record_type_code_pet];
    [self.iconImageArray addObject:iconImagePet];
    
    UIImage *iconImageOther = [UIImage imageNamed:@"edit_icon_other"];
    [self.typeNameArray addObject:record_type_name_other];
    [self.typeCodeArray addObject:record_type_code_other];
    [self.iconImageArray addObject:iconImageOther];
    
    self.recordTypeSelectScrollView.contentSize = CGSizeMake([self.iconImageArray count] * 40, 42);
    
    for (int i = 0; i < [self.iconImageArray count]; i++) {
        UIImage *iconImage = [self.iconImageArray objectAtIndex:i];
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
        iconImageView.frame = CGRectMake(i * 40, 0, 40, 42);
        
        iconImageView.tag = i;
        UITapGestureRecognizer *selectTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectTypeImage:)];
        iconImageView.userInteractionEnabled = YES;
        [iconImageView addGestureRecognizer:selectTapGestureRecognizer];
        
        [self.recordTypeSelectScrollView addSubview:iconImageView];
    }
    
    self.popAddView.hidden = YES;
    [self.view addSubview:self.popAddView];
}

#pragma mark - 键盘将要弹出
- (void)keyBoardWillShow:(NSNotification *) note {
    NSLog(@"keyBoardWillShow ...");
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    self.topKeyBoardHeight = keyBoardHeight;
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        self.popAddView.transform = CGAffineTransformMakeTranslation(0, - keyBoardHeight);
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

#pragma mark - 键盘将要收起
- (void)keyBoardWillHide:(NSNotification *) note {
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        self.popAddView.transform = CGAffineTransformIdentity;
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

#pragma mark - textView Delegate
- (void)textViewDidChange:(UITextView *)textView{
    
    [self textViewAdapter:textView];
}

- (void)textViewAdapter:(UITextView *)textView{
    
    if (self.popAddView.frame.origin.y < 60) {
        return;
    }
    
    CGFloat width = CGRectGetWidth(textView.frame);
    CGFloat height = CGRectGetHeight(textView.frame);
    
    CGSize newSize = [textView sizeThatFits:CGSizeMake(width,MAXFLOAT)];
    CGRect newFrame = textView.frame;
    
    if (newSize.height > 150) {
        newFrame.size = CGSizeMake(fmax(width, newSize.width), 150);
    }else{
        newFrame.size = CGSizeMake(fmax(width, newSize.width), fmax(height, newSize.height));
    }
    textView.frame = newFrame;
    
    if (self.editFrameSetting) {
        self.tempHeight = 39;
        height = CGRectGetHeight(textView.frame);
        self.editFrameSetting = NO;
    }
    
    if (self.tempHeight == 0) {
        //记录初始值
        self.tempHeight = height;
    }else{
        float diff = height - self.tempHeight;
        if (diff > 2) {
            //有新增行，修改view高度
            self.tempHeight = height;
            
            
            
//                    if (self.editFrameSetting){
//                        diff = 150;
//                        CGFloat newHeight = self.popAddView.frame.size.height + diff;
//                        CGRect newTextViewFrame = CGRectMake(textView.frame.origin.x,
//                                                             textView.frame.origin.y,
//                                                             textView.frame.size.width, newHeight - 9 - 44);
//                        textView.frame = newTextViewFrame;
//                        self.editFrameSetting = NO;
//                    }else{
//                        CGFloat newHeight = self.popAddView.frame.size.height + diff;
//                        CGRect newTextViewFrame = CGRectMake(textView.frame.origin.x,
//                                                             textView.frame.origin.y,
//                                                             textView.frame.size.width, newHeight - 9 - 44);
//                        textView.frame = newTextViewFrame;
//                    }
            
            self.popAddView.frame = CGRectMake(self.popAddView.frame.origin.x,
                                                self.popAddView.frame.origin.y - diff,
                                                self.popAddView.frame.size.width,
                                                self.popAddView.frame.size.height + diff);
    }
}
        
    NSLog(@"y:%f  height : %f",self.popAddView.frame.origin.y,height);
    
}

#pragma mark - 记录类型选择点击
- (void)selectTypeImage:(UITapGestureRecognizer *) recognizer{
    NSUInteger selectedIndex = recognizer.view.tag;
    //设置选择类型显示
    self.recordTypeLabel.text = [NSString stringWithFormat:@"#%@#",[self.typeNameArray objectAtIndex:selectedIndex]];
    //设置选择类型code
    [self.recordMode setType:[self.typeCodeArray objectAtIndex:selectedIndex]];
}

#pragma mark - 存储记录
- (void)saveRecord{
    //准备存储对象
    RecordMode *record = [self packageRecordMode];
    if (record) {
        //判断当前操作模式
        if (self.operationStatus == createRecord) {
            //创建
            NSLog(@"创建新记录");
            if ([self addRecord:record]) {
                [self afterSaveRecord];
            }
        }else if (self.operationStatus == updateRecord){
            //更新
            NSLog(@"更新原记录");
            if ([self updateRecord:record]) {
                [self afterSaveRecord];
            }
        }
    }else{
        NSLog(@"存储对象为空");
    }
}

#pragma mark - 存储完成动作
- (void)afterSaveRecord{
    //取消新增状态
    [self touchMask];
    
    //刷新表单
    self.listData = [self quaryAllRecord];
    [self.ListTable reloadData];
    
    [self isShowEmptyView];
}

- (UIView *)inputAccessoryView{
    
//    if (self.operationStatus == createRecord || self.operationStatus == updateRecord) {
//        
//        [self.popAddView bringSubviewToFront:self.maskView];
//        return self.popAddView;
//    }else{
//        return nil;
//    }
    return nil;
}

#pragma mark - 组织存储对象
- (RecordMode *)packageRecordMode{
    //输入内容
    NSString *content = self.recordView.text;
    if ([JerryTools stringIsNull:content]) {
        //内容为空
        NSLog(@"内容为空");
        return nil;
    }else{
        //内容不为空
        //文字内容
        [self.recordMode setContent:content];
        //时间
        if (self.operationStatus == createRecord) {
            long long timeStamp = [JerryTools getCurrentTimestamp];
            NSNumber *longlongNumber = [NSNumber numberWithLongLong:timeStamp];
            NSString *timeStampStr = [longlongNumber stringValue];
            [self.recordMode setTimeStamp:timeStampStr];
        }
        
        return self.recordMode;
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
    
    UILabel *contentLabel = (UILabel *)[recordCell viewWithTag:1];
    UIImageView *typeImageView = (UIImageView *)[recordCell viewWithTag:2];
    
    RecordMode *record = [self.listData objectAtIndex:indexPath.row];
    //内容
    [contentLabel setText:record.content];
    //类型
    NSUInteger iconIndex = [record.type integerValue];
    UIImage *typeImage = [self.iconImageArray objectAtIndex:iconIndex];
    [typeImageView setImage:typeImage];

    //显示拖动按钮
    recordCell.showsReorderControl = YES;
    
    return recordCell;
}

//实现左滑删除功能需要实现
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //删除数据
    //数据库
    RecordMode *record = [self.listData objectAtIndex:indexPath.row];
    if ([self deleteById:record.recordId]) {
        //数据集
        [self.listData removeObjectAtIndex:indexPath.row];
        //刷新UI
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [self isShowEmptyView];
    }
}

//左滑出现的按钮显示文字
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

//是否允许移动
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

#pragma mark 移动完成后的数据排序交换
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
//    [self.listData exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    //目标位置对象
//    RecordMode *sourceRecord = [self.listData objectAtIndex:sourceIndexPath.row];
    //源对象
    RecordMode *record = [self.listData objectAtIndex:sourceIndexPath.row];
    
    //得到一个分身
    RecordMode *tempRecord = [[RecordMode alloc] init];
    tempRecord.recordId = record.recordId;
    tempRecord.timeStamp = record.timeStamp;
    tempRecord.content = record.content;
    tempRecord.type = record.type;
    tempRecord.order = record.order;
    tempRecord.pic = record.pic;
    tempRecord.temp1 = record.temp1;
    tempRecord.temp2 = record.temp2;
    tempRecord.temp3 = record.temp3;
    
    //将原数据设置为空，一遍后续删除
    record.recordId = @"";
    [self.listData replaceObjectAtIndex:sourceIndexPath.row withObject:record];
    
    //插入
    [self.listData insertObject:tempRecord atIndex:destinationIndexPath.row];
    
    //删除待删项
    for (int i = 0; i < [self.listData count]; i++) {
        RecordMode *currentRecord = [self.listData objectAtIndex:i];
        if ([currentRecord.recordId isEqualToString:@""]) {
            [self.listData removeObjectAtIndex:i];
            break;
        }
    }
    
    //更新排序位置
    for (int i = 0; i < [self.listData count]; i++) {
        RecordMode *record = [self.listData objectAtIndex:i];
        record.order = [NSString stringWithFormat:@"%d",i];
        //更新数据库
        [self updateRecord:record];
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RecordMode *record = [self.listData objectAtIndex:indexPath.row];
    self.recordMode = record;
    
    //操作状态设置为编辑
    self.operationStatus = updateRecord;
    
    self.editFrameSetting = YES;
    
    [self showEditInterface:self.recordMode];
}

//编辑状态下CELL行不缩进
-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPat{
    return NO;
}

//某行是否可编译
//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}

#pragma mark - 数据库
//打开数据库
- (BOOL)openSqlite{
    //判断数据库是否为空,如果不为空说明已经打开
    if (db != nil) {
        NSLog(@"数据库已打开");
        return YES;
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
        return [self createTable];
    } else {
        NSLog(@"数据库打开失败");
        return NO;
    }
}

//创建表
- (BOOL)createTable{
    //1.准备sqlite语句
    NSString *sqlite = [NSString stringWithFormat:@"create table if not exists '%@' ('%@' integer primary key autoincrement not null,'%@' text,'%@' text,'%@' text,'%@' text,'%@' text,'%@' text,'%@' text,'%@' text,'%@' text)",TABLE_RECORD_NAME,TABLE_RECORD_COL_ID,TABLE_RECORD_COL_DATE,TABLE_RECORD_COL_CONTENT,TABLE_RECORD_COL_TYPE,TABLE_RECORD_COL_PIC,TABLE_RECORD_COL_ISFINISH,TABLE_RECORD_COL_ORDER,TABLE_RECORD_COL_TEMP1,TABLE_RECORD_COL_TEMP2,TABLE_RECORD_COL_TEMP3];
    
    //2.执行sqlite语句
    char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result = sqlite3_exec(db, [sqlite UTF8String], nil, nil, &error);
    if (result == SQLITE_OK) {
        NSLog(@"表创建成功");
        return YES;
    } else {
        NSLog(@"表创建失败");
        NSLog(@"error : %s",error);
        return NO;
    }
}

//插入数据
- (BOOL)addRecord:(RecordMode *) record{
    
    NSString *orderStr = @"1";
    //排序值
    if ([self.listData count] > 0) {
        NSUInteger orderCount = [self.listData count] + 1;
        orderStr = [NSString stringWithFormat:@"%ld",orderCount];
    }
    
    //1.准备sqlite语句
    NSString *sqlite = [NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@,%@,%@,%@,%@,%@) values (%@,'%@','%@','%@','%@','%@','%@','%@','%@','%@')",TABLE_RECORD_NAME,TABLE_RECORD_COL_ID,TABLE_RECORD_COL_DATE,TABLE_RECORD_COL_CONTENT,TABLE_RECORD_COL_TYPE,TABLE_RECORD_COL_PIC,TABLE_RECORD_COL_ISFINISH,TABLE_RECORD_COL_ORDER,TABLE_RECORD_COL_TEMP1,TABLE_RECORD_COL_TEMP2,TABLE_RECORD_COL_TEMP3,nil,record.timeStamp,record.content,record.type,record.pic,record_status_not_finish,orderStr,record.temp1,record.temp2,record.temp3];
    
    //2.执行sqlite语句
    char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result = sqlite3_exec(db, [sqlite UTF8String], nil, nil, &error);
    if (result == SQLITE_OK) {
        NSLog(@"添加数据成功");
        return YES;
    } else {
        NSLog(@"添加数据失败");
        NSLog(@"错误：%s",error);
        return NO;
    }
}

//删除数据
- (BOOL)deleteById:(NSString *) recordId{
    //1.准备sqlite语句
    NSString *sqlite = [NSString stringWithFormat:@"delete from %@ where recordId = '%@'",TABLE_RECORD_NAME,recordId];
    //2.执行sqlite语句
    char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result = sqlite3_exec(db, [sqlite UTF8String], nil, nil, &error);
    if (result == SQLITE_OK) {
        NSLog(@"删除数据成功");
        return YES;
    } else {
        NSLog(@"删除数据失败%s",error);
        return NO;
    }
}

//修改
- (BOOL)updateRecord:(RecordMode *) recordMode{
    
    NSString *sqlite = [NSString stringWithFormat:@"update %@ set %@='%@',%@='%@',%@='%@' where %@='%@'",TABLE_RECORD_NAME,TABLE_RECORD_COL_CONTENT,recordMode.content,TABLE_RECORD_COL_TYPE,recordMode.type,TABLE_RECORD_COL_ORDER,recordMode.order,TABLE_RECORD_COL_ID,recordMode.recordId];
    
    NSLog(@"update sql : %@",sqlite);
    
    char *error = NULL;
    int result = sqlite3_exec(db, [sqlite UTF8String], nil, nil, &error);
    
    if (result == SQLITE_OK) {
        NSLog(@"修改数据成功");
        return YES;
    } else {
        NSLog(@"修改数据失败");
        return NO;
    }
}

//查询所有数据
- (NSMutableArray*)quaryAllRecord {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    //1.准备sqlite语句
    NSString *sqlite = [NSString stringWithFormat:@"select * from %@ order by %@",TABLE_RECORD_NAME,TABLE_RECORD_COL_ORDER];
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
            NSString *type = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)] ;
            NSString *order = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt,6)] ;
            
            NSLog(@"recordId:%@,date:%@,content:%@,type:%@,order:%@",recordId,date,content,type,order);
            
            //封装记录对象
            RecordMode *recordMode = [[RecordMode alloc] init];
            [recordMode setRecordId:recordId];
            [recordMode setTimeStamp:date];
            [recordMode setContent:content];
            [recordMode setType:type];
            [recordMode setOrder:order];
            
            [array addObject:recordMode];
        }
    } else {
        NSLog(@"查询失败");
        
    }
    //5.关闭伴随指针
    sqlite3_finalize(stmt);
    return array;
}
@end

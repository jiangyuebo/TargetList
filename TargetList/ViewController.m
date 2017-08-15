//
//  ViewController.m
//  TargetList
//
//  Created by Jerry on 2017/8/15.
//  Copyright © 2017年 Jerry. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *ListTable;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *operateBarButton;

//测试数据
@property (strong,nonatomic) NSMutableArray *listData;

//编辑状态
@property (nonatomic) NSUInteger editMode;


@end

@implementation ViewController

- (IBAction)operateButtonAction:(UIBarButtonItem *)sender {
    if (self.ListTable.editing) {
        self.ListTable.editing = NO;
    }else{
        self.ListTable.editing = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
}

- (void)initView{
    //test data
    self.listData = [[NSMutableArray alloc] initWithObjects:@"猪八戒", @"牛魔王", @"蜘蛛精", @"白骨精", @"狐狸精",nil];
    
    self.ListTable.delegate = self;
    self.ListTable.dataSource = self;
    
    self.editMode = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"moveCell";
    //获取可重用单元格
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        //创建cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSUInteger rowNumber = [indexPath row];
    cell.textLabel.text = [self.listData objectAtIndex:rowNumber];
    
    //显示拖动按钮
    cell.showsReorderControl = YES;
    
    return cell;
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

@end

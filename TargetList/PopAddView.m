//
//  PopAddView.m
//  TargetList
//
//  Created by Jerry on 2017/8/17.
//  Copyright © 2017年 Jerry. All rights reserved.
//

#import "PopAddView.h"

@implementation PopAddView



- (instancetype)init{
    //从xib初始化视图
    if (self = [super init]) {
        NSArray *xibArray = [[NSBundle mainBundle] loadNibNamed:@"PopAddView" owner:nil options:nil];
        self = [xibArray lastObject];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  PopAddView.m
//  TargetList
//
//  Created by Jerry on 2017/9/11.
//  Copyright © 2017年 Jerry. All rights reserved.
//

#import "PopAddView.h"
#import "JerryViewTools.h"

@implementation PopAddView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (PopAddView *) popAddView{
    return (PopAddView *)[JerryViewTools getViewByXibName:@"PopAddView"];
}

//-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//    NSLog(@"=========================hit");
//    UIView *view = [super hitTest:point withEvent:event];
//    if (view == nil) {
//        for (UIView *subView in self.subviews) {
//            CGPoint tp = [subView convertPoint:point fromView:self];
//            if (CGRectContainsPoint(subView.bounds, tp)) {
//                view = subView;
//                NSLog(@"有了");
//            }
//        }
//    }
//    
//    return view;
//}

@end

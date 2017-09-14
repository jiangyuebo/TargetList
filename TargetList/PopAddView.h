//
//  PopAddView.h
//  TargetList
//
//  Created by Jerry on 2017/9/11.
//  Copyright © 2017年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopAddView : UIView

@property (strong, nonatomic) IBOutlet UILabel *typeLabel;

@property (strong, nonatomic) IBOutlet UITextView *recordTextView;

@property (strong, nonatomic) IBOutlet UIScrollView *typeIconScrollView;

@property (strong, nonatomic) IBOutlet UIButton *submitButton;

+ (PopAddView *) popAddView;

@end

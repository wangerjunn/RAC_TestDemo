//
//  ViewController.m
//  RAC_Test
//
//  Created by 花花 on 2017/8/8.
//  Copyright © 2017年 花花. All rights reserved.
//

//view
#import "UIView+Frame.h"

#import "ViewController.h"

//rac
#import <ReactiveCocoa/ReactiveCocoa.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //学习地址http://cbsfly.github.io/ios/rac2
    [self.navigationItem setTitle:@"Rac_Test"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITextField *field = [[UITextField alloc]initWithFrame:CGRectMake(15, 100, 100, 30)];
    field.font = [UIFont systemFontOfSize:15];
    field.placeholder = @"placeholder";
    [self.view addSubview:field];
    
    //监听输入事件
   RACSignal *signal = [field rac_signalForControlEvents:UIControlEventEditingChanged];
    
    [signal subscribeNext:^(id x) {
        
        UITextField *tf = (UITextField *)x;
        
        NSLog(@"-----%@-----",tf.text);
    } completed:^{
        NSLog(@"-------");
    }];
    
    [[field rac_textSignal] subscribeNext:^(id x) {
        
    } completed:^{
        
    }];
    
    [RACObserve(field, text) subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(field.left, field.bottom+15, field.width, field.height)];
    label.backgroundColor = [UIColor redColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    label.text = @"点击label";
    label.userInteractionEnabled = YES;
    [self.view addSubview:label];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
    [[tap rac_gestureSignal] subscribeNext:^(id x) {
        [self showTitle:@"点击label"];
    } completed:^{
        NSLog(@"----------------");
    }];
    [label addGestureRecognizer:tap];
    
    UIButton *btn = [[UIButton alloc]init];
    btn.frame = CGRectMake(label.left, label.bottom+15, label.width, label.height);
    btn.backgroundColor = [UIColor orangeColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:@"按钮" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self showTitle:@"点击button"];
    }];
    
    
    //接收一些通知
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"testRacNotification" object:nil] subscribeNext:^(NSNotification *noti) {
        NSLog(@"%@",noti.name);
        NSLog(@"%@",noti.userInfo);
        [self showTitle:@"点击取消时会触发通知哦！"];
    }];
    
    //KVO RACObserve(TARGET, KEYPATH)这种形式，TARGET是监听目标，KEYPATH是要观察的属性值
    
    
    /**************探究RAC-RAC信号处理方法归纳**************/
    //RAC的核心就是信号(RACSignal)
    
}

- (void)showTitle:(NSString *)title {
    
    //用RAC写代理是有局限的，它只能实现返回值为void的代理方法
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title
                                                       message:@"RAC_Test"
                                                      delegate:self
                                             cancelButtonTitle:@"cancel"
                                             otherButtonTitles:@"other",@"1",@"2",@"3", nil];
    
    //    [[self rac_signalForSelector:@selector(alertView:clickedButtonAtIndex:) fromProtocol:@protocol(UIAlertViewDelegate)] subscribeNext:^(RACTuple *tuple) {
    //        NSLog(@"%@",tuple.first);
    //        NSLog(@"%@",tuple.second);
    //        NSLog(@"%@",tuple.third);
    //    }];
    
    [[alertView rac_buttonClickedSignal] subscribeNext:^(id x) {
        NSLog(@"x就是各个Button的序号%@",x);
        //
        if ([x integerValue] == 0) {
            
            NSDictionary *dic = @{
                                  @"cancel":@1,
                                  @"notiName":@"testRacNotification"
                                  };
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"testRacNotification" object:nil userInfo:dic];
        }
    }];
    [alertView show];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end




















































































































































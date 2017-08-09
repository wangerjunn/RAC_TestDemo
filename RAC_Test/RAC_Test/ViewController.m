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
        NSLog(@"----UIControlEventEditingChanged----");
    }];
    
//    [[field rac_textSignal] subscribeNext:^(id x) {
//        
//    } completed:^{
//        
//    }];
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(field.left, field.bottom+15, field.width, field.height)];
    label.backgroundColor = [UIColor redColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    label.text = @"点击label";
    label.userInteractionEnabled = YES;
    [self.view addSubview:label];
    
    [RACObserve(field, text) subscribeNext:^(id x) {
        NSLog(@"%@",x);
        label.text = x;
    }];

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
        NSLog(@"button响应事件");
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
    
    //自己手动写一个RACSignal
    //创建信号
    RACSignal *signalTest = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"signal"];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    //订阅信号
    [signalTest subscribeNext:^(id x) {
        NSLog(@"x = %@", x);
    } error:^(NSError *error) {
        NSLog(@"error = %@",error);
    } completed:^{
        NSLog(@"completed");
    }];
    
    //信号的处理
        //map：映射，创建一个订阅者的映射并且返回数据
    [[field.rac_textSignal map:^id(id value) {
        NSLog(@"%@", value);
        return @1;
    }] subscribeNext:^(id x) {
        NSLog(@"映射内容：%@", x);
    }];
    
    //map构造的映射块value的值就是控件中的字符变化，而订阅者x的值就是映射者的返回值1
    
    //filter（过滤）帮助你筛选出你需要的信号变化
    [[field.rac_textSignal filter:^BOOL(id value) {
        return [value length] > 3;
    }] subscribeNext:^(id x) {
        NSLog(@"x = %@", x);
    }];
    
    //take/skip/repeat
        //take是获取，skip是跳过，这两个方法后面跟着NSInteger。所以take 2就是获取前两个信号，skip 2就是跳过前两个。repeat是重复发送信号。
    
    RACSignal *takeSignal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"2"];
        [subscriber sendNext:@"3"];
        [subscriber sendNext:@"4"];
        [subscriber sendNext:@"5"];
        
        return nil;
    }] take:2];
    
    [takeSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }completed:^{
        NSLog(@"completed");
    }];
    
    //这个demo只会输出前两个信号1和2还有完成信号completed，skip,repeat同理.相似的还有takeLast takeUntil takeWhileBlock skipWhileBlock skipUntilBlock repeatWhileBlock都可以根据字面意思来理解。
    
    //delay 延时信号，即延迟发送信号
    RACSignal *delaySignal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"延迟了5s"];
        [subscriber sendCompleted];
        return nil;
    }] delay:5];
    
    [delaySignal subscribeNext:^(id x) {
        NSLog(@"信号延迟：%@",x);
    } completed:^{
        NSLog(@"延迟调用完成");
    }];
    
    //throttle 节流，在我们做搜索框的时候，有时候的需求是实时搜索，即用户每每输入字符，view都要求展现搜索结果。这时如果用户搜索的字符串较长，那么由于网络请求的延时可能造成UI显示错误，并且多次不必要的请求还会加大服务器的压力，这显然是不合理的，此时我们就需要用到节流。
    
    [[[field rac_textSignal] throttle:.5] subscribeNext:^(id x) {
        NSLog(@"节流内容：%@",x);
    } completed:^{
        NSLog(@"节流内容完成");
    }];
    
    //distincUntilChanged
    //网络请求中为了减轻服务器压力，无用的请求我们应该尽可能不发送。distinctUnitChanged的作用是使RAC不会连续发送两次相同的信号，这样就解决了这个问题。
    [[[field rac_textSignal] distinctUntilChanged] subscribeNext:^(id x) {
        NSLog(@"distincUntilChanged：%@", x);
    }];
    
    
    //timeout 超时信号，当超出限定时间后会给订阅者发送error信号。
    
    RACSignal *tiemoutSignal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [[RACScheduler mainThreadScheduler] afterDelay:3 schedule:^{
                [subscriber sendNext:@"delay"];
                [subscriber sendCompleted];
            }];
        return nil;
    }] timeout:2 onScheduler:[RACScheduler mainThreadScheduler]];
    
    [tiemoutSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
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




















































































































































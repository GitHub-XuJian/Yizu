//
//  LoopImageViewController.m
//  yizu
//
//  Created by myMac on 2017/10/25.
//  Copyright © 2017年 XuJian. All rights reserved.
//

#import "LoopImageViewController.h"
#import "UIImageView+AFNetworking.h"
#import "HomAreaBtnController.h"
@interface LoopImageViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UIPageControl *pageCon;

@property (strong, nonatomic) NSArray* loopArr;

@property (strong, nonatomic)NSTimer* timer;
@property (assign, nonatomic)int currentNumber;

@end

@implementation LoopImageViewController
- (IBAction)btnAction:(id)sender
{
 
    NSLog(@"点击了区域按钮%@",self.cityID);
    HomAreaBtnController* aVC=[[HomAreaBtnController alloc]init];
    aVC.cityId=self.cityID;
    UINavigationController* nav=[[UINavigationController alloc]initWithRootViewController:aVC];
    [self presentViewController:nav animated:YES completion:nil];
    
    
    
}

- (void)setLoopArr:(NSArray *)loopArr
{
    _loopArr=loopArr;
    [self updateUI];
}

- (void)updateUI
{
 self.scrollView.contentSize=CGSizeMake(self.loopArr.count*self.view.bounds.size.width, 0);
    for (int i=0; i<self.loopArr.count; i++) {
        
        UIImageView* imaView=[[UIImageView alloc]init];
        NSString* imaUrl=[NSString stringWithFormat:@"%@Public/img/img/%@",Main_ServerImage,self.loopArr[i]];
        [imaView setImageWithURL:[NSURL URLWithString:imaUrl]];
        imaView.frame=CGRectMake(i*self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [self.scrollView addSubview:imaView];
        if (self.currentNumber==0) {
            self.currentNumber++;
            
            //设置定时器让_scrollView 无限滚动播放
            self.timer =[NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(svRun) userInfo:nil repeats:YES];
        }
    }
    
}
-(void)svRun
{
    
    
    self.currentNumber++;
    
    if (self.currentNumber==self.loopArr.count) {
        self.currentNumber=0;
    }
    
    [UIView animateWithDuration:1 animations:^{
        self.scrollView.contentOffset=CGPointMake( self.view.frame.size.width*self.currentNumber-1, 0);
        [self updatePageControl:self.scrollView];
    }];
    //动画
//    [self.scrollView
//     scrollRectToVisible:CGRectMake(self.view.frame.size.width*self.currentNumber-1, 0, self.view.frame.size.width, 0) animated:YES];
    
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置第一次点击区域按钮
    self.cityID=@"73";
   
    [self setScrollViewStyle];
    
    //通知接受数据
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(massageCityId:) name:@"nameId" object:nil];

    NSString*  url=[NSString stringWithFormat:@"%@Mobile/Index/index_Slideshow",Main_Server];
    [XAFNetWork GET:url params:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.loopArr =responseObject[@"list"];
        
    } fail:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"出错了");
        [SVProgressHUD dismiss];

        [SVProgressHUD showErrorWithStatus:@"出错了"];

    }];
 
}
#pragma mark-scrollView相关设置
- (void)setScrollViewStyle
{
    self.scrollView.pagingEnabled=YES;
    self.scrollView.showsHorizontalScrollIndicator=NO;
    self.scrollView.bounces=NO;
    self.scrollView.delegate=self;
    self.pageCon.currentPage=0;
}
#pragma mark-通知回传
- (void)massageCityId:(NSNotification *)notification
{
    //NSLog(@"loopIma接受到通知%@,%@",notification.userInfo[@"name"],notification.userInfo[@"cityId"]);
    self.cityID=notification.userInfo[@"cityId"];
}
- (void)updatePageControl:(UIScrollView*)srollView
{
    CGPoint point=srollView.contentOffset;
    int numPage=point.x/srollView.bounds.size.width;
    self.pageCon.currentPage=numPage;
}
#pragma mark-UIScrollViewDelegate
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //NSLog(@"拖拽完成，减速%d",decelerate);
    if (!decelerate) {
        [self updatePageControl:scrollView];
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"减速完成");
    [self updatePageControl:scrollView];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

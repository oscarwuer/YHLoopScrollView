//
//  ViewController.m
//  YHLoopScrollViewDemo
//
//  Created by 张长弓 on 2018/1/4.
//  Copyright © 2018年 张长弓. All rights reserved.
//

#import "ViewController.h"
#import "YHLoopScrollView/YHLoopScrollView.h"

#define kColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ViewController ()<YHLoopScrollViewDelegate>

@property (nonatomic, strong) YHLoopScrollView *loopScrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"YHLoopScrollView";
    self.view.backgroundColor = kColorFromRGB(0xd8d8d8);
    
    CGRect frame = CGRectMake(0, 120, self.view.frame.size.width, 120);
    self.loopScrollView = [[YHLoopScrollView alloc] initWithLoopPageType:LoopPageType_Circle delegate:self frame:frame];
    NSArray *imgUrls = @[@"http://img14.gomein.net.cn/image/prodimg/promimg/topics/201511/20151102/1733jjj640_x.jpg",
                         
                         @"http://img4.gomein.net.cn/image/prodimg/promimg/topics/201510/20151030/1733kaimen280_x.jpg",
                         
                         @"http://img10.gomein.net.cn/image/prodimg/promimg/topics/201510/20151030/1733bx280_x.jpg",
                         
                         @"http://img3.gomein.net.cn/image/prodimg/promimg/topics/201510/20151030/1733qu280_x.jpg",
                         
                         @"http://img10.gomein.net.cn/image/prodimg/promimg/topics/201511/20151102/1733dn280_x.jpg",
                         
                         @"http://img1.gomein.net.cn/image/prodimg/promimg/topics/201510/20151030/1733cd280_x.jpg",
                         
                         @"http://img13.gomein.net.cn/image/prodimg/promimg/topics/201510/20151030/1733bh280_x.jpg"];
    
    self.loopScrollView.mArrayImageUrls = [imgUrls mutableCopy];
    [self.view addSubview:self.loopScrollView];
}

#pragma mark - YHLoopScrollViewDelegate

- (void)requiredLoopScrollView:(YHLoopScrollView *)aScrollViewLoop
              didSelectedIndex:(NSUInteger)aUIntIndex
{
    /// 处理点击之后的跳转逻辑
    NSLog(@"轮播图点击的是第%@个",@(aUIntIndex+1));
}


@end

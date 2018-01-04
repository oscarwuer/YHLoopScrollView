//
//  YHLoopScrollView.m
//  YHLoopScrollView
//
//  Created by yahui.zhang on 3/10/16.
//  Copyright © 2016 yahui.zhang. All rights reserved.
//

#import "YHLoopScrollView.h"
#import <SDWebImage/UIButton+WebCache.h>

/// 默认总的 image 个数
#define mtkDefaultTotalImgCount (3)
/// 轮播间隔
#define mtkLoopDuring (4.0f)

@interface YHLoopScrollView ()
<
UIScrollViewDelegate
>

@property (nonatomic, strong) UIScrollView *scrollViewContent;
@property (nonatomic, strong) UIPageControl *pageCtrlCircle;
/// 只添加一张轮播图时 单独处理 （注意：此时子视图没有scrollView,没有pageControl，只有一张imageView）
@property (nonatomic, strong) UIButton *imgViewSingle;

@property (nonatomic, strong) NSMutableArray *mArrayImageViews;
@property (nonatomic, strong) NSMutableDictionary *mDicIndex;

@property (nonatomic, assign) LoopPageType enumPageType;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) CADisplayLink *displayLink;

/// 为了第一次不走改变点点的方法 （做个标记）
@property (nonatomic, assign) BOOL isMoveCircle;


@end

@implementation YHLoopScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        if ((frame.size.width > 0) && (frame.size.height > 0))
        {
            [self initialize];
        }
        else
        {
            NSLog(@"!!!!!!!    请传入frame    !!!!!!!!");
        }
    }
    return self;
}

- (instancetype)initWithLoopPageType:(LoopPageType)pageType
                            delegate:(id<YHLoopScrollViewDelegate>)delegate
                               frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        if (frame.size.width > 0 && frame.size.height > 0)
        {
            self.enumPageType = pageType;
            self.delegate = delegate;
            [self initialize];
            /// 不用请注释掉（背景色）
//            self.scrollViewContent.backgroundColor = [UIColor redColor];
        }
        else
        {
            NSLog(@"!!!!!!!    请传入frame    !!!!!!!!");
        }
    }
    return self;
}

/// 初始化...
- (void)initialize{
    self.mArrayImageViews = [NSMutableArray arrayWithCapacity:mtkDefaultTotalImgCount];
    self.mDicIndex = [NSMutableDictionary dictionary];
    
    /// 初始化scrollView
    self.scrollViewContent = [[UIScrollView alloc] init];
    self.scrollViewContent.delegate = self;
    self.scrollViewContent.pagingEnabled = YES;
    self.scrollViewContent.showsHorizontalScrollIndicator = NO;
    self.scrollViewContent.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollViewContent];
    
    self.scrollViewContent.frame = self.bounds;
    self.scrollViewContent.contentSize = CGSizeMake(self.frame.size.width * mtkDefaultTotalImgCount, self.frame.size.height);
    
    /// 循环创建轮播图
    for (NSInteger i = 0; i < mtkDefaultTotalImgCount; i++)
    {
        CGRect frame = CGRectMake(i * self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
        UIButton *btnImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnImageView addTarget:self action:@selector(btnClickLoopView:) forControlEvents:UIControlEventTouchUpInside];
        btnImageView.frame = frame;
        /// 不用请注释掉（背景色）
//        [btnImageView setBackgroundColor:[UIColor colorWithRed:arc4random()%255/256.0f green:arc4random()%255/256.0f blue:arc4random()%255/256.0f alpha:1.0f]];
        btnImageView.adjustsImageWhenHighlighted = NO;
        [self.mArrayImageViews addObject:btnImageView];
        [self.scrollViewContent addSubview:btnImageView];
    }
    
    /// 初始化 pageControl
    self.pageCtrlCircle = [[UIPageControl alloc] init];
    _pageCtrlCircle.pageIndicatorTintColor = [UIColor grayColor];
    _pageCtrlCircle.currentPageIndicatorTintColor = [UIColor whiteColor];
    _pageCtrlCircle.userInteractionEnabled = NO;
    _pageCtrlCircle.currentPage = 0;
    _pageCtrlCircle.frame = CGRectMake(0, self.frame.size.height - 16, self.frame.size.width, 10);
    [self addSubview:self.pageCtrlCircle];
    
    /// 只有一张轮播图时的单独处理，默认隐藏起来。
    self.imgViewSingle = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.imgViewSingle addTarget:self action:@selector(btnClickLoopView:) forControlEvents:UIControlEventTouchUpInside];
    self.imgViewSingle.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.imgViewSingle.hidden = YES;
    [self addSubview:self.imgViewSingle];
    
    /// 判断pageType
    if (self.enumPageType == LoopPageType_Line)
    {
        self.pageCtrlCircle.hidden = YES;
    }
}

- (void)dealloc
{
    [self stopTimer];
}

#pragma mark - 计时器

- (void)startTimer
{
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:mtkLoopDuring
                                                  target:self
                                                selector:@selector(handleTimer:)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
    
    /// 关闭定时器的同时，关闭displayLink.
    [self completionDisplayLink];
}

- (void)handleTimer:(NSTimer*)sender
{
    if (self.scrollViewContent)
    {
#pragma mark 使用默认的轮播速度 还是 自定义轮播速度 ****** 目前采用默认 轮播速度默认
        
        /**
         *  YES:轮播速度默认
         *  NO :轮播速度自定义
         *  记得修改上面 #pragma mark提示语🤗（目前采用...）
         */
        BOOL isDefaultLoopSpeed = YES;
        
        if (isDefaultLoopSpeed)
        {
            /// 采用默认轮播图速度 注意：与下面的方法只能任选其一。并记得修改上面 #pragma mark提示语🤗
            [self.scrollViewContent setContentOffset:CGPointMake(self.scrollViewContent.contentOffset.x+self.frame.size.width, 0)
                                            animated:YES];
        }
        else
        {
            /// 采用自定义轮播图速度
            [self startDisplayLink];
        }
    }
}

#pragma mark - 自定义轮播速度 CADisplayLink

- (void)startDisplayLink
{
    if (!_displayLink)
    {
        _displayLink = [CADisplayLink displayLinkWithTarget:self
                                                   selector:@selector(loopSlowly:)];
        /// 注意：这儿要使用 NSRunLoopCommonModes
        /*
         *  关于 NSDefaultRunLoopMode 和 NSRunLoopCommonModes 的较量，可以参阅 http://handy-wang.iteye.com/blog/1491140
         *  简单来说，使用前者会导致用户事件触发时暂停displayLink，例如滑动tableView，这是为了突出用户事件的优先级。
         *  使用后者则不会出现上述情况
         */
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)loopSlowly:(CADisplayLink *)aDisplayLink
{
    /// 修改每一步前进的距离，以此改变滑动的速度，默认1s执行60次。暂设定100步走完一个屏幕的宽度
    NSInteger spacing = ceilf([UIScreen mainScreen].bounds.size.width/100);
    [self.scrollViewContent setContentOffset:CGPointMake(self.scrollViewContent.contentOffset.x + spacing, 0)
                                    animated:NO];
    
    /// 一张图轮播完成后，设定最终的contentOffset(避免偏差),并且关闭displayLink.
    if (self.scrollViewContent.contentOffset.x >= self.frame.size.width * 2 - spacing)
    {
        CGPoint point = CGPointMake(self.scrollViewContent.contentOffset.x+self.frame.size.width, 0);
        [self.scrollViewContent setContentOffset:point
                                        animated:NO];
        [self completionDisplayLink];
    }
}

/// 销毁 displayLink
- (void)completionDisplayLink
{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

#pragma mark - 获取url的index
- (NSInteger)indexWithUrl:(NSString *)aStringUrl
{
    return [[self.mDicIndex objectForKey:aStringUrl] integerValue];
}

#pragma mark - 赋值入口(数据唯一来源)
-(void)setMArrayImageUrls:(NSMutableArray *)mArrayImageUrls
{
    /// 增加传入的是多张url相同的图片时可以继续轮播的功能
    if(_mArrayImageUrls == nil)
    {
        _mArrayImageUrls = [NSMutableArray array];
    }
    else
    {
        [_mArrayImageUrls removeAllObjects];
    }
    
    for (NSInteger i = 0; i < mArrayImageUrls.count; i++)
    {
        NSString *strUrl = [mArrayImageUrls objectAtIndex:i];
        /// 只有url的长度大于1的才会添加到_imgUrls中
        if (strUrl.length > 1)
        {
            /// 将循环的i值添加到原始url之后
            [_mArrayImageUrls addObject:[NSString stringWithFormat:@"%@%@",strUrl,@(i)]];
        }
    }
    
    /// 如果图片数量为一张时，赋值imgViewSingle
    if (_mArrayImageUrls.count < 2)
    {
        self.imgViewSingle.hidden = NO;
        /// 设置点点数量 一张时候没有点点
        self.pageCtrlCircle.numberOfPages = 0;
        self.scrollViewContent.hidden = YES;
        
        if (self.mArrayImageUrls.count > 0)
        {
            NSString *url = [self.mArrayImageUrls objectAtIndex:0];
            self.imgViewSingle.tag = 0;
            [self.imgViewSingle sd_setBackgroundImageWithURL:[NSURL URLWithString:[url substringToIndex:url.length-1]] forState:UIControlStateNormal];
        }
    }
    else
    {
        self.imgViewSingle.hidden = YES;
        self.pageCtrlCircle.numberOfPages = 0;
        self.scrollViewContent.hidden = NO;
        self.pageCtrlCircle.numberOfPages = _mArrayImageUrls.count;
        
        /// 保存每个索引,以url当做唯一标示key,value是顺序,由此可以得知当前url的正常排序是第几个
        [self.mDicIndex removeAllObjects];
        for (NSInteger i = 0; i < _mArrayImageUrls.count; i++)
        {
            NSString *url = [_mArrayImageUrls objectAtIndex:i];
            [self.mDicIndex setObject:@(i) forKey:url];
        }
        
        /// 给点点纪录状态使用
        _isMoveCircle = NO;
        
        /// 因为实际上中间的按钮显示第一个图片,因此需要将图片数据左移
        [self goLeft];
        [self startTimer];
    }
}

#pragma mark - btn click event
/// 轮播图点击事件
- (void)btnClickLoopView:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(requiredLoopScrollView:didSelectedIndex:)])
    {
        [self.delegate requiredLoopScrollView:self
                             didSelectedIndex:btn.tag];
    }
}

#pragma mark - 刷新图片
- (void)refreshImage
{
    self.scrollViewContent.contentOffset = CGPointMake(self.frame.size.width, 0);
    NSInteger count = (self.mArrayImageUrls.count < 3) ? self.mArrayImageUrls.count : 3;
    for (NSInteger i = 0; i < count; i++)
    {
        __weak UIButton *weakBtnImageView = [self.mArrayImageViews objectAtIndex:i];
        NSString *url = [self.mArrayImageUrls objectAtIndex:i];
        weakBtnImageView.tag = [self indexWithUrl:url];
        /// 将url的最后一个的序号删除掉,最后一位的序号只是用来强制的区分相同的url
        [weakBtnImageView sd_setBackgroundImageWithURL:[NSURL URLWithString:[url substringToIndex:url.length-1]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error)
            {
                [weakBtnImageView setBackgroundImage:nil forState:UIControlStateNormal];
            }
        }];
    }
    
    /// 修复只有两个url时的bug（会闪一下）
    /// 将最后一个imgvBtn赋值为第一个url显示的图片。
    if (self.mArrayImageUrls.count == 2)
    {
        __weak UIButton *weakBtnImageView = self.mArrayImageViews.lastObject;
        NSString *tempUrl = self.mArrayImageUrls.firstObject;
        weakBtnImageView.tag = [self indexWithUrl:tempUrl];
        [weakBtnImageView sd_setBackgroundImageWithURL:[NSURL URLWithString:[tempUrl substringToIndex:tempUrl.length-1]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error)
            {
                [weakBtnImageView setBackgroundImage:nil forState:UIControlStateNormal];
            }
        }];
    }
}

#pragma mark - 移动数据
- (void)goRight
{
    NSString *url = [self.mArrayImageUrls firstObject];
    [self.mArrayImageUrls removeObjectAtIndex:0];
    [self.mArrayImageUrls addObject:url];
    
    /// 改变点点位置
    _pageCtrlCircle.currentPage = _pageCtrlCircle.currentPage == (self.mArrayImageUrls.count - 1) ? (0) : (_pageCtrlCircle.currentPage + 1);
    
    [self refreshImage];
}

- (void)goLeft
{
    NSString *url = [self.mArrayImageUrls lastObject];
    [self.mArrayImageUrls removeObjectAtIndex:self.mArrayImageUrls.count-1];
    [self.mArrayImageUrls insertObject:url atIndex:0];
    
    /// 判断是否移动点点
    if (_isMoveCircle)
    {
        /// 改变点点位置
        _pageCtrlCircle.currentPage = _pageCtrlCircle.currentPage == 0?(self.mArrayImageUrls.count - 1):_pageCtrlCircle.currentPage - 1;
    }
    else
    {
        _isMoveCircle = YES;
    }
    [self refreshImage];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /// 当轮播图个数超过1时，执行下面的操作。
    if (self.mArrayImageUrls && self.mArrayImageUrls.count > 1)
    {
        if (scrollView.contentOffset.x >= 2*self.frame.size.width)
        {
            [self goRight];
        }
        if (scrollView.contentOffset.x<=0)
        {
            [self goLeft];
        }
    }
}

/// 手指滑动时，关闭timer
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}

/// 手指滑动结束后，重新启动timer
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    /// 修复在滑动过程中切换到别的目标，导致画面一半一半的问题。
    if (self.scrollViewContent.contentOffset.x == 0)
    {
        return;
    }
    
    NSString *string = [NSString stringWithFormat:@"%@", @(self.scrollViewContent.contentOffset.x/[UIScreen mainScreen].bounds.size.width)];
    if (string.length != 1)
    {
        [self.scrollViewContent setContentOffset:CGPointMake(self.frame.size.width, 0)
                                        animated:YES];
    }
}


@end

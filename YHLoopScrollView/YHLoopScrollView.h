//
//  YHLoopScrollView.h
//  YHLoopScrollView
//
//  Created by yahui.zhang on 3/10/16.
//  Copyright © 2016 yahui.zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LoopPageType) {
    /// page 样式为小圆点
    LoopPageType_Circle = 0,
    
    /// page 样式为横线 （目前未实现）
    LoopPageType_Line,
};

@protocol YHLoopScrollViewDelegate;

@interface YHLoopScrollView : UIView

- (instancetype)initWithLoopPageType:(LoopPageType)aEnumPageType
                            delegate:(id<YHLoopScrollViewDelegate>)aDelegate
                               frame:(CGRect)aFrame;

@property (nonatomic, strong) NSMutableArray *mArrayImageUrls;

@property (nonatomic, weak) id<YHLoopScrollViewDelegate> delegate;

/// ！！！注意：要在父类的 dealloc 中调用此方法，避免因 timer 造成此类的不释放。
- (void)stopTimer;

@end


@protocol YHLoopScrollViewDelegate <NSObject>

@required
/// 轮播图点击事件的回调 aUIntIndex:所点选的图片index
- (void)requiredLoopScrollView:(YHLoopScrollView *)aScrollViewLoop
              didSelectedIndex:(NSUInteger)aUIntIndex;

@end

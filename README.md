# YHLoopScrollView
三张imgView实现无限循环，成熟稳定

### 效果图
![效果图](http://7xp0ch.com1.z0.glb.clouddn.com/loopScroll.gif)

### 原理

* 当图片数据大于1张的时候，采用三张imgView实现
* 每次滑动完，重置中间的imgView位置（无动画），并且更改数据源顺序
* 当只有两个数据时作处理（见Demo），否则会出现白屏的情况
* 手指移动的时候关闭定时器，当手指放开重新启动定时器，以避免相互影响的情况
* 将定时器加入RunLoop时的mode选择

**博客地址** 

[https://oscarwuer.github.io/2018/01/02/三张imgView实现无限轮播，可自定义轮播速度/](https://oscarwuer.github.io/2018/01/02/三张imgView实现无限轮播，可自定义轮播速度/)
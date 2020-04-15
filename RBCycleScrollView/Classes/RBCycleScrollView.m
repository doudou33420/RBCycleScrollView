//
//  testReaderView.m
//  ReaderDemo
//
//  Created by PartyLu on 2020/4/13.
//  Copyright © 2020 PartyLu. All rights reserved.
//

#import "RBCycleScrollView.h"
#import <Masonry.h>
#import "LFCollectionViewCell.h"
 
@interface RBCycleScrollView()<UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,assign) NSInteger currentPageIndex;
@property (nonatomic,strong) UIView *leftView;
@property (nonatomic,strong) UIView *centerView;
@property (nonatomic,strong) UIView *rightView;
@property (nonatomic,assign) NSInteger totalPageCount;
@end

@implementation RBCycleScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.currentPageIndex = 0;
        
        [self initSubviews];
        
        [self reloadContentViews];
    }
    
    return self;
}

-(void)initSubviews{

    _scrollView = [[UIScrollView alloc]init];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator   = NO;
    _scrollView.frame = self.bounds;
    _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
    [self addSubview:_scrollView];
  
}
 
- (void)setDelegate:(id<RBCycleScrollViewDelegate>)delegate{
    _delegate = delegate;
    [self reloadData];
}

#pragma mark - ReloadData

- (void)reloadData{
    _currentPageIndex  = 0;
    _totalPageCount    = 0;
    
    if ([self.delegate respondsToSelector:@selector(numberOfContentViewsInCycleScrollView:)]) {
        _totalPageCount = [self.delegate numberOfContentViewsInCycleScrollView:self];
    }else{
        NSAssert(NO, @"请实现numberOfContentViewsInCycleScrollView:代理函数");
    }
    [self reloadContentViews];
}

-(void)scrollToPageIndex:(NSInteger)pageIndex{
    if (pageIndex > _totalPageCount) {
        NSLog(@"无法跳转,pageIndexc大小超过数据总量");
    }else{
        _currentPageIndex  = pageIndex;
        [self reloadContentViews];
    }
}


#pragma mark --重置contentview的排版
- (void)reloadContentViews{
    
    //计算index
    NSInteger leftIndex = [self getPreviousPageIndex];
    NSInteger centerIndex = _currentPageIndex;
    NSInteger rightIndex = [self getNextPageIndex];
    
    //重置位置
    CGPoint offset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
    [self.scrollView setContentOffset:offset];
    
    //绘制view
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:contentViewAtIndex:)]) {
        [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        NSArray *indexArr = @[@(leftIndex),@(centerIndex),@(rightIndex)];
        NSMutableArray *viewArr = @[].mutableCopy;
        for (NSNumber * index in indexArr) {
            UIView *contentView;
            
            contentView = [self.delegate cycleScrollView:self contentViewAtIndex:[index integerValue]];
            [viewArr addObject:contentView];
            
            //点击
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewDidTap:)];
            [contentView addGestureRecognizer:tapGesture];
        }
        
        _leftView = viewArr[0];
        _leftView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        _centerView = viewArr[1];
        _centerView.frame = CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
        _rightView = viewArr[2];
        _rightView.frame = CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
        
        //手动指定层级 用以模仿翻页效果
        [self.scrollView addSubview:_rightView];
        [self.scrollView addSubview:_centerView];
        [self.scrollView addSubview:_leftView];
    }
}

// 将3个view显示的内容平移调换 并将空出的view重新填充
-(void)reloadLeftView{
    
    //重置位置
    CGPoint offset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
    [self.scrollView setContentOffset:offset];
    
    NSInteger leftIndex = [self getPreviousPageIndex];
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:contentViewAtIndex:)]) {
        UIView *newLeftView = [self.delegate cycleScrollView:self contentViewAtIndex:leftIndex];
        CGRect centerViewFrame = CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
        CGRect leftViewFrame =  CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        CGRect rightViewFrame = CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
        [_leftView removeFromSuperview];
        [_centerView removeFromSuperview];
        [_rightView removeFromSuperview];
        
        _rightView = _centerView;
        _rightView.frame = rightViewFrame;
        
        _centerView = _leftView;
        _centerView.frame = centerViewFrame;
        
        _leftView = newLeftView;
        _leftView.frame = leftViewFrame;
        
        [self.scrollView addSubview:_rightView];
        [self.scrollView addSubview:_centerView];
        [self.scrollView addSubview:_leftView];
        for (UIView *contentView in _scrollView.subviews) {
            //点击
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewDidTap:)];
            [contentView addGestureRecognizer:tapGesture];
        }
    }
}

// 将3个view显示的内容平移调换 并将空出的view重新填充
-(void)reloadRightView{
    //重置位置
    CGPoint offset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
    [self.scrollView setContentOffset:offset];
    
    NSInteger rightIndex = [self getNextPageIndex];
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:contentViewAtIndex:)]) {
        //获取新rightView
        UIView *newRightView = [self.delegate cycleScrollView:self contentViewAtIndex:rightIndex];
        
        CGRect centerViewFrame = CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
        CGRect leftViewFrame =  CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        CGRect rightViewFrame = CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
        [_leftView removeFromSuperview];
        [_centerView removeFromSuperview];
        [_rightView removeFromSuperview];
        
        _leftView = _centerView;
        _leftView.frame = leftViewFrame;
        
        _centerView = _rightView;
        _centerView.frame = centerViewFrame;
        
        _rightView = newRightView;
        _rightView.frame = rightViewFrame;
 
        [self.scrollView addSubview:_rightView];
        [self.scrollView addSubview:_centerView];
        [self.scrollView addSubview:_leftView];
        for (UIView *contentView in _scrollView.subviews) {
            //点击
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewDidTap:)];
            [contentView addGestureRecognizer:tapGesture];
        }
    }
}
 
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width, 0) animated:YES];
}

//控制界面移动及计算页码
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    CGFloat offsetX = scrollView.contentOffset.x;
    //与中间位置的偏移量
    CGFloat userDistance = offsetX - self.scrollView.bounds.size.width;
    
    if (offsetX > self.scrollView.bounds.size.width) {
        //移动view始终在中间位置
        self.rightView.frame = CGRectMake(self.frame.size.width + userDistance, 0, self.rightView.bounds.size.width, self.rightView.bounds.size.height);
        //右侧边界
        if (_currentPageIndex +1 < _totalPageCount) {
            //加载新的rightView
            if (offsetX >= self.scrollView.bounds.size.width * 2) {
                _currentPageIndex = [self getNextPageIndex];
                if ([self.delegate respondsToSelector:@selector(cycleScrollView:currentContentViewAtIndex:)]) {
                    [self.delegate cycleScrollView:self currentContentViewAtIndex:_currentPageIndex];
                    //重新构建contentView
                    [self reloadRightView];
                }else{
                    NSAssert(NO, @"请实现cycleScrollView:currentContentViewAtIndex:代理函数");
                }
            }
        }else{
            [scrollView setContentOffset:CGPointMake(scrollView.bounds.size.width, 0) animated:NO];
        }
    }else{
        if (_currentPageIndex) {
            self.centerView.frame = CGRectMake(self.frame.size.width + userDistance, 0, self.centerView.bounds.size.width, self.centerView.bounds.size.height);
            if (offsetX <= 0){
                _currentPageIndex = [self getPreviousPageIndex];
                if ([self.delegate respondsToSelector:@selector(cycleScrollView:currentContentViewAtIndex:)]) {
                    [self.delegate cycleScrollView:self currentContentViewAtIndex:_currentPageIndex];
                    [self reloadLeftView];
                }else{
                    NSAssert(NO, @"请实现cycleScrollView:currentContentViewAtIndex:代理函数");
                }
            }
        }else{
             [scrollView setContentOffset:CGPointMake(scrollView.bounds.size.width, 0) animated:NO];
        }
    }
}

//上一页页码
-(NSInteger)getPreviousPageIndex{
    return _currentPageIndex ? _currentPageIndex - 1 : 0;
}

//下一页页码
-(NSInteger)getNextPageIndex{
    return _currentPageIndex == _totalPageCount -1 ? _currentPageIndex : _currentPageIndex + 1;
}


#pragma mark -- tap
//点击事件
-(void)contentViewDidTap:(UITapGestureRecognizer *)gesture{
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:didSelectContentViewAtIndex:)]) {
        [self.delegate cycleScrollView:self didSelectContentViewAtIndex:_currentPageIndex];
    }
}

@end

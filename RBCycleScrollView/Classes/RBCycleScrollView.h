//
//  testReaderView.h
//  ReaderDemo
//
//  Created by PartyLu on 2020/4/13.
//  Copyright © 2020 PartyLu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@class RBCycleScrollView;

@protocol RBCycleScrollViewDelegate <NSObject>

@required

/// 总数量
- (NSInteger)numberOfContentViewsInCycleScrollView:(RBCycleScrollView *)cycleScrollView;


/// 构建要显示的view
/// @param index view对应的index
- (UIView *)cycleScrollView:(RBCycleScrollView *)cycleScrollView contentViewAtIndex:(NSInteger)index;
    
@optional

/// 当前显示view的index
- (void)cycleScrollView:(RBCycleScrollView *)cycleScrollView currentContentViewAtIndex:(NSInteger)index;
/// 选中的view
- (void)cycleScrollView:(RBCycleScrollView *)cycleScrollView didSelectContentViewAtIndex:(NSInteger)index;
@end

@interface RBCycleScrollView : UIView

@property (nonatomic,weak) id<RBCycleScrollViewDelegate> delegate;


/// 重新加载数据
- (void)reloadData;

/// 跳转至某页
-(void)scrollToPageIndex:(NSInteger)pageIndex;

@end

NS_ASSUME_NONNULL_END

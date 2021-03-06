//
//  ZXRefreshHeaderView.m
//  CodeLibary
//
//  Created by wlh on 16/9/2.
//  Copyright © 2016年 linxun. All rights reserved.
//

#import "ZXRefreshHeaderView.h"

@interface ZXRefreshHeaderView ()
@property (nonatomic, assign) UIScrollView *scrollView;
@property (nonatomic, assign) UIEdgeInsets parentInset;
@property (nonatomic, assign) ZXRefreshState refreshState;
@property (nonatomic, assign) CGFloat pullingProgress;
@property (nonatomic, copy) ZXRefreshHeaderBlock refreshBlock;

@end

@implementation ZXRefreshHeaderView

+ (instancetype)headerWithRefreshingBlock:(ZXRefreshHeaderBlock)block {
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0);
    ZXRefreshHeaderView *headerView = [[[self class] alloc] initWithFrame:frame];
    headerView.refreshBlock = block;
    return headerView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentHeight = 40;
        self.contentInset = 0;
        self.contentOffset = 0;
        self.refreshState = ZXRefreshStateIdle;
        self.pullingProgress = 0.f;
    }
    return self;
}

- (void)dealloc
{
    [self removeObservers];
}

#pragma mark Functions

- (BOOL)attachToView:(UIView *)view {
    if ([view isKindOfClass:[UIScrollView class]]) {
        self.scrollView = (UIScrollView *)view;
        self.scrollView.alwaysBounceVertical = YES;
        self.parentInset = self.scrollView.contentInset;
        [self.scrollView addSubview:self];
        return YES;
    }
    return NO;
}

- (BOOL)detach {
    if (self.scrollView) {
        self.scrollView = nil;
        self.parentInset = UIEdgeInsetsZero;
        [self removeFromSuperview];
        return YES;
    }
    return NO;
}

#pragma mark Getter & Setter

- (void)setContentHeight:(CGFloat)contentHeight {
    _contentHeight = contentHeight;
    [self updateContentSize];
}

- (void)setContentInset:(CGFloat)contentInset {
    _contentInset = contentInset;
    [self updateContentSize];
}

- (void)setRefreshState:(ZXRefreshState)refreshState {
    if (_refreshState != refreshState) {
        _refreshState = refreshState;
    }
}

- (void)setPullingProgress:(CGFloat)pullingProgress {
    if (pullingProgress < 0.f) {
        pullingProgress = 0.f;
    } else if (pullingProgress > 1.f) {
        pullingProgress = 1.f;
    }
    //
    if (ABS(_pullingProgress - pullingProgress) > .005) {
        _pullingProgress = pullingProgress;
    }
}

- (void)updateContentSize {
    CGRect frame = self.frame;
    frame.origin.y = -_contentHeight + _contentInset;
    frame.size.height = _contentHeight;
    self.frame = frame;
}

#pragma mark Overrides

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    //
    if (newSuperview) {
        [self removeObservers];
        [self addObservers];
    } else {
        [self removeObservers];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    CGRect frame = self.frame;
    frame.size.width = self.superview.bounds.size.width;
    self.frame = frame;
}

#pragma mark Refreshing

- (BOOL)beginRefreshing {
    if (_refreshState == ZXRefreshStateIdle || _refreshState == ZXRefreshStateWillRefreshing) {
        _refreshState = ZXRefreshStateRefreshing;
        //
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top += self.frame.size.height;
        [UIView animateWithDuration:.2 animations:^{
            _scrollView.contentInset = inset;
        }];
        //
        if (_refreshBlock) {
            _refreshBlock();
        }
        //
        return YES;
    }
    return NO;
}

- (BOOL)endRefreshing {
    if (self.refreshState == ZXRefreshStateRefreshing) {
        self.refreshState = ZXRefreshStateIdle;
        //
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top -= self.frame.size.height;
        [UIView animateWithDuration:.2 animations:^{
            _scrollView.contentInset = inset;
        }];
        //
        return YES;
    }
    return NO;
}

- (BOOL)isRefreshing {
    return self.refreshState == ZXRefreshStateRefreshing;
}

#pragma mark NSKeyValueObserving

- (void)addObservers {
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

- (void)removeObservers {
    [self.superview removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        self.parentInset = self.scrollView.contentInset;
        [self scrollViewDidScroll:self.scrollView];
    }
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = self.scrollView.contentOffset.y + self.contentOffset;
    CGFloat insetTop = -self.parentInset.top;
    CGFloat height = self.frame.size.height;
    CGFloat progress = (insetTop - offsetY) / height;
    if (self.scrollView.isDragging && !self.isRefreshing) {
        if (offsetY < insetTop) {
            if (offsetY > insetTop - height) {
                if (self.refreshState == ZXRefreshStateIdle || self.refreshState == ZXRefreshStateWillRefreshing) {
                    self.refreshState = ZXRefreshStatePulling;
                }
                self.pullingProgress = progress;
            } else {
                self.pullingProgress = 1.f;
                if (self.refreshState == ZXRefreshStatePulling) {
                    self.refreshState = ZXRefreshStateWillRefreshing;
                }
            }
        } else {
            self.pullingProgress = 0.f;
            if (self.refreshState == ZXRefreshStateWillRefreshing) {
                self.refreshState = ZXRefreshStateIdle;
            }
        }
        self.pullingProgress = (insetTop - offsetY) / height;
    } else if (self.refreshState == ZXRefreshStateWillRefreshing) {
        [self beginRefreshing];
//    } else {
//        self.pullingProgress = progress;
    }
//    NSLog(@"%d %d", (int)self.refreshState, (int)(self.pullingProgress * 100));
}

@end

@implementation UIView (ZXRefreshHeaderView)

- (ZXRefreshHeaderView *)refreshHeaderView {
    return objc_getAssociatedObject(self, @selector(refreshHeaderView));
}

- (void)setRefreshHeaderView:(ZXRefreshHeaderView *)refreshHeaderView {
    [self.refreshHeaderView detach];
    //
    if (refreshHeaderView) {
        [refreshHeaderView attachToView:self];
    }
    //
    objc_setAssociatedObject(self, @selector(refreshHeaderView), refreshHeaderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
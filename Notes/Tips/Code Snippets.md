##Code Snippets
#####UIScrollView代理
```objc
// 停止拖动时执行
// 快速停止拖动时,虽然这个方法执行了,但是此时滑动还没停下来,所以下面打印出来的`contentOffsetY`是当时的偏移量,而`targetOffsetY`打印出来的是滑动最终停下来的位置的偏移量.
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    // 快速拖拽时的速度,为正代表向上拖动,为负代表向下拖动
    // 如果是平滑慢慢拖动,此值为`0`,所以不能仅以此值来判断是向上滑动还是向下滑动
    // `locityY`速度为0,也就没有加速和减速
    // 反之，当 velocity 不为 CGPointZero 时，scroll view 会以 velocity 为初速度，减速直到 targetContentOffset。
    CGFloat velocityY = velocity.y;
    CGFloat targetOffsetY = targetContentOffset->y;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    
    NSLog(@"\n\nvelocityY = %f,\ntargetOffsetY = %f,\noffsetY = %f", velocityY, targetOffsetY, contentOffsetY);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    // 慢慢拖动时`decelerate`为 NO
    NSLog(@"\n\n %@,\nEndDrag = %f", decelerate ? @"将要减速" : @"不会减速", contentOffsetY);
}
``` 
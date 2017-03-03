//
//  AStart.m
//  AStartDemo
//
//  Created by philZhang on 2017/2/20.
//  Copyright © 2017年 com.qianrong.SKSimple. All rights reserved.
//

#import "AStart.h"

@interface AStart()
@property (nonatomic, strong) NSMutableArray *mOpenList;
@property (nonatomic, strong) NSMutableArray *mCloseList;
@property (nonatomic, strong) NSMutableArray *mPathVec;
@end

@implementation AStart

@synthesize mMapGrid = _mMapGrid;

- (BOOL)findPathWithGrid:(MapGrid *)grid
{
    _mMapGrid = grid;
    self.mOpenList = [NSMutableArray array];
    self.mCloseList = [NSMutableArray array];
    CFAbsoluteTime beginTime = CFAbsoluteTimeGetCurrent();
    BOOL hasPath = [self findPathWithGrid:grid];
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    NSLog(@"本次寻路耗时:%f", endTime - beginTime);
    return hasPath;//[self findPathStep];
}

- (BOOL)findPathStep
{
    MapNode *node = self.mMapGrid.mStartNode;
    node.g = 0;
    node.h = [AStart costDiagByStartNode:node andEndNode:self.mMapGrid.mEndNode];
    node.f = node.h + node.g;
    int stepCount = 0;
    
    while (node != self.mMapGrid.mEndNode) {
        [self filterRoundNode:node];
        [self.mCloseList addObject:node];
        if (self.mOpenList.count == 0) {
            NSLog(@"未找到路径");
            return false;
        }
        MapNode __block *tmpNode = [self.mOpenList firstObject];
        [self.mOpenList enumerateObjectsUsingBlock:^(MapNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (tmpNode.f>obj.f) {
                tmpNode = obj;
            }
        }];
        node = tmpNode;
        [self.mOpenList removeObject:node];
        stepCount ++;
    }
    NSLog(@"最大寻路步数:%d", stepCount);
//    [self buildPath];
    return true;
}

- (void)filterRoundNode:(MapNode *)node
{
    int startX = MAX(0, node.x - 1);
    int endX = MIN(self.mMapGrid.mCloumnNums - 1, node.x + 1);
    int startY = MAX(0, node.y - 1);
    int endY = MIN(self.mMapGrid.mRowNums - 1, node.y + 1);
    for (int x = startX; x <= endX; x ++) {
        for (int y = startY; y <= endY; y ++) {
            MapNode *tmpNode = [self.mMapGrid getNodeByPoint:CGPointMake(x, y)];
            if (tmpNode == node || !tmpNode.walkEnable) {
                continue;
            }
            int moveCost = kStraightCost;
            if (tmpNode.x != node.x && tmpNode.y != node.y) {
                CGPoint p1 = CGPointMake(node.x, tmpNode.y);
                CGPoint p2 = CGPointMake(tmpNode.x, node.y);
                if (![self.mMapGrid getNodeByPoint:p1].walkEnable || ![self.mMapGrid getNodeByPoint:p2].walkEnable) {
                    continue;
                }
                moveCost = kDiagCost;
            }
            //h为估算值
            int h = [AStart costDiagByStartNode:tmpNode andEndNode:self.mMapGrid.mEndNode];
            //g为移动消耗
            int g = moveCost + tmpNode.g;
            //A* 计算公式f = g + h
            int f = g + h;
            if ([self isOpenedNode:tmpNode] || [self isCloseNode:tmpNode]) {
                if (tmpNode.f > f) {
                    tmpNode.g = g;
                    tmpNode.f = f;
                    tmpNode.h = h;
                    tmpNode.parent = node;
                }
            }else
            {
                tmpNode.f = f;
                tmpNode.g = g;
                tmpNode.h = h;
                tmpNode.parent = node;
                [self.mOpenList addObject:tmpNode];
            }
        }
    }
}

- (BOOL)isOpenedNode:(MapNode *)node
{
    return [self.mOpenList containsObject:node];
}

- (BOOL)isCloseNode:(MapNode *)node
{
    return [self.mCloseList containsObject:node];
}

+ (int)costDiagByStartNode:(MapNode *)startNode andEndNode:(MapNode *)endNode
{
    int dx = abs(startNode.x - endNode.x);
    int dy = abs(startNode.y - endNode.y);
    int diag = MIN(dx, dy);
    return diag * kDiagCost + (MAX(dx, dy) - diag) * kStraightCost;
}

- (NSArray *)buildPath
{
    self.mPathVec = [NSMutableArray array];
    MapNode *node = self.mMapGrid.mEndNode;
    [self.mPathVec addObject:node];
    while (node != self.mMapGrid.mStartNode) {
        node = node.parent;
        [self.mPathVec insertObject:node atIndex:0];
    }
//    [self printPath];
    return self.mPathVec;
}

- (void)printPath
{
    NSMutableString *str = [NSMutableString string];
    for (int i = 0; i < self.mPathVec.count; i ++) {
        MapNode *node = [self.mPathVec objectAtIndex:i];
        [str appendString:[NSString stringWithFormat:@"(%d,%d)->", node.x, node.y]];
    }
    NSLog(@"[==\n%@\n==]", str);
}

@end

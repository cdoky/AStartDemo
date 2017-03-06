//
//  MapGrid.m
//  AStartDemo
//
//  Created by philZhang on 2017/2/20.
//  Copyright © 2017年 com.qianrong.SKSimple. All rights reserved.
//

#import "MapGrid.h"

@implementation MapGrid
@synthesize mCloumnNums = _mCloumnNums;
@synthesize mRowNums = _mRowNums;
@synthesize mMapNodes = _mMapNodes;
@synthesize mScale = _mScale;

- (instancetype)initWithCloumnNums:(int)cloumnsNums andRowNums:(int)rowNums andScale:(CGFloat)scale
{
    if (self = [super init]) {
        _mCloumnNums = cloumnsNums;
        _mRowNums = rowNums;
        _mScale = scale;
    }
    return self;
}

- (void)buildMapNode
{
    _mMapNodes = [NSMutableArray array];
    for (int y = 0; y < self.mRowNums; y ++) {
        for (int x = 0; x < self.mCloumnNums; x ++) {
            MapNode *node = [[MapNode alloc] initWithX:x andY:y];
            node.walkEnable = arc4random() % 100 < 90;
            node.scale = self.mScale;
            [_mMapNodes addObject:node];
        }
    }
}

- (void)setStartNodeByPoint:(CGPoint)point
{
    self.mStartNode = [self getNodeByPoint:point];
}

- (void)setEndNodeByPoint:(CGPoint)point
{
    self.mEndNode = [self getNodeByPoint:point];
}

- (void)resetGrid
{
    for (MapNode *node in _mMapNodes) {
        node.g = 0;
        node.f = 0;
        node.h = 0;
        node.parent = nil;
    }
}

- (MapNode *)getNodeByPoint:(CGPoint)point
{
    return [self.mMapNodes objectAtIndex:point.y * _mCloumnNums + point.x];
}


@end

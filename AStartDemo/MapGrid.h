//
//  MapGrid.h
//  AStartDemo
//
//  Created by philZhang on 2017/2/20.
//  Copyright © 2017年 com.qianrong.SKSimple. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MapNode.h"

@interface MapGrid : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *mMapNodes;
@property (nonatomic, strong) MapNode *mStartNode;
@property (nonatomic, strong) MapNode *mEndNode;
@property (nonatomic, assign, readonly) int mCloumnNums;
@property (nonatomic, assign, readonly) int mRowNums;
@property (nonatomic, assign, readonly) CGFloat mScale;

- (instancetype)initWithCloumnNums:(int)cloumnsNums andRowNums:(int)rowNums andScale:(CGFloat)scale;

- (void)buildMapNode;

- (void)resetGrid;

- (MapNode *)getNodeByPoint:(CGPoint)point;

- (void)setStartNodeByPoint:(CGPoint)point;

- (void)setEndNodeByPoint:(CGPoint)point;

@end

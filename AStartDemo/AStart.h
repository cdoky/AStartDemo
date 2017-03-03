//
//  AStart.h
//  AStartDemo
//
//  Created by philZhang on 2017/2/20.
//  Copyright © 2017年 com.qianrong.SKSimple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MapGrid.h"

static int const kDiagCost = 14;
static int const kStraightCost = 10;

@interface AStart : NSObject

@property (nonatomic, readonly) MapGrid *mMapGrid;

- (BOOL)findPathWithGrid:(MapGrid *)grid;

- (NSArray *)buildPath;

- (void)printPath;
@end

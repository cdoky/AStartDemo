//
//  MapNode.m
//  AStartDemo
//
//  Created by philZhang on 2017/2/20.
//  Copyright © 2017年 com.qianrong.SKSimple. All rights reserved.
//

#import "MapNode.h"

@interface MapNode()

@end

@implementation MapNode

@synthesize x = _x, y = _y;

- (instancetype)initWithX:(int)x andY:(int)y
{
    if (self = [super init]) {
        _x = x;
        _y = y;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, x:%d, y:%d,", self, self.x, self.y];
}

@end

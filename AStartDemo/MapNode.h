//
//  MapNode.h
//  AStartDemo
//
//  Created by philZhang on 2017/2/20.
//  Copyright © 2017年 com.qianrong.SKSimple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MapNode : NSObject

@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;
@property (nonatomic, assign) int g;
@property (nonatomic, assign) int f;
@property (nonatomic, assign) int h;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) BOOL walkEnable;
@property (nonatomic, strong) MapNode *parent;

- (instancetype)initWithX:(int)x andY:(int)y;

@end

//
//  ViewController.m
//  AStartDemo
//
//  Created by philZhang on 2017/2/20.
//  Copyright © 2017年 com.qianrong.SKSimple. All rights reserved.
//

#import "ViewController.h"
#import "AStart.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIView *mMapView;
//@property UIView *mMapView;

@property CAShapeLayer *mGridLayer;
@property CAShapeLayer *mBarrierLayer;
@property CAShapeLayer *mPathLayer;

@property UIBezierPath *mBrushGrid;
@property UIBezierPath *mBrushBarrier;
@property UIBezierPath *mBrushPath;

@property AStart *mAStart;
@property MapGrid *mMapGrid;

//outlets
@property (strong, nonatomic) IBOutlet UITextField *mTxtColumns;
@property (strong, nonatomic) IBOutlet UITextField *mTxtRows;
@property (strong, nonatomic) IBOutlet UITextField *mTxtScale;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildMapViewByNumCloumns:90 andNumRows:60 andScale:10];
    [self initLayer];
    [self initBrush];
    [self drawMap];
}

- (void)buildMapViewByNumCloumns:(int)columns andNumRows:(int)rows andScale:(CGFloat)scale
{
    self.mMapGrid = [[MapGrid alloc] initWithCloumnNums:columns andRowNums:rows andScale:scale];
    [self.mMapGrid buildMapNode];
    self.mAStart = [AStart new];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMapTaped:)];
    [self.mMapView addGestureRecognizer:tapGesture];
}

- (void)initLayer
{
    self.mGridLayer = [CAShapeLayer layer];
    [self.mMapView.layer addSublayer:self.mGridLayer];
    self.mGridLayer.fillColor = nil;
    self.mGridLayer.strokeColor = [UIColor blackColor].CGColor;
    self.mGridLayer.lineWidth = 1;
    
    self.mBarrierLayer = [CAShapeLayer layer];
    [self.mMapView.layer addSublayer:self.mBarrierLayer];
    self.mBarrierLayer.fillColor = [UIColor blackColor].CGColor;
    self.mGridLayer.strokeColor = [UIColor redColor].CGColor;
    
    self.mPathLayer = [CAShapeLayer layer];
    [self.mMapView.layer addSublayer:self.mPathLayer];
    self.mPathLayer.fillColor = nil;
    self.mPathLayer.strokeColor = [UIColor blueColor].CGColor;
    self.mPathLayer.lineWidth = 1;
}

- (void)initBrush
{
    self.mBrushGrid = [UIBezierPath bezierPath];
    self.mBrushBarrier = [UIBezierPath bezierPath];
    self.mBrushPath = [UIBezierPath bezierPath];
    self.mGridLayer.path = self.mBrushGrid.CGPath;
    self.mBarrierLayer.path = self.mBrushBarrier.CGPath;
    self.mPathLayer.path = self.mBrushPath.CGPath;
}

- (void)drawMap
{
    [self.mBrushGrid removeAllPoints];
    CGFloat kHeight = self.mMapGrid.mRowNums * self.mMapGrid.mScale;
    CGFloat kWidht = self.mMapGrid.mCloumnNums * self.mMapGrid.mScale;
    for (int x = 0; x <= self.mMapGrid.mCloumnNums; x ++) {
        [self.mBrushGrid moveToPoint:CGPointMake(x * self.mMapGrid.mScale, 0.0f)];
        [self.mBrushGrid addLineToPoint:CGPointMake(x * self.mMapGrid.mScale, kHeight)];
    }
    for (int y = 0; y <= self.mMapGrid.mRowNums; y ++) {
        [self.mBrushGrid moveToPoint:CGPointMake(0, y * self.mMapGrid.mScale)];
        [self.mBrushGrid addLineToPoint:CGPointMake(kWidht, y * self.mMapGrid.mScale)];
    }
    CABasicAnimation *gridAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    gridAnimation.fromValue = @0;
    gridAnimation.toValue = @1;
    gridAnimation.duration = 2;
    [self.mGridLayer addAnimation:gridAnimation forKey:@"gridAnimation"];
    self.mGridLayer.path = self.mBrushGrid.CGPath;
    
    [self.mBrushBarrier removeAllPoints];
    [self.mMapGrid.mMapNodes enumerateObjectsUsingBlock:^(MapNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.walkEnable) {
            return;
        }
        CGPoint point = CGPointMake(obj.x * self.mMapGrid.mScale, obj.y * self.mMapGrid.mScale);
        point = CGPointMake(point.x + self.mMapGrid.mScale / 2, point.y + self.mMapGrid.mScale / 2);
        [self.mBrushBarrier moveToPoint:point];
        [self.mBrushBarrier addArcWithCenter:point radius:self.mMapGrid.mScale / 2 startAngle:0 endAngle:360 clockwise:YES];
    }];
    self.mBarrierLayer.path = self.mBrushBarrier.CGPath;
    
    gridAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    gridAnimation.fromValue = @0;
    gridAnimation.toValue = @1;
    gridAnimation.duration = 3;
    [self.mPathLayer addAnimation:gridAnimation forKey:@"gridAnimation"];
}

- (void)onMapTaped:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        CGPoint oriPoint = [tapGesture locationInView:tapGesture.view];
        if (!CGRectContainsPoint(CGRectMake(0, 0, self.mMapGrid.mScale * self.mMapGrid.mCloumnNums, self.mMapGrid.mScale * self.mMapGrid.mRowNums), oriPoint)) {
            return;
        }
        CGPoint relPoint = CGPointMake(floor(oriPoint.x / self.mMapGrid.mScale), floor(oriPoint.y / self.mMapGrid.mScale));
        if (![self.mMapGrid getNodeByPoint:relPoint].walkEnable) {
            [[[UIAlertView alloc] initWithTitle:@"错误" message:@"当前所选点为障碍物" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return;
        }
        
        if (self.mMapGrid.mStartNode) {
            if (self.mMapGrid.mEndNode) {
                self.mMapGrid.mStartNode = self.mMapGrid.mEndNode;
            }
            [self.mMapGrid setEndNodeByPoint:relPoint];
            
            [self.mBrushPath removeAllPoints];
            [self drawPathPoint:CGPointMake(self.mMapGrid.mStartNode.x, self.mMapGrid.mStartNode.y)];
            [self drawPathPoint:CGPointMake(self.mMapGrid.mEndNode.x, self.mMapGrid.mEndNode.y)];
           self.mPathLayer.path = self.mBrushPath.CGPath; 
            
            [self.mMapGrid resetGrid];
            BOOL hasFindPath = [self.mAStart findPathWithGrid:self.mMapGrid];
            if (!hasFindPath) {
               [[[UIAlertView alloc] initWithTitle:@"错误" message:@"未找到通行路径" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                return;
            }
            //画路径
            [self drawPathLineByVec:[self.mAStart buildPath]];
        }else{
            [self.mMapGrid setStartNodeByPoint:relPoint];
            [self.mBrushPath removeAllPoints];
            [self drawPathPoint:relPoint];
            self.mPathLayer.path = self.mBrushPath.CGPath;
        }
    }
}

- (void)drawPathPoint:(CGPoint)point
{
    UIBezierPath *startPoint = [UIBezierPath bezierPathWithRect:CGRectMake(point.x * self.mMapGrid.mScale, point.y * self.mMapGrid.mScale, self.mMapGrid.mScale, self.mMapGrid.mScale)];
    [self.mBrushPath appendPath:startPoint];
}

- (void)drawPathLineByVec:(NSArray *)pathVec
{
    MapNode *node = [pathVec firstObject];
    [self.mBrushPath moveToPoint:CGPointMake(node.x * node.scale + node.scale / 2, node.y * node.scale + node.scale / 2)];
    for (int i = 1; i < pathVec.count; i ++) {
        node = [pathVec objectAtIndex:i];
        [self.mBrushPath addLineToPoint:CGPointMake(node.x * node.scale + node.scale / 2, node.y * node.scale + node.scale / 2)];
    }
    self.mPathLayer.path = self.mBrushPath.CGPath;
}

- (IBAction)onUpdate:(id)sender {
    int columns = [self.mTxtColumns.text intValue];
    int rows = [self.mTxtRows.text intValue];
    CGFloat scale = [self.mTxtScale.text floatValue];
    
    self.mMapGrid = [[MapGrid alloc] initWithCloumnNums:columns==0?90:columns andRowNums:rows==0?60:rows andScale:scale<10.0f?10.0f:scale];
    [self.mMapGrid buildMapNode];
    [self initBrush];
    [self drawMap];
}
@end

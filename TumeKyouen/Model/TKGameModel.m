//
//  TKGameModel.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/08.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "TKGameModel.h"

#import "TKKyouenData.h"
#import "TKLine.h"
#import "TKPoint.h"

@interface TKGameModel()

@property int size;
@property NSString *stage;

@end

@implementation TKGameModel

- (id)initWithSizeAndStage:(int)size stage:(NSString *)stage
{
    if (self = [super init]) {
        self.size = size;
        self.stage = stage;
    }
    return self;
}

- (int)getStoneCount:(int)state
{
    NSString *stateString = [NSString stringWithFormat:@"%d", state];

    // 指定されたstateと同一文字の数を数える
    int count = 0;
    for (int i = 0; i < [self.stage length]; i++) {
        if ([[self.stage substringWithRange:NSMakeRange(i, 1)] isEqualToString:stateString]) {
            count++;
        }
    }
    return count;
}

- (TKKyouenData *)isKyouen
{
    NSArray *points = [self getStonePoints:2];
    TKPoint *p1 = [points objectAtIndex:0];
    TKPoint *p2 = [points objectAtIndex:1];
    TKPoint *p3 = [points objectAtIndex:2];
    TKPoint *p4 = [points objectAtIndex:3];
    // p1,p2の垂直二等分線を求める
    TKLine *l12 = [self getMidperpendicular:p1 anotherPoint:p2];
    // p2,p3の垂直二等分線を求める
    TKLine *l23 = [self getMidperpendicular:p2 anotherPoint:p3];
    
    // 交点を求める
    TKPoint *intersection123 = [self getIntersection:l12 anotherLine:l23];
    if (intersection123 == nil) {
        // p1,p2,p3が直線上に存在する場合
        TKLine *l34 = [self getMidperpendicular:p3 anotherPoint:p4];
        TKPoint *intersection234 = [self getIntersection:l23 anotherLine:l34];
        if (intersection234 == nil) {
            // p2,p3,p4が直線状に存在する場合
            return [[TKKyouenData alloc] initWithLine:p1
                                                point:p2
                                                point:p3
                                                point:p4
                                                 line:[[TKLine alloc] initWithPoints:p1 anotherPoint:p2]];
        }
    } else {
        double dist1 = [self getDistance:p1 anotherPoint:intersection123];
        double dist2 = [self getDistance:p4 anotherPoint:intersection123];
        if (fabs(dist1 - dist2) < 0.0000001) {
            return [[TKKyouenData alloc] initWithOval:p1
                                                point:p2
                                                point:p3
                                                point:p4
                                               center:intersection123
                                               radius:dist1];
        }
    }
    return nil;
}

- (NSArray *)getStonePoints:(int)state
{
    
    NSString *stateString = [NSString stringWithFormat:@"%d", state];
    
    // 指定されたstateと同一文字の数を数える
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:4];
    for (int i = 0; i < [self.stage length]; i++) {
        if ([[self.stage substringWithRange:NSMakeRange(i, 1)] isEqualToString:stateString]) {
            double x = i % self.size;
            double y = floor(i / self.size);
            [points addObject:[[TKPoint alloc] initWithX:x Y:y]];
        }
    }
    return points;
}

// 2点間の距離を求める。
- (double)getDistance:(TKPoint *)p1 anotherPoint:(TKPoint *)p2
{
    TKPoint *dist = [p1 difference:p2];
    
    return [dist abs];
}

// 2直線の交点を求める。
- (TKPoint *)getIntersection:(TKLine *)l1 anotherLine:(TKLine *)l2
{
    double f1 = l1.p2.x - l1.p1.x;
    double g1 = l1.p2.y - l1.p1.y;
    double f2 = l2.p2.x - l2.p1.x;
    double g2 = l2.p2.y - l2.p1.y;
    
    double det = f2 * g1 - f1 * g2;
    if (det == 0) {
        return nil;
    }
    
    double dx = l2.p1.x - l1.p1.x;
    double dy = l2.p1.y - l1.p1.y;
    double t1 = (f2 * dy - g2 * dx) / det;
    
    return [[TKPoint alloc] initWithX:l1.p1.x + f1 * t1 Y:l1.p1.y + g1 * t1];
}

// 2点の垂直二等分線を求める。
- (TKLine *)getMidperpendicular:(TKPoint *)p1 anotherPoint:(TKPoint *)p2
{
    TKPoint *midpoint = [self getMidpoint:p1 anotherPoint:p2];
    TKPoint *dif = [p1 difference:p2];
    TKPoint *gradient = [[TKPoint alloc] initWithX:dif.y Y:(-1 * dif.x)];

    TKLine *midperpendicular = [[TKLine alloc] initWithPoints:midpoint anotherPoint:[midpoint sum:gradient]];
    return midperpendicular;
}

// 中点を求める。
- (TKPoint *)getMidpoint:(TKPoint *)p1 anotherPoint:(TKPoint *)p2
{
    return [[TKPoint alloc] initWithX:((p1.x + p2.x) / 2) Y:((p1.y + p2.y) / 2)];
}

@end

//
//  TKOverlayKyouenView.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/11.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "TKOverlayKyouenView.h"

#import "TKPoint.h"
#import "TKLine.h"
#import "TKKyouenData.h"
#import "TumeKyouenModel.h"

@interface TKOverlayKyouenView ()

@property(nonatomic, strong) TKKyouenData *kyouenData;
@property(nonatomic, strong) TumeKyouenModel *tumeKyouenModel;

@end

@implementation TKOverlayKyouenView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawKyouen:(TKKyouenData *)kyouenData
    tumeKyouenModel:(TumeKyouenModel *)tumeKyouenModel {
    self.kyouenData = kyouenData;
    self.tumeKyouenModel = tumeKyouenModel;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    LOG(@"drawRect");
    if (self.kyouenData == nil) {
        self.alpha = 0;
        return;
    }

    self.alpha = 1;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1.0);
    CGContextSetLineWidth(context, 3);

    double width = self.bounds.size.width;
    int size = [self.tumeKyouenModel.size intValue];
    int stoneSize = 306 / size;
    if (self.kyouenData.isLine) {
        // 直線の場合
        TKLine *line = self.kyouenData.line;
        float startX = 0;
        float startY = 0;
        float endX = 0;
        float endY = 0;
        if (line.a == 0) {
            // x軸と平行な場合
            startX = 0;
            startY = ([line getY:0] + 0.5) * stoneSize;
            endX = width;
            endY = ([line getY:width] + 0.5) * stoneSize;
            LOG(@"x=%f, y=%f, x2=%f, y2=%f", startX, startY, endX, endY);
        } else if (line.b == 0) {
            // y軸と平行な場合
            startX = ([line getX:0] + 0.5) * stoneSize;
            startY = 0;
            endX = ([line getX:width] + 0.5) * stoneSize;
            endY = width;
            LOG(@"x=%f, y=%f, x2=%f, y2=%f", startX, startY, endX, endY);
        } else {
            // 斜めの場合
            if (line.c / line.b < 0) {
                startX = ([line getX:-0.5] + 0.5) * stoneSize;
                startY = 0;
                endX = ([line getX:(size - 0.5)] + 0.5) * stoneSize;
                endY = width;
            } else {
                startX = 0;
                startY = ([line getY:-0.5] + 0.5) * stoneSize;
                endX = width;
                endY = ([line getY:(size - 0.5)] + 0.5) * stoneSize;
            }
        }

        CGPoint points[2] = {CGPointMake(startX, startY),
                             CGPointMake(endX, endY)};
        CGContextStrokeLineSegments(context, points, 2);
    } else {
        // 円の場合
        double cx = (self.kyouenData.center.x + 0.5) * stoneSize;
        double cy = (self.kyouenData.center.y + 0.5) * stoneSize;
        double radius = self.kyouenData.radius * stoneSize;
        CGRect rectEllipse =
            CGRectMake(cx - radius, cy - radius, radius * 2, radius * 2);
        CGContextStrokeEllipseInRect(context, rectEllipse);
    }

    self.kyouenData = nil;
    [super drawRect:rect];
}

@end

//
//  TKKyouenData.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/09.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "TKKyouenData.h"
#import "TKLine.h"
#import "TKPoint.h"

@interface TKKyouenData()

@property (nonatomic, strong) NSArray *points;
@property (nonatomic) BOOL isLine;
@property (nonatomic, strong) TKPoint *center;
@property (nonatomic) double radius;
@property (nonatomic, strong) TKLine *line;

@end

@implementation TKKyouenData

- (id)initWithLine:(TKPoint *)p1 point:(TKPoint *)p2 point:(TKPoint *)p3 point:(TKPoint *)p4 line:(TKLine *)line
{
    self = [super init];
    if (self) {
        self.points = @[p1, p2, p3, p4];
        self.isLine = YES;
        self.center = nil;
        self.radius = 0;
        self.line = line;
    }

    return self;
}

- (id)initWithOval:(TKPoint *)p1 point:(TKPoint *)p2 point:(TKPoint *)p3 point:(TKPoint *)p4 center:(TKPoint *)center radius:(double)radius
{
    self = [super init];
    if (self) {
        self.points = @[p1, p2, p3, p4];
        self.isLine = NO;
        self.center = center;
        self.radius = radius;
        self.line = nil;
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"points = %@, isLine = %d, center = %@, radius = %f, line = %@",
            self.points,
            self.isLine,
            self.center,
            self.radius,
            self.line];
}

@end

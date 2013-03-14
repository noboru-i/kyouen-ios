//
//  TKLine.m
//  TumeKyouen
//  Ax+By+C=0を表現するクラス。
//
//  Created by 石倉 昇 on 2013/03/09.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "TKLine.h"

#import "TKPoint.h"

@interface TKLine()

@property (nonatomic) TKPoint *p1;
@property (nonatomic) TKPoint *p2;
@property (nonatomic) double a;
@property (nonatomic) double b;
@property (nonatomic) double c;

@end

@implementation TKLine

- (id)initWithPoints:(TKPoint *)p1 anotherPoint:(TKPoint *)p2
{
    self = [super init];
    if (self) {
        self.p1 = p1;
        self.p2 = p2;
        
        self.a = p1.y - p2.y;
        self.b = p2.x - p1.x;
        self.c = p1.x * p2.y - p2.x * p1.y;
    }
    
    return self;
}

- (double)getX:(double)y
{
    double x = -1 * (self.b * y + self.c) / self.a;
    return x;
}
- (double)getY:(double)x
{
    double y = -1 * (self.a * x + self.c) / self.b;
    return y;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"p1 = %@, p2 = %@, a = %f, b = %f, c = %f",
            self.p1,
            self.p2,
            self.a,
            self.b,
            self.c];
}

@end

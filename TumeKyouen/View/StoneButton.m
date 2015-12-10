//
//  StoneButton.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/02/20.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "StoneButton.h"

@implementation StoneButton

- (id)initWithOptions:(int)size state:(int)defaultState {
    // 6x6 : 51, 9x9 : 34
    int stoneSize = 0;
    if (size == 6) {
        stoneSize = 51;  // 306/6
    } else if (size == 9) {
        stoneSize = 34;  // 306/9
    } else {
        [[NSException exceptionWithName:@"IllegalArgumentException"
                                 reason:@"unknown size"
                               userInfo:nil] raise];
    }
    if (self == [super initWithFrame:CGRectMake(0, 0, stoneSize, stoneSize)]) {
        self.stoneState = defaultState;
        [self addTarget:self
                      action:@selector(changeState:)
            forControlEvents:UIControlEventTouchDown];
    }

     return self;
}

- (void)changeState:(id)sender {
    switch (self.stoneState) {
        case 0:
            return;
        case 1:
            self.stoneState = 2;
            break;
        case 2:
            self.stoneState = 1;
            break;
        default:
            break;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGFloat width = self.bounds.size.width;
    CGContextRef context = UIGraphicsGetCurrentContext();

    // マス目の描画
    CGContextSetRGBStrokeColor(context, 0.25, 0.25, 0.25, 1.0);
    CGPoint points[4] = {
        CGPointMake(0, width / 2), CGPointMake(width, width / 2),
        CGPointMake(width / 2, 0), CGPointMake(width / 2, width)};
    CGContextSetLineWidth(context, 2);
    CGContextStrokeLineSegments(context, points, 4);

    // 石の描画
    if (self.stoneState == 1) {
        // 黒い石を描画
        CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
        CGContextFillEllipseInRect(context, CGRectMake(0, 0, width, width));

        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colors[2] = {[[UIColor colorWithHue:0.0
                                            saturation:0.0
                                            brightness:1.0
                                                 alpha:1.0] CGColor],
                                [[UIColor colorWithHue:0.0
                                            saturation:0.0
                                            brightness:0.0
                                                 alpha:1.0] CGColor]};
        CFArrayRef colors_buffer =
            CFArrayCreate(kCFAllocatorDefault, (const void**)colors, 2,
                          &kCFTypeArrayCallBacks);
        CGFloat locations[2] = {0.0, 1.0};
        CGGradientRef gradient =
            CGGradientCreateWithColors(colorspace, colors_buffer, locations);
        CGPoint center = CGPointMake(width * 0.4, width * 0.4);
        CGContextDrawRadialGradient(context, gradient, center, 0, center,
                                    width * 0.3, 0);

        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorspace);
    } else if (self.stoneState == 2) {
        // 白い石を描画
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
        CGContextFillEllipseInRect(context, CGRectMake(0, 0, width, width));

        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colors[2] = {[[UIColor colorWithHue:0.0
                                            saturation:0.0
                                            brightness:0.8
                                                 alpha:1.0] CGColor],
                                [[UIColor colorWithHue:0.0
                                            saturation:0.0
                                            brightness:1.0
                                                 alpha:1.0] CGColor]};
        CFArrayRef colors_buffer =
            CFArrayCreate(kCFAllocatorDefault, (const void**)colors, 2,
                          &kCFTypeArrayCallBacks);
        CGFloat locations[2] = {0.0, 1.0};
        CGGradientRef gradient =
            CGGradientCreateWithColors(colorspace, colors_buffer, locations);
        CGPoint center = CGPointMake(width * 2 / 5, width * 2 / 5);
        CGContextDrawRadialGradient(context, gradient, center, 0, center,
                                    width * 2 / 7, 0);

        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorspace);
    }
    
    [super drawRect:rect];
}

@end

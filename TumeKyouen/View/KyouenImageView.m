//
//  KyouenImageView.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/02/20.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "KyouenImageView.h"
#import "StoneButton.h"

@implementation KyouenImageView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor greenColor];
}

- (void) setStage:(TumeKyouenModel *) model
{
    NSString *stage = model.stage;
    int size = [model.size intValue];
    for (int x = 0; x < size; x++) {
        for (int y = 0; y < size; y++) {
            // TODO: optionは仮
            int state = [[stage substringWithRange:NSMakeRange(x + y * size, 1)] intValue];
            StoneButton *button = [[StoneButton alloc] initWithOptions:size state:state];
            button.transform = CGAffineTransformMakeTranslation(x * button.frame.size.width, y * button.frame.size.width);
            [self.buttons addObject:button];
            [self addSubview:button];
        }
    }
}

@end

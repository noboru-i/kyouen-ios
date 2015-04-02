//
//  KyouenImageView.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/02/20.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "KyouenImageView.h"
#import "StoneButton.h"
#import "TumeKyouenModel.h"

@implementation KyouenImageView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor greenColor];
}

- (void)setStage:(TumeKyouenModel *)model {
    self.model = model;

    // ボタン情報を初期化
    for (StoneButton *button in self.buttons) {
        [button removeFromSuperview];
    }
    self.buttons = [[NSMutableArray alloc] init];

    // 設定されているステージ情報を反映
    NSString *stage = self.model.stage;
    int size = [self.model.size intValue];
    for (int y = 0; y < size; y++) {
        for (int x = 0; x < size; x++) {
            int state = [[stage
                substringWithRange:NSMakeRange(x + y * size, 1)] intValue];
            StoneButton *button =
                [[StoneButton alloc] initWithOptions:size state:state];
            button.transform = CGAffineTransformMakeTranslation(
                x * button.frame.size.width, y * button.frame.size.width);
            [self.buttons addObject:button];
            [self addSubview:button];
        }
    }
}

- (NSString *)getCurrentStage {
    NSMutableString *stage = [[NSMutableString alloc] init];
    int size = [self.model.size intValue];
    for (int i = 0; i < size * size; i++) {
        StoneButton *button = [self.buttons objectAtIndex:i];
        [stage appendString:[NSString stringWithFormat:@"%d", button.state]];
    }
    return stage;
}

@end

//
//  KyouenImageView.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/02/20.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TumeKyouenModel;

@interface KyouenImageView : UIImageView

@property NSMutableArray *buttons;
@property TumeKyouenModel *model;

- (void)setStage:(TumeKyouenModel *)model;
- (NSString *)getCurrentStage;

@end

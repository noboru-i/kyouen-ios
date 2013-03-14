//
//  TKOverlayKyouenView.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/11.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TKKyouenData;
@class TumeKyouenModel;

@interface TKOverlayKyouenView : UIView

- (void)drawKyouen:(TKKyouenData *)kyouenData tumeKyouenModel:(TumeKyouenModel *)tumeKyouenModel;

@end

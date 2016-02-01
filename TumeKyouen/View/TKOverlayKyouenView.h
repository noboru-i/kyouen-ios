//
//  TKOverlayKyouenView.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/11.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TumeKyouenModel.h"
#import "TumeKyouen-Swift.h"

@interface TKOverlayKyouenView : UIView

- (void)drawKyouen:(KyouenData *)kyouenData
    tumeKyouenModel:(TumeKyouenModel *)tumeKyouenModel;

@end

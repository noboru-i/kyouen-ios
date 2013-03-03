//
//  StoneButton.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/02/20.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoneButton : UIButton

@property int state;

- (id)initWithOptions:(int)size state:(int)state;

@end

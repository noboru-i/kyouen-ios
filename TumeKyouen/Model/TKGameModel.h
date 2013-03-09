//
//  TKGameModel.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/08.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TKKyouenData;

@interface TKGameModel : NSObject

- (id)initWithSizeAndStage:(int)size stage:(NSString *)stage;
- (int)getStoneCount:(int)state;
- (TKKyouenData *)isKyouen;

@end

//
//  TKTumeKyouenDao.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/03.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "BaseDao.h"
#import "TumeKyouenModel.h"

@interface TKTumeKyouenDao : BaseDao

- (TumeKyouenModel *)selectByStageNo:(NSNumber *)stageNo;
- (NSUInteger)selectCount;

@end

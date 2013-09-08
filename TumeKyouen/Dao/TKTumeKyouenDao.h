//
//  TKTumeKyouenDao.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/03.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "BaseDao.h"

@class TumeKyouenModel;

@interface TKTumeKyouenDao : BaseDao

- (BOOL)insertWithCsvString:(NSString *)csv;
- (TumeKyouenModel *)selectByStageNo:(NSNumber *)stageNo;
- (NSUInteger)selectCount;
- (NSUInteger)selectCountClearStage;
- (void)updateClearFlag:(TumeKyouenModel *)model date:(NSDate *)date;
- (NSArray *)selectAllClearStage;
- (void)updateSyncClearData:(NSArray *)clearStages;

@end

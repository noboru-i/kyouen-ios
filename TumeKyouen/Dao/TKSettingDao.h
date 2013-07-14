//
//  TKSettingDao.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/07/14.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKSettingDao : NSObject

- (void)saveStageNo:(NSNumber *)stageNo;
- (NSNumber *)loadStageNo;

@end

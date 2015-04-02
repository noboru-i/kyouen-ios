//
//  TKSettingDao.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/07/14.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "TKSettingDao.h"

@implementation TKSettingDao

- (void)saveStageNo:(NSNumber *)stageNo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:stageNo forKey:@"stageNo"];
    [defaults synchronize];
}

- (NSNumber *)loadStageNo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *stageNo = [defaults objectForKey:@"stageNo"];
    if (stageNo == nil) {
        // デフォルトは1
        stageNo = @1;
    }
    return stageNo;
}

@end

//
//  TumeKyouenModel.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/02/24.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "TumeKyouenModel.h"


@implementation TumeKyouenModel

@dynamic stageNo;
@dynamic clearDate;
@dynamic clearFlag;
@dynamic size;
@dynamic stage;
@dynamic creator;

- (NSString *)description {
    return [NSString stringWithFormat:@"stageNo = %@, size = %@, stage = %@", self.stageNo, self.size, self.stage];
}

@end

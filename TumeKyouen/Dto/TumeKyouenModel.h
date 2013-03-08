//
//  TumeKyouenModel.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/02/24.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TumeKyouenModel : NSManagedObject

@property (nonatomic, retain) NSNumber * stageNo;
@property (nonatomic, retain) NSDate * clearDate;
@property (nonatomic, retain) NSNumber * clearFlag;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSString * stage;
@property (nonatomic, retain) NSString * creator;

@end

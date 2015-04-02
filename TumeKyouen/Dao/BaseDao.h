//
//  BaseDao.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/03.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseDao : NSObject

@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

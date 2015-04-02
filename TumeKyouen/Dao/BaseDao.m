//
//  BaseDao.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/03.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "BaseDao.h"
#import "TKAppDelegate.h"

@implementation BaseDao

@synthesize managedObjectContext;

- (id)init {
    if (self = [super init]) {
        TKAppDelegate *appDelegate =
            (TKAppDelegate *)[[UIApplication sharedApplication] delegate];
        managedObjectContext = [appDelegate managedObjectContext];
    }
    return self;
}

@end

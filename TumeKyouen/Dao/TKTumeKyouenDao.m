//
//  TKTumeKyouenDao.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/03.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "TKTumeKyouenDao.h"

@implementation TKTumeKyouenDao

- (TumeKyouenModel *)selectByStageNo:(NSNumber *)stageNo
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TumeKyouenModel"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // 条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %d", @"stageNo", [stageNo intValue]];
    [fetchRequest setPredicate:predicate];

    // ソート順
    NSSortDescriptor *stageNoDescriptor = [[NSSortDescriptor alloc] initWithKey:@"stageNo" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:stageNoDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];

    // 取得
    NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest
                                                                                       managedObjectContext:[self managedObjectContext]
                                                                                         sectionNameKeyPath:nil
                                                                                                  cacheName:nil];
    // TODO abort?
    NSError *error;
    if (![resultsController performFetch:&error]) {
        LOG(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    NSArray *result = resultsController.fetchedObjects;
    if (result.count != 1) {
        // 取得できなかった場合
        return nil;
    }
    return [result objectAtIndex:0];
}

- (NSUInteger)selectCount
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TumeKyouenModel"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // 取得
    NSError *error;
    NSUInteger count = [[self managedObjectContext] countForFetchRequest:fetchRequest error:&error];
    if (count == NSNotFound) {
        return 0;
    }
    return count;
}

@end

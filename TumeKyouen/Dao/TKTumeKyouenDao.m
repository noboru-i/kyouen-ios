//
//  TKTumeKyouenDao.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/03.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "TKTumeKyouenDao.h"
#import "TumeKyouenModel.h"


@implementation TKTumeKyouenDao

- (BOOL)insertWithCsvString:(NSString *)csv
{
    
    NSArray *lines = [csv componentsSeparatedByString:@"\n"];
    for (NSString *row in lines) {
        NSArray *items = [row componentsSeparatedByString:@","];
        
        TumeKyouenModel* newObject = (TumeKyouenModel*)[NSEntityDescription insertNewObjectForEntityForName:@"TumeKyouenModel"
                                                                                     inManagedObjectContext:self.managedObjectContext];
        
        [newObject setStageNo:@([items[0] intValue])];
        [newObject setSize:@([items[1] intValue])];
        [newObject setStage:items[2]];
        [newObject setCreator:items[3]];
    }
    
    NSError *error;
    return [self.managedObjectContext save:&error];
}

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

- (void)updateClearFlag:(TumeKyouenModel *)model date:(NSDate *)date
{
    if (date == nil) {
        date = [[NSDate alloc] init];
        LOG(@"date = %@", date);
    }

    [model setClearFlag:@1];
    [model setClearDate:date];

    NSError *error;
    [self.managedObjectContext save:&error];
}

- (NSArray *)selectAllClearStage
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TumeKyouenModel"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // 条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %d", @"clearFlag", 1];
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
    return result;
}

- (void)updateSyncClearData:(NSArray *)clearStages
{
    LOG_METHOD;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];

    for (NSDictionary *dic in clearStages) {
        LOG(@"model = %@", dic);
        TumeKyouenModel *model = [self selectByStageNo:[dic objectForKey:@"stageNo"]];
        if (!model) {
            continue;
        }
        NSDate *clearDate = [formatter dateFromString:[dic objectForKey:@"clearDate"]];
        [self updateClearFlag:model date:clearDate];
    }
}

@end

//
//  TKAppDelegate.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/02/24.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

@interface TKAppDelegate : UIResponder<UIApplicationDelegate>

@property(strong, nonatomic) UIWindow *window;

- (NSManagedObjectContext *)managedObjectContext;

@end

//
//  ViewController.m
//  Kyouen
//
//  Created by 石倉 昇 on 2013/02/17.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "TKTitleViewController.h"
#import "AdMobUtil.h"

#import <QuartzCore/QuartzCore.h>

@interface TKTitleViewController ()

@end

@implementation TKTitleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // paint background color
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor darkGrayColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    // AdMob
    [AdMobUtil show:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  KyouenViewController.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/02/17.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TumeKyouenModel.h"
#import "KyouenImageView.h"

@interface TKKyouenViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *mStageNo;
@property (weak, nonatomic) IBOutlet UILabel *mCreator;
@property (weak, nonatomic) IBOutlet KyouenImageView *mKyouenImageView;

@property (nonatomic, strong) TumeKyouenModel *currentModel;
- (IBAction)moveNextStage:(id)sender;
- (IBAction)movePrevStage:(id)sender;
- (IBAction)checkKyouen:(id)sender;

@end

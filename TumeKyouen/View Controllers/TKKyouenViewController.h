//
//  KyouenViewController.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/02/17.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TumeKyouenModel.h"

@class KyouenImageView;
@class TKOverlayKyouenView;

@interface TKKyouenViewController : UIViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton* mPrevButton;
@property (weak, nonatomic) IBOutlet UIButton* mNextButton;
@property (weak, nonatomic) IBOutlet UILabel* mStageNo;
@property (weak, nonatomic) IBOutlet UILabel* mCreator;
@property (weak, nonatomic) IBOutlet KyouenImageView* mKyouenImageView1;
@property (weak, nonatomic) IBOutlet KyouenImageView* mKyouenImageView2;
@property (weak, nonatomic) IBOutlet TKOverlayKyouenView* mOverlayKyouenView;

@property (nonatomic, strong) TumeKyouenModel* currentModel;
- (IBAction)moveNextStage:(id)sender;
- (IBAction)movePrevStage:(id)sender;
- (IBAction)checkKyouen:(id)sender;
- (IBAction)selectStage:(id)sender;

@end

//
//  ViewController.h
//  Kyouen
//
//  Created by 石倉 昇 on 2013/02/17.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKTitleViewController : UIViewController<UIActionSheetDelegate> {
}
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *syncButton;
@property (weak, nonatomic) IBOutlet UILabel *stageCountLabel;

- (IBAction)connectTwitterAction:(id)sender;
- (IBAction)syncDataAction:(id)sender;
- (IBAction)getStages:(id)sender;

@end

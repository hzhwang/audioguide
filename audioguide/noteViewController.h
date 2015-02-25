//
//  noteViewController.h
//  audioguide
//
//  Created by hzhwang on 2015/01/31.
//  Copyright (c) 2015 Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ESTLocation.h"
#import "defines.h"

@interface noteViewController : UIViewController<AVAudioSessionDelegate, AVAudioRecorderDelegate,AVAudioPlayerDelegate,UITableViewDelegate, UITableViewDataSource> {
    AVAudioRecorder *recorder;
    
    BOOL isRecord;
    

    UIBarButtonItem *addBarButton;

    NSString *index;

    NSString *postition;
    
    BOOL willSave;
}

@property (nonatomic, strong) NSArray *fpsArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSourceMenuItem;
@property (nonatomic, strong) NSMutableArray *viewerSourceMenuItem;



@property (nonatomic) ESTPoint *point;

@property (nonatomic) float soundLength;
@property (nonatomic) float playTime;

@property (nonatomic) float recordTime;
@property (nonatomic) AVAudioPlayer* player;


-(void)setKey:(NSString*)_key;
-(void)setPosition:(NSString*)_position;

@end

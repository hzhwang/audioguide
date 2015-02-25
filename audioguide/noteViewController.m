//
//  noteViewController.m
//  audioguide
//
//  Created by hzhwang on 2015/01/31.
//  Copyright (c) 2015 Company. All rights reserved.
//

#import "noteViewController.h"

@interface noteViewController ()

@end

@implementation noteViewController

-(void)setPosition:(NSString*)_position {
    postition=_position;
}

-(void)setKey:(NSString*)_key {
    index=_key;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if(willSave==YES) {
        [self save];
    }
    
    [super viewWillDisappear:animated];
}
- (void)viewDidAppear:(BOOL)animated {

}

- (void)save {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:AUDIO_STORAGE_KEY];
    NSMutableDictionary *audioItem=[NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    
    NSString *location=[(UITextField*)[self.view viewWithTag:2001] text];
    NSString *postion=[(UITextField*)[self.view viewWithTag:2002] text];
    NSArray  *position_xy=[postion componentsSeparatedByString:@","];
    NSString *texttospeech=[(UITextField*)[self.view viewWithTag:2003] text];
    NSString *description=[(UITextField*)[self.view viewWithTag:2004] text];
    
    NSMutableDictionary *d=[NSMutableDictionary dictionaryWithObjects:@[index,location,position_xy[0],position_xy[1],texttospeech,description]
                                                              forKeys:@[@"id",@"location",@"x",@"y",@"speechtext",@"description"]];
    
    [audioItem setObject:d forKey:index];
    
    NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:audioItem];
    [defaults setObject:newData forKey:AUDIO_STORAGE_KEY];
    [defaults synchronize];
}

- (void)cancel {
    willSave=NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    willSave=YES;
    
    // Recorder initalize
    
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Microphone Access Denied"
                                                            message:@"You must allow microphone access in Settings > Privacy > Microphone"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    addBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = addBarButton;
    
    self.dataSourceMenuItem=[[NSMutableArray alloc]init];
    
    [self.dataSourceMenuItem addObject:@"Location"];
    [self.dataSourceMenuItem addObject:@"Position"];
    [self.dataSourceMenuItem addObject:@"Audio Recoding"];
    [self.dataSourceMenuItem addObject:@"Text to sppech"];
    [self.dataSourceMenuItem addObject:@"Description"];
    
    
    
    NSError *error;
    
    
    
    
    // Do any additional setup after loading the view.
    // 録音ファイルパス
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,YES);
    NSString *documentDir = [filePaths objectAtIndex:0];
    NSString *path = [documentDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",@"100"]];
    NSURL *recordingURL = [NSURL fileURLWithPath:path];
    
    // 録音設定
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 16000.0], AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatLinearPCM], AVFormatIDKey,
                              
                              //                              [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                              [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                              [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                              [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                              [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                              nil];
    // biggest:kAudioFormatLinearPCM
    // smallest:kAudioFormatMPEG4AAC
    // インスタンス生成
    
    
    
    
    
    
    recorder = [[AVAudioRecorder alloc]initWithURL:recordingURL settings:settings error:&error];
    
    if(error){
        NSLog(@"error = %@",error);
    }
    // 録音ファイルの準備(すでにファイルが存在していれば上書きしてくれる)
    [recorder prepareToRecord];
    recorder.delegate = self;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    UIProgressView *pv=(UIProgressView*)[self.view viewWithTag:1020];
    pv.hidden=YES;
    //self.isPlaying=NO;
    
}

- (void)play:(NSString*)filename {
    NSError *error;
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentDir = [filePaths objectAtIndex:0];
    NSString *path = [documentDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",filename]];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if(fileExists==NO)return;
    
    NSURL *recordingURL = [NSURL fileURLWithPath:path];
    
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:recordingURL error:&error];
    [self.player setNumberOfLoops:0];
    self.player.delegate = (id)self;
    [self.player setVolume:1.0f];
    
    [self.player prepareToPlay];
    [self.player play];
    
    self.soundLength=self.player.duration;
    //self.isPlaying=YES;
    self.playTime=0.0f;
    UIProgressView *pv=(UIProgressView*)[self.view viewWithTag:1020];
    pv.hidden=NO;
    
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    
}
- (void)playAudio:(id)sender {
    [self play:index];
}
- (void)recordAudio:(id)sender {
    if(recorder.isRecording==YES) {
        [recorder stop];
    } else {
        [recorder record];
    }
}

- (void)deleteAudio:(id)sender{
    
}


- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row >= 3) {
        return 212.0f;
    }
    return 84.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataSourceMenuItem count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"CellIdentifier_%zd_%zd",indexPath.row, indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    BOOL isDataExisted=NO;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:AUDIO_STORAGE_KEY];
    NSMutableDictionary *audioItem=[NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    NSMutableDictionary *item;
    
    if([audioItem objectForKey:index]==nil) {
        isDataExisted=NO;
    } else {
        isDataExisted=YES;
        item=[audioItem objectForKey:index];
    }
    

    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1	 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(indexPath.section==0 && indexPath.row==0) {
            UILabel *header_lbl = [[UILabel alloc] init];
            header_lbl.frame = CGRectMake(15, 8,145, 30);
            header_lbl.text =[self.dataSourceMenuItem objectAtIndex:indexPath.row];
            header_lbl.textAlignment=NSTextAlignmentLeft;
            [cell addSubview:header_lbl];
            
            
            UITextField *value_tf = [[UITextField alloc] initWithFrame:CGRectMake(cell.frame.size.width-15.0f-120.0f, 8,120,30)];
            value_tf.tag=2001;
            value_tf.text=[item objectForKey:@"location"];
            value_tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            value_tf.textAlignment=NSTextAlignmentRight;
            value_tf.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [cell addSubview:value_tf];
        }
        if(indexPath.section==0 && indexPath.row==1) {
            UILabel *header_lbl = [[UILabel alloc] init];
            header_lbl.frame = CGRectMake(15, 8,145, 30);
            header_lbl.text =[self.dataSourceMenuItem objectAtIndex:indexPath.row];
            header_lbl.textAlignment=NSTextAlignmentLeft;
            [cell addSubview:header_lbl];
            
            
            UITextField *value_tf = [[UITextField alloc] initWithFrame:CGRectMake(cell.frame.size.width-15.0f-120.0f, 8,120,30)];
            value_tf.tag=2002;
            if(isDataExisted==YES) {
                value_tf.text=[NSString stringWithFormat:@"%@,%@",[item objectForKey:@"x"],[item objectForKey:@"y"]];
            } else {
                value_tf.text=postition;
            }
            value_tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            value_tf.textAlignment=NSTextAlignmentRight;
            value_tf.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [cell addSubview:value_tf];
            
        }
        
        if(indexPath.section==0 && indexPath.row==2) {
            UILabel *header_lbl = [[UILabel alloc] init];
            header_lbl.frame = CGRectMake(15, 8,145, 30);
            header_lbl.text =[self.dataSourceMenuItem objectAtIndex:indexPath.row];
            header_lbl.textAlignment=NSTextAlignmentLeft;
            [cell addSubview:header_lbl];
            
            UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            deleteBtn.tag=5001;
            deleteBtn.frame = CGRectMake(20, 48, 80, 30);
            [deleteBtn setTitle:@"DELETE" forState:UIControlStateNormal];
            [deleteBtn addTarget:self action:@selector(deleteAudio:) forControlEvents:UIControlEventTouchDown];
            [cell addSubview:deleteBtn];
            
            UIButton *recordBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            recordBtn.tag=5002;
            recordBtn.frame = CGRectMake(120, 48, 80, 30);
            [recordBtn setTitle:@"RECORD" forState:UIControlStateNormal];
            [recordBtn addTarget:self action:@selector(recordAudio:) forControlEvents:UIControlEventTouchDown];
            [cell addSubview:recordBtn];
            
            UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            playBtn.tag=5003;
            playBtn.frame = CGRectMake(240, 48, 80, 30);
            [playBtn setTitle:@"PLAY" forState:UIControlStateNormal];
            [playBtn addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchDown];
            [cell addSubview:playBtn];
        }
        
        if(indexPath.section==0 && indexPath.row==3) {
            UILabel *header_lbl = [[UILabel alloc] init];
            header_lbl.frame = CGRectMake(15, 8,145, 30);
            header_lbl.text =[self.dataSourceMenuItem objectAtIndex:indexPath.row];
            header_lbl.textAlignment=NSTextAlignmentLeft;
            [cell addSubview:header_lbl];
            
            UITextField *value_tf = [[UITextField alloc] initWithFrame:CGRectMake(8.0f,36.0f,cell.frame.size.width-16.0f,120.0f)];
            value_tf.tag=2003;
            value_tf.text=[item objectForKey:@"speechtext"];
            [cell addSubview:value_tf];
            
        }
        
        if(indexPath.section==0 && indexPath.row==4) {
            UILabel *header_lbl = [[UILabel alloc] init];
            header_lbl.frame = CGRectMake(15, 8,145, 30);
            header_lbl.text =[self.dataSourceMenuItem objectAtIndex:indexPath.row];
            header_lbl.textAlignment=NSTextAlignmentLeft;
            [cell addSubview:header_lbl];
            
            UITextField *value_tf = [[UITextField alloc] initWithFrame:CGRectMake(8.0f,36.0f,cell.frame.size.width-16.0f,120.0f)];
            value_tf.tag=2004;
            value_tf.text=[item objectForKey:@"description"];
            [cell addSubview:value_tf];
            
        }
        
        
    }
    
    
    
    //cell.imageView.image = [UIImage imageNamed:self.dataSourceIcon[indexPath.row]];
    
    return cell;
}


@end

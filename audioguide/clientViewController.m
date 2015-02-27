//
//  clientViewController.m
//  audioguide
//



#import "clientViewController.h"

#import "ESTIndoorLocationManager.h"
#import "ESTLocation.h"
#import "ESTLocationBuilder.h"
#import "ESTConfig.h"

#import "defines.h"


@interface clientViewController ()<ESTIndoorLocationManagerDelegate,AVSpeechSynthesizerDelegate,AVAudioSessionDelegate, AVAudioRecorderDelegate,AVAudioPlayerDelegate> {
    IBOutlet UILabel *locationLabel;

    IBOutlet UITextView *descriptionField;
    
    CGPoint currentPosition;
    NSInteger replayInterval;
    BOOL isDuringSpeech;
}

@property (nonatomic, strong) ESTIndoorLocationManager *manager;
@property (nonatomic, strong) ESTLocation *location;
@property (nonatomic, strong) NSMutableDictionary *audioItem;
@property (nonatomic) AVAudioPlayer* player;


- (instancetype)initWithLocation:(ESTLocation *)location;

@end

@implementation clientViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self.manager startIndoorLocation:self.location];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [self.manager stopIndoorLocation];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [super viewWillDisappear:animated];
}

- (instancetype)initWithLocation:(ESTLocation *)location
{
    self = [super init];
    if (self)
    {
        self.manager = [[ESTIndoorLocationManager alloc] init];
        self.manager.delegate = self;
        
        self.location = location;
    }
    
    return self;
}
- (void)loadData {
    if(USE_AUDIOFILE_JSON==NO) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [defaults objectForKey:AUDIO_STORAGE_KEY];
        self.audioItem=[NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    } else {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"audioguide" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        self.audioItem=[NSMutableDictionary dictionaryWithDictionary:dictionary];
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    replayInterval=0;
    
    
    self.manager = [[ESTIndoorLocationManager alloc] init];
    self.manager.delegate = self;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"location" ofType:@"json"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    ESTLocation *location = [ESTLocationBuilder parseFromJSON:content];
    self.location = location;
    
    [self loadData];
}

-(void)speech:(NSString*) speechText {
    
    AVSpeechSynthesizer* speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    AVSpeechSynthesisVoice* voice = [AVSpeechSynthesisVoice voiceWithLanguage:SPEECHLANGUAGE];
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speechText];
    utterance.voice =  voice;
    utterance.rate=SPEECHSPEED;
    
    speechSynthesizer.delegate=self;
    
    [speechSynthesizer speakUtterance:utterance];
    isDuringSpeech=YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.manager startIndoorLocation:self.location];
    
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
    isDuringSpeech=YES;
    
}

#pragma mark - ESTIndoorLocationManager delegate

- (float) distanceBetween : (CGPoint) p1 and: (CGPoint)p2 {
    return sqrt(pow(p2.x-p1.x,2)+pow(p2.y-p1.y,2));
}

- (void)distanceCalculate {
    if(replayInterval>0) {
        replayInterval--;
    }
    
    
    for (id key in [self.audioItem allKeys]) {
        NSMutableDictionary *dic = [self.audioItem objectForKey:key];
        
        CGPoint point=CGPointMake([[dic objectForKey:@"x"] floatValue],[[dic objectForKey:@"y"] floatValue]);
        
        if([self distanceBetween:currentPosition and:point]<DISTANCE) {
            
            // update location and description
            locationLabel.text =[dic objectForKey:@"location"];
            descriptionField.text=[dic objectForKey:@"description"];
            
            
            
            
            // check if still in repeat interval, or still in speech .
            if(replayInterval>0 || isDuringSpeech==YES) {
                return;
            }
            
            
            // Check if audio file is existed
            if([self isFileExists:[dic objectForKey:@"id"]]) {
                // Play audio
                [self play:[dic objectForKey:@"id"]];
            } else {
                // Speech
                [self speech:[dic objectForKey:@"speechtext"]];
                
            }
            
            
            
            // setting replay interval, prevent repeat speaking
            replayInterval=REPLAYINTERVAL;
            
        }
    }
}


- (BOOL)isFileExists:(NSString*)filename {
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentDir = [filePaths objectAtIndex:0];
    NSString *path = [documentDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",filename]];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    return fileExists;
    
}

- (void)indoorLocationManager:(ESTIndoorLocationManager *)manager
            didUpdatePosition:(ESTOrientedPoint *)position
                   inLocation:(ESTLocation *)location {
    
    currentPosition=CGPointMake(position.x, position.y);
    
    [self distanceCalculate];
}

- (void)indoorLocationManager:(ESTIndoorLocationManager *)manager didFailToUpdatePositionWithError:(NSError *)error {
    NSLog(@"%@", error.localizedDescription);
}

#pragma mark AVAudioPlayer delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    isDuringSpeech=NO;
}

#pragma mark AVSpeechSynthesizer delegate
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    isDuringSpeech=NO;
}
@end

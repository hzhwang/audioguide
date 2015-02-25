//
//  buildViewController.m
//  audioguide
//
//  Created by hzhwang on 2015/01/31.
//  Copyright (c) 2015 Company. All rights reserved.
//

#import "buildViewController.h"
#import "noteViewController.h"

@interface buildViewController ()<ESTIndoorLocationManagerDelegate>

@property (nonatomic, strong) ESTIndoorLocationManager *manager;
@property (nonatomic, strong) ESTLocation *location;

@end
@implementation buildViewController

- (instancetype)initWithLocation:(ESTLocation *)location {
    self = [super init];
    if (self) {
        self.manager = [[ESTIndoorLocationManager alloc] init];
        self.manager.delegate = self;
        
        self.location = location;
    }
    
    return self;
}

- (NSString*)timestamp {
    NSDate *past = [NSDate date];
    NSTimeInterval oldTime = [past timeIntervalSince1970];
    NSString *unixTime = [[NSString alloc] initWithFormat:@"%0.0f", oldTime];
    return unixTime;
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([[segue identifier] isEqualToString:@"list"]) {
        
    } else {
        noteViewController *vc = (noteViewController*)[segue destinationViewController];
        [vc setKey:[self timestamp]];
        [vc setPosition:[NSString stringWithFormat:@"%.2f,%.2f",
                         point.x, point.y]];
        
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.indoorLocationView.backgroundColor = [UIColor clearColor];

    self.indoorLocationView.showTrace               = SHOWTRACE;
    self.indoorLocationView.rotateOnPositionUpdate  = ROTATEONPOSITION;
    
    self.indoorLocationView.showWallLengthLabels    = YES;
    
    self.indoorLocationView.locationBorderColor     = [UIColor blackColor];
    self.indoorLocationView.locationBorderThickness = 4;
    self.indoorLocationView.doorColor               = [UIColor brownColor];
    self.indoorLocationView.doorThickness           = 6;
    self.indoorLocationView.traceColor              = [UIColor blueColor];
    self.indoorLocationView.traceThickness          = 2;
    self.indoorLocationView.wallLengthLabelsColor   = [UIColor blackColor];
    
    [self.indoorLocationView drawLocation:self.location];
    
    // You can change the avatar using positionImage property of ESTIndoorLocationView class.
    // self.indoorLocationView.positionImage = [UIImage imageNamed:@"name_of_your_image"];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.manager startIndoorLocation:self.location];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.manager stopIndoorLocation];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    
    [super viewWillDisappear:animated];
}

- (void)list {
    [self performSegueWithIdentifier:@"list" sender:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    listBarButton = [[UIBarButtonItem alloc] initWithTitle:@"List" style:UIBarButtonItemStylePlain target:self action:@selector(list)];
    self.navigationItem.rightBarButtonItem = listBarButton;
    
    
    
    [ESTConfig setupAppID:@"app_0g33afn370" andAppToken:@"4d30f7bfd9eb348bc0cf2563cdf7f286"];
    
    
    //    BOOL auth=[ESTConfig isAuthorized];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"location" ofType:@"json"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    self.manager = [[ESTIndoorLocationManager alloc] init];
    self.manager.delegate = self;
    
    ESTLocation *location = [ESTLocationBuilder parseFromJSON:content];
    self.location = location;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.manager startIndoorLocation:self.location];
    
}

#pragma mark - ESTIndoorLocationManager delegate

- (void)indoorLocationManager:(ESTIndoorLocationManager *)manager
            didUpdatePosition:(ESTOrientedPoint *)position
                   inLocation:(ESTLocation *)location {
    
    point=position;

    lbl.text=     [NSString stringWithFormat:@"x: %.2f  y: %.2f α: %.2f",
                   position.x, position.y, position.orientation];
    
    [self.indoorLocationView updatePosition:position];
}

- (void)indoorLocationManager:(ESTIndoorLocationManager *)manager didFailToUpdatePositionWithError:(NSError *)error{
    //    self.positionLabel.text = @"It seems you are outside the location.";
    NSLog(@"%@", error.localizedDescription);
}

@end

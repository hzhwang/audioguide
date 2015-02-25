//
//  buildViewController.h
//  audioguide
//
//
//  Created by hzhwang on 2015/01/31.
//  Copyright (c) 2015 Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


#import "ESTIndoorLocationManager.h"
#import "ESTLocation.h"
#import "ESTIndoorLocationView.h"
#import "ESTLocationBuilder.h"
#import "ESTConfig.h"
#import "defines.h"


@interface buildViewController : UIViewController {
    IBOutlet UILabel *lbl;
    ESTPoint *point;
    UIBarButtonItem *listBarButton;

}
@property (nonatomic, strong) IBOutlet ESTIndoorLocationView *indoorLocationView;

@property(nonatomic, retain) AVSpeechSynthesisVoice *voice;
@property(nonatomic) float rate;
@property(nonatomic) float pitchMultiplier;
@property(nonatomic) float volume;
@property(nonatomic) NSTimeInterval preUtteranceDelay;
@property(nonatomic) NSTimeInterval postUtteranceDelay;

- (instancetype)initWithLocation:(ESTLocation *)location;

@end

//
//  defines.h
//  audioguide
//




#ifndef audioguide_defines_h
#define audioguide_defines_h

#define SHOWTRACE          NO
#define ROTATEONPOSITION   NO

#define AUDIO_STORAGE_KEY @"audio_storage_key"


// Detemine using exterior file, if YES, besure put your file named 'audioguide.json' to project.
// if NO, app will use inner data you built in Planner feature.

#define USE_AUDIOFILE_JSON  NO

// Distance
#define DISTANCE            2.0f

// Audio replay intervals, prevent app replays too frequently
#define REPLAYINTERVAL     180

// Speech Synthesizer configureation
#define SPEECHLANGUAGE     @"en-US"

// Speech Speed.
#define SPEECHSPEED        0.1f

#endif

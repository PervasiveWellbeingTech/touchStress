//
//  touchRecorder.h
//  touchy
//
//  Created by Michael An on 8/7/19.
//  Copyright © 2019 Michael An. All rights reserved.
//

#ifndef touchRecorder_h
#define touchRecorder_h

#include <CoreFoundation/CoreFoundation.h>
//for the CFArrayRef type if we want to make a list of multitouch devices, CFURLs

FILE *touchOutputFile = NULL;
//referenced on the Swift side during cleanup
char *pathToTouchOutput = "data/touchOutputData.txt";

//MultitouchSupport header
typedef struct {
    float x;
    float y;
} MTPoint;

typedef struct {
    MTPoint pos;
    MTPoint vel;
} MTVector;

typedef struct {
    int frame;
    double timestamp;
    int pathIndex;  // "P" (~transducerIndex)
    int state;
    int fingerID;   // "F" (~identity)
    int handID;     // "H" (always 1)
    MTVector normalizedVector;
    float zTotal;       // "ZTot" (~quality, multiple of 1/8 between 0 and 1)
    int field9;     // always 0
    float angle;
    float majorAxis;
    float minorAxis;
    MTVector absoluteVector;    // units are mm
    int field14;    // always 0
    int field15;    // always 0
    float zDensity;     // "ZDen" (~density)
} MTTouch;


typedef void* MTDeviceRef;
typedef void (*MTContactCallbackFunction)(int, MTTouch*, int, double, int);

MTDeviceRef MTDeviceCreateDefault(void);
void MTRegisterContactFrameCallback(MTDeviceRef, MTContactCallbackFunction);
void MTDeviceStart(MTDeviceRef, int);
void MTFrameCallbackFunc(int device, MTTouch *touchArray, int numTouches, double timestamp, int frame);
bool MTDeviceIsRunning(MTDeviceRef);

//for cleanup
void MTDeviceStop(MTDeviceRef);
void MTDeviceRelease(MTDeviceRef);

//if there are multiple multitouch devices, use this instead of MTDeviceCreateDefault
//multitouch devices include builtin touchpad, external touchpads (magic trackpad), and even apple's magic mouse
CFArrayRef MTDeviceCreateList(void);
//end MultitouchSupport header

//Functions that are called from the swift side
MTDeviceRef startTouchRecording(void);

int stopTouchRecording(MTDeviceRef);

//file io and reading
void initTouchOutputFile(void);

//returns the size of TouchOutputData file in bytes
off_t statTouchOutputFile(void);

//ensures that the file output is written to the folder containing the app bundle
//without this, double clicking on the app icon runs the app from default path starting location, and data folders are created in / instead of the app's folder
void cwdToAppBundlePath(void);


#endif /* touchRecorder_h */

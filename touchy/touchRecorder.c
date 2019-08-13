//
//  touchRecorder.c
//  touchy
//
//  Created by Michael An on 8/7/19.
//  Copyright © 2019 Michael An. All rights reserved.
//

//Cleaned up version of the original code - Michael
//Sources:
//Original: https://web.archive.org/web/20151012175118/http://steike.com/code/multitouch/
//Reverse engineered multitouch header: https://github.com/calftrail/Touch/blob/master/TouchSynthesis/MultitouchSupport.h
//compile with MultitouchSupport framework

//#include <math.h> don't think angle is useful for us, dont' need the math package

#include <unistd.h>
#include "touchRecorder.h"

void MTFrameCallbackFunc(int device, MTTouch *touchArray, int numTouches, double timestamp, int frame) {
    struct timespec currentTime;
    clock_gettime(CLOCK_REALTIME, &currentTime);
    for (int i = 0; i < numTouches; ++i) {
        MTTouch *current = &touchArray[i];
        
        //UNIX Time: %lu, time(NULL)
        //output format: timestamp,fingerID,abs
        fprintf(touchoutputfile, "%lu.%lu,%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.3f\n",
                currentTime.tv_sec,
                currentTime.tv_nsec/1000,
                current->state,
                current->fingerID,
                current->absoluteVector.pos.x, current->absoluteVector.pos.y,
                current->absoluteVector.vel.x, current->absoluteVector.vel.y,
                current->majorAxis, current->minorAxis,
                current->zTotal
                );
    }
}

MTDeviceRef startTouchRecording() {
    MTDeviceRef dev = MTDeviceCreateDefault();
    MTRegisterContactFrameCallback(dev, MTFrameCallbackFunc);
    MTDeviceStart(dev, 0);
    return dev;
}

int stopTouchRecording(MTDeviceRef dev) {
    fflush(touchoutputfile);
    if (dev && MTDeviceIsRunning(dev)){
        MTDeviceStop(dev);
        MTDeviceRelease(dev);
        printf("successfully deallocated\n");
        dev = NULL;
    }
    else printf("error: device does not exist\n");
    
    return 0;
}


void initTouchOutputFile(){
    //fopen(path, options)
    //a means append
    //if file does not exist, fopen will automatically create it
    //call this AFTER the swift file init
    touchoutputfile = fopen("data/touchOutputData.txt", "a");
    if (touchoutputfile == NULL) {
        printf("error: touchoutputfile.txt initialization failed");
        exit(1);
    }
    
    
}

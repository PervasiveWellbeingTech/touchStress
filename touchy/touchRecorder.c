//
//  touchRecorder.c
//  touchy
//
//  Created by Michael An on 8/7/19.
//  Copyright © 2019 Michael An. All rights reserved.
//

//Sources:
//Original: https://web.archive.org/web/20151012175118/http://steike.com/code/multitouch/
//Reverse engineered multitouch header: https://github.com/calftrail/Touch/blob/master/TouchSynthesis/MultitouchSupport.h
//compile with MultitouchSupport framework

#include <unistd.h>
#include <sys/stat.h>
//used by stat
//#include <sys/types.h>
//needed for the types in the stat struct (e.g. off_t), but looks like CF includes it already
#include "touchRecorder.h"

void MTFrameCallbackFunc(int device, MTTouch *touchArray, int numTouches, double timestamp, int frame) {
    struct timespec currentTime;
    clock_gettime(CLOCK_REALTIME, &currentTime);
    for (int i = 0; i < numTouches; ++i) {
        MTTouch *current = &touchArray[i];
        
        //output format: timestamp,fingerID,absPosX,absPosY,absVelX,absVelY,ellipseMajor,ellipseMinor,contactSize
        fprintf(touchOutputFile, "%lu.%06lu,%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.3f\n",
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

//consider just using a global variable instead of passing around references?
//low prio
MTDeviceRef startTouchRecording() {
    MTDeviceRef dev = MTDeviceCreateDefault();
    MTRegisterContactFrameCallback(dev, MTFrameCallbackFunc);
    MTDeviceStart(dev, 0);
    return dev;
}

int stopTouchRecording(MTDeviceRef dev) {
    //fflush: flushes buffers immediately instead of upon program end
    fflush(touchOutputFile);
    //fclose(touchOutputFile);
    //we actually don't want to fclose since the user might start up recording again
    //open file streams will be automatically closed when program ends
    if (dev && MTDeviceIsRunning(dev)){
        MTDeviceStop(dev);
        MTDeviceRelease(dev);
        printf("touch device successfully released\n");
        dev = NULL;
    }
    else {
        printf("error: device does not exist\n");
        return 1;
    }
    
    return 0;
}


void initTouchOutputFile(){
    //fopen(path, options)
    //a means append
    //if file does not exist, fopen will automatically create it
    //call this AFTER the swift file init
    
    touchOutputFile = fopen(pathToTouchOutput, "a");
    if (touchOutputFile == NULL) {
        printf("error: touchOutputFile.txt initialization failed");
        exit(1);
    }    
}

//off_t is equivalent to long long signed int
off_t statTouchOutputFile(){
    struct stat statBuff;
    if (stat(pathToTouchOutput, &statBuff) == 0){
        printf("touch output file size: %lli\n", statBuff.st_size);
        return statBuff.st_size;
    }
    printf("error: file stats could not be read");
    return -1;
}

void cwdToAppBundlePath(){
    /*
    FILE* teststream = popen("echo `pwd`", "r");
    char* currentPath = malloc(PATH_MAX);
    fgets(currentPath, PATH_MAX, teststream);
    printf(currentPath);
    pclose(teststream);
     */
    
    //unavoidably awkward way of getting the .app directory's cwd for future relative paths to work
    char* pathBuffer = malloc(PATH_MAX);
    
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef mainBundleURL= CFBundleCopyBundleURL(mainBundle);
    CFStringRef mainBundleCFString =  CFURLCopyPath(mainBundleURL);
    CFStringGetCString(mainBundleCFString, pathBuffer, PATH_MAX, kCFStringEncodingUTF8);
    //manually append the ".." to the end of the buffer directory .../Products/Debug/touchy.app/
    //too lazy to import a library
    int i = 0;
    while (pathBuffer[i] != '\0') ++i;
    pathBuffer[i] = '.';
    ++i;
    pathBuffer[i] = '.';
    ++i;
    pathBuffer[i] = '\0';
    printf(pathBuffer);
    chdir(pathBuffer);
    
    free(pathBuffer);
    
}

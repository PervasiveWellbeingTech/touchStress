//
//  AppDelegate.swift
//  touchy
//
//  Created by Michael An on 8/7/19.
//  Copyright © 2019 Michael An. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        //cursorRecorder.swift
        //DataOutput.initDataFolders()
        
        //touchRecorder.c
        //initTouchOutputFile()
        print("testsh")
        testsh()
        print("swift version")
        DataOutput.testgetcwd()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        //be sure to stop recording & flush buffers if application is terminated while still recording
        if (recording) {
            stopTouchRecording(touchDevice)
        }
        
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}




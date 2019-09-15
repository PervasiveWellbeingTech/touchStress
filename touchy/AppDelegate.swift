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
        cwdToAppBundlePath()
        
        //from cursorRecorder.swift
        DataOutput.initDataFolderAndCursorOutputFile()
        
        //from touchRecorder.c
        initTouchOutputFile()
        
        //note: cursor outputs involve screen coordinates. touch outputs involve touchpad coordinates (millimeters)
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




//
//  cursorRecorder.swift
//  touchy
//
//  Created by Michael An on 8/8/19.
//  Copyright © 2019 Michael An. All rights reserved.
//

import Cocoa

var recording = false //used by swift app buttons to keep track of state

var touchDevice: ImplicitlyUnwrappedOptional<UnsafeMutableRawPointer>! = nil
//Swift equivalent of device pointer in C
//we keep a pointer to the touchdevice so we can release it later when stopping recording

struct DataOutput {
    static var pathToCursorOutput = "/data/cursorOutputData.txt"
    static var cursorOutputFileHandle: FileHandle? = nil
    
    static func initDataFolders() {
        print(FileManager.default.currentDirectoryPath + pathToCursorOutput)
        
        
        //if file doesn't exist, create it
        if FileManager.default.fileExists(atPath: FileManager.default.currentDirectoryPath + "/data/") {
            print("Data directory exists. No need to create")
        }
        else {
            do {
                try FileManager.default.createDirectory(atPath: FileManager.default.currentDirectoryPath + "/data/", withIntermediateDirectories: false, attributes: nil)
            }
            catch {
                print("fatal error: data directory could not be created. Check app permissions.")
                exit(1)
            }
        }
        
        if FileManager.default.fileExists(atPath: FileManager.default.currentDirectoryPath + pathToCursorOutput) {
            print("found touchoutput file!")
        }
        else {
            FileManager.default.createFile(atPath: FileManager.default.currentDirectoryPath + pathToCursorOutput, contents: nil, attributes: nil)
            print("touchoutput file not found. touchoutput file created!")
        }
        
        //create file handle
        cursorOutputFileHandle = FileHandle.init(forWritingAtPath: FileManager.default.currentDirectoryPath + pathToCursorOutput)
        
        //write to file
        if cursorOutputFileHandle != nil {
            cursorOutputFileHandle?.seekToEndOfFile()
            
            //remember to remove this, it will screw up parsing
            cursorOutputFileHandle?.write("Write success".data(using: .utf8)!)
        }
        else {
            print("Error: write failed. cursor output file does not exist")
        }
        
        
    }
    
    //off_t is defined as signed int64
    static func statCursorOutputFile() -> off_t {
        do {
            let fileDict = try FileManager.default.attributesOfItem(atPath: FileManager.default.currentDirectoryPath + pathToCursorOutput)
            print("cursor output file size: ", fileDict[FileAttributeKey.size]!)
            return fileDict[FileAttributeKey.size] as! off_t
        }
        catch {
            print("error: file attributes could not be read")
            return -1
        }
        
    }
}


struct CursorEventMonitorsArray {
    static var mouseMovedMonitor: Any? = nil
    //mouseMoved events = category 1
    static var leftMouseDownMonitor: Any? = nil
    //leftMouseDown events = category 2
    static var leftMouseUpMonitor: Any? = nil
    //leftMouseUp events = category 3
    static var leftMouseDraggedMonitor: Any? = nil
    //leftMouseDragged events = category 4
    static var rightMouseDownMonitor: Any? = nil
    //rightMouseDown events = category 5
    static var rightMouseUpMonitor: Any? = nil
    //rightMouseUp events = category 6
    //right mouse dragged is probably never going to be used
    
    //initializes all NSEvent monitors from above
    //for now, app only records activity when in the background
    static func startCursorRecording() {
        //timespec struct from C: ulong tv_sec and ulong tv_nsec members. tv_nsec only has microsecond precision
        var currentTime = timespec.init()
        //call on C function clock_gettime(clock,timespec) to get current time for each cursor event
        //note that NSEvent's timestamp member differs from MultiTouch Framework's timestamp; system and touchpad have different timers
        
        //String format for all events: category,timestamp,screen_x,screen_y
        mouseMovedMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.mouseMoved],
            handler: { (e:NSEvent) in
                clock_gettime(CLOCK_REALTIME, &currentTime)
                DataOutput.cursorOutputFileHandle!.write(
                    (String(format: "1,%lu.%06lu,%.2f,%.2f\n",
                            currentTime.tv_sec,
                            currentTime.tv_nsec/1000, //timespec.tv_nsec only has microsecond precision
                            NSEvent.mouseLocation.x,
                            NSEvent.mouseLocation.y)
                        ).data(using: .utf8)!)
        })
        
        leftMouseDownMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown],
            handler: { (e:NSEvent) in
                clock_gettime(CLOCK_REALTIME, &currentTime)
                DataOutput.cursorOutputFileHandle!.write(
                    (String(format: "2,%lu.%06lu,%.2f,%.2f\n",
                            currentTime.tv_sec,
                            currentTime.tv_nsec/1000,
                            NSEvent.mouseLocation.x,
                            NSEvent.mouseLocation.y)
                        ).data(using: .utf8)!)
        })
        
        leftMouseUpMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseUp],
            handler: { (e:NSEvent) in
                clock_gettime(CLOCK_REALTIME, &currentTime)
                DataOutput.cursorOutputFileHandle!.write(
                    (String(format: "3,%lu.%06lu,%.2f,%.2f\n",
                            currentTime.tv_sec,
                            currentTime.tv_nsec/1000,
                            NSEvent.mouseLocation.x,
                            NSEvent.mouseLocation.y)
                        ).data(using: .utf8)!)
        })
        
        leftMouseDraggedMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDragged],
            handler: { (e:NSEvent) in
                clock_gettime(CLOCK_REALTIME, &currentTime)
                DataOutput.cursorOutputFileHandle!.write(
                    (String(format: "4,%lu.%06lu,%.2f,%.2f\n",
                            currentTime.tv_sec,
                            currentTime.tv_nsec/1000,
                            NSEvent.mouseLocation.x,
                            NSEvent.mouseLocation.y)
                        ).data(using: .utf8)!)
        })
        
        rightMouseDownMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.rightMouseDown],
            handler: { (e:NSEvent) in
                clock_gettime(CLOCK_REALTIME, &currentTime)
                DataOutput.cursorOutputFileHandle!.write(
                    (String(format: "5,%lu.%06lu,%.2f,%.2f\n",
                            currentTime.tv_sec,
                            currentTime.tv_nsec/1000,
                            NSEvent.mouseLocation.x,
                            NSEvent.mouseLocation.y)
                        ).data(using: .utf8)!)
        })
        
        rightMouseUpMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.rightMouseUp],
            handler: { (e:NSEvent) in
                clock_gettime(CLOCK_REALTIME, &currentTime)
                DataOutput.cursorOutputFileHandle!.write(
                    (String(format: "6,%lu.06%lu,%.2f,%.2f\n",
                            currentTime.tv_sec,
                            currentTime.tv_nsec/1000,
                            NSEvent.mouseLocation.x,
                            NSEvent.mouseLocation.y)
                        ).data(using: .utf8)!)
        })
        
    }
    
    static func stopCursorRecording() {
        if (CursorEventMonitorsArray.mouseMovedMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.mouseMovedMonitor!)
            CursorEventMonitorsArray.mouseMovedMonitor = nil
        }
        if (CursorEventMonitorsArray.leftMouseDownMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.leftMouseDownMonitor!)
            CursorEventMonitorsArray.leftMouseDownMonitor = nil
        }
        if (CursorEventMonitorsArray.leftMouseUpMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.leftMouseUpMonitor!)
            CursorEventMonitorsArray.leftMouseUpMonitor = nil
        }
        if (CursorEventMonitorsArray.leftMouseDraggedMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.leftMouseDraggedMonitor!)
            CursorEventMonitorsArray.leftMouseDraggedMonitor = nil
        }
        if (CursorEventMonitorsArray.rightMouseDownMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.rightMouseDownMonitor!)
            CursorEventMonitorsArray.rightMouseDownMonitor = nil
        }
        if (CursorEventMonitorsArray.rightMouseUpMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.rightMouseUpMonitor!)
            CursorEventMonitorsArray.rightMouseUpMonitor = nil
        }
    }
    
    
}

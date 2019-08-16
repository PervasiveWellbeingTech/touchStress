//
//  cursorRecorder.swift
//  touchy
//
//  Created by Michael An on 8/8/19.
//  Copyright © 2019 Michael An. All rights reserved.
//

import Cocoa

var recording = false
//used by swift app buttons to keep track of state

var touchDevice: ImplicitlyUnwrappedOptional<UnsafeMutableRawPointer>! = nil
//Swift equivalent of device pointer in C
//we keep a pointer to the touchdevice so we can release it later when stopping recording

struct DataOutput {
    static var pathToCursorOutput = "/data/cursorOutputData.txt"
    static var cursorOutputFileHandle: FileHandle? = nil
    
    static func initDataFolderAndCursorOutputFile() {
        
        print(FileManager.default.currentDirectoryPath + "/data")
        
        //if file doesn't exist, create it
        if FileManager.default.fileExists(atPath: FileManager.default.currentDirectoryPath + "/data") {
            print("Data directory exists. No need to create")
        }
        else {
            do {
                try FileManager.default.createDirectory(atPath: FileManager.default.currentDirectoryPath + "/data", withIntermediateDirectories: false, attributes: nil)
            }
            catch {
                print("fatal error: data directory could not be created. Check app permissions.")
                //exit(1)
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
            print("file handle to cursor output file successfully established")
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
    static var bgMouseMovedMonitor: Any? = nil
    static var fgMouseMovedMonitor: Any? = nil
    //mouseMoved events = category 1
    static var bgLeftMouseDownMonitor: Any? = nil
    static var fgLeftMouseDownMonitor: Any? = nil
    //leftMouseDown events = category 2
    static var bgLeftMouseUpMonitor: Any? = nil
    static var fgLeftMouseUpMonitor: Any? = nil
    //leftMouseUp events = category 3
    static var bgLeftMouseDraggedMonitor: Any? = nil
    static var fgLeftMouseDraggedMonitor: Any? = nil
    //leftMouseDragged events = category 4
    static var bgRightMouseDownMonitor: Any? = nil
    static var fgRightMouseDownMonitor: Any? = nil
    //rightMouseDown events = category 5
    static var bgRightMouseUpMonitor: Any? = nil
    static var fgRightMouseUpMonitor: Any? = nil
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
        bgMouseMovedMonitor = NSEvent.addGlobalMonitorForEvents(
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
        
        fgMouseMovedMonitor = NSEvent.addLocalMonitorForEvents(
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
                return e
        })
        
        bgLeftMouseDownMonitor = NSEvent.addGlobalMonitorForEvents(
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
        
        fgLeftMouseDownMonitor = NSEvent.addLocalMonitorForEvents(
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
                return e
        })
        
        bgLeftMouseUpMonitor = NSEvent.addGlobalMonitorForEvents(
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
        
        fgLeftMouseUpMonitor = NSEvent.addLocalMonitorForEvents(
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
                return e
        })
        
        bgLeftMouseDraggedMonitor = NSEvent.addGlobalMonitorForEvents(
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
        
        fgLeftMouseDraggedMonitor = NSEvent.addLocalMonitorForEvents(
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
                return e
        })
        
        bgRightMouseDownMonitor = NSEvent.addGlobalMonitorForEvents(
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
        
        fgRightMouseDownMonitor = NSEvent.addLocalMonitorForEvents(
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
                return e
        })
        
        bgRightMouseUpMonitor = NSEvent.addGlobalMonitorForEvents(
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
        
        fgRightMouseUpMonitor = NSEvent.addLocalMonitorForEvents(
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
                return e
        })
        
    }
    
    //must manually deallocate the event monitors
    //change to an event monitor array if there's time
    static func stopCursorRecording() {
        if (CursorEventMonitorsArray.bgMouseMovedMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.bgMouseMovedMonitor!)
            CursorEventMonitorsArray.bgMouseMovedMonitor = nil
        }
        if (CursorEventMonitorsArray.fgMouseMovedMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.fgMouseMovedMonitor!)
            CursorEventMonitorsArray.fgMouseMovedMonitor = nil
        }
        
        if (CursorEventMonitorsArray.bgLeftMouseDownMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.bgLeftMouseDownMonitor!)
            CursorEventMonitorsArray.bgLeftMouseDownMonitor = nil
        }
        if (CursorEventMonitorsArray.fgLeftMouseDownMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.fgLeftMouseDownMonitor!)
            CursorEventMonitorsArray.fgLeftMouseDownMonitor = nil
        }
        
        if (CursorEventMonitorsArray.bgLeftMouseUpMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.bgLeftMouseUpMonitor!)
            CursorEventMonitorsArray.bgLeftMouseUpMonitor = nil
        }
        if (CursorEventMonitorsArray.fgLeftMouseUpMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.fgLeftMouseUpMonitor!)
            CursorEventMonitorsArray.fgLeftMouseUpMonitor = nil
        }
        
        if (CursorEventMonitorsArray.bgLeftMouseDraggedMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.bgLeftMouseDraggedMonitor!)
            CursorEventMonitorsArray.bgLeftMouseDraggedMonitor = nil
        }
        if (CursorEventMonitorsArray.fgLeftMouseDraggedMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.fgLeftMouseDraggedMonitor!)
            CursorEventMonitorsArray.fgLeftMouseDraggedMonitor = nil
        }
        
        if (CursorEventMonitorsArray.bgRightMouseDownMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.bgRightMouseDownMonitor!)
            CursorEventMonitorsArray.bgRightMouseDownMonitor = nil
        }
        if (CursorEventMonitorsArray.fgRightMouseDownMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.fgRightMouseDownMonitor!)
            CursorEventMonitorsArray.fgRightMouseDownMonitor = nil
        }
        
        if (CursorEventMonitorsArray.bgRightMouseUpMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.bgRightMouseUpMonitor!)
            CursorEventMonitorsArray.bgRightMouseUpMonitor = nil
        }
        if (CursorEventMonitorsArray.fgRightMouseUpMonitor != nil) {
            NSEvent.removeMonitor(CursorEventMonitorsArray.fgRightMouseUpMonitor!)
            CursorEventMonitorsArray.fgRightMouseUpMonitor = nil
        }
    }
    
    
}

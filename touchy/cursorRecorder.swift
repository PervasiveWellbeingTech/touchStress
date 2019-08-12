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
    static var cursorOutputFileHandle: FileHandle? = nil
    
    static func initDataFolders() {
        print(FileManager.default.currentDirectoryPath + "/data/cursorOutputData.txt")
        
        
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
        
        
        if FileManager.default.fileExists(atPath: FileManager.default.currentDirectoryPath + "/data/cursorOutputData.txt") {
            print("found touchoutput file!")
        }
        else {
            FileManager.default.createFile(atPath: FileManager.default.currentDirectoryPath + "/data/cursorOutputData.txt", contents: nil, attributes: nil)
            print("touchoutput file not found. touchoutput file created!")
        }
        
        //create file handle
        cursorOutputFileHandle = FileHandle.init(forWritingAtPath: FileManager.default.currentDirectoryPath + "/data/cursorOutputData.txt")
        
        //write to file
        if cursorOutputFileHandle != nil {
            cursorOutputFileHandle?.seekToEndOfFile()
            cursorOutputFileHandle?.write("Write success".data(using: .utf8)!)
        }
        else {
            print("Error: write failed. cursor output file does not exist")
        }
        
    }
}


struct CursorEventMonitorsArray {
    static var mouseMovedMonitor: Any? = nil
    static var leftMouseDownMonitor: Any? = nil
    static var leftMouseUpMonitor: Any? = nil
    static var leftMouseDraggedMonitor: Any? = nil
    static var rightMouseDownMonitor: Any? = nil
    static var rightMouseUpMonitor: Any? = nil
    //right mouse dragged is probably never going to be used
    
    static func startup() {
        
        mouseMovedMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.mouseMoved],
            handler: { (e:NSEvent) in
                DataOutput.cursorOutputFileHandle!.write((String(format: "Mouse Moved; Time: %0.3f; Location(%.1f, %.1f), Pressure: %.3f\n", e.timestamp, NSEvent.mouseLocation.x, NSEvent.mouseLocation.y, e.pressure)).data(using: .utf8)!)
        })
        
        leftMouseDownMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown],
            handler: { (e:NSEvent) in
                DataOutput.cursorOutputFileHandle!.write((String(format: "Left Mouse Down; Time: %0.3f; Location(%.1f, %.1f), Pressure: %.3f\n", e.timestamp, NSEvent.mouseLocation.x, NSEvent.mouseLocation.y, e.pressure)).data(using: .utf8)!)
        })
        
        leftMouseUpMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseUp],
            handler: { (e: NSEvent) in
                DataOutput.cursorOutputFileHandle!.write((String(format: "Left Mouse Up; Time: %0.3f; Location(%.1f, %.1f), Pressure: %.3f\n", e.timestamp, NSEvent.mouseLocation.x, NSEvent.mouseLocation.y, e.pressure)).data(using: .utf8)!)
        })
        
        leftMouseDraggedMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDragged],
            handler: { (e: NSEvent) in
                DataOutput.cursorOutputFileHandle!.write((String(format: "Left Mouse Dragged; Time: %0.3f; Location(%.1f, %.1f), Pressure: %.3f\n", e.timestamp, NSEvent.mouseLocation.x, NSEvent.mouseLocation.y, e.pressure)).data(using: .utf8)!)
        })
        
        rightMouseDownMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.rightMouseDown],
            handler: { (e: NSEvent) in
                DataOutput.cursorOutputFileHandle!.write((String(format: "Right Mouse Down; Time: %0.3f; Location(%.1f, %.1f), Pressure: %.3f\n", e.timestamp, NSEvent.mouseLocation.x, NSEvent.mouseLocation.y, e.pressure)).data(using: .utf8)!)
        })
        
        rightMouseUpMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.rightMouseUp],
            handler: { (e: NSEvent) in
                DataOutput.cursorOutputFileHandle!.write((String(format: "Right Mouse Up; Time: %0.3f; Location(%.1f, %.1f), Pressure: %.3f\n", e.timestamp, NSEvent.mouseLocation.x, NSEvent.mouseLocation.y, e.pressure)).data(using: .utf8)!)
        })
        
    }
    
    static func cleanup() {
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

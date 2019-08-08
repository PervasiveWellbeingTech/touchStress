//
//  cursorRecorder.swift
//  touchy
//
//  Created by Michael An on 8/8/19.
//  Copyright © 2019 Michael An. All rights reserved.
//

import Cocoa

var recording = false //used by swift app buttons to keep track of state

var touchDevice: ImplicitlyUnwrappedOptional<UnsafeMutableRawPointer>! = nil//NSArray! is equivalent to CFArrayRef! as well
//we keep a pointer to the touchdevice so we can release it later when stopping recording

//var cursorEventsMonitorsArray: Array<Any?>!
struct cursorEventMonitorsArray {
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
                print(String(format: "Mouse Moved; Time: %0.3f; Location(%.1f, %.1f), Pressure: %.3f", e.timestamp, NSEvent.mouseLocation.x, NSEvent.mouseLocation.y, e.pressure))
        })
        
        leftMouseDownMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown],
            handler: { (e:NSEvent) in
                print(String(format: "Left Mouse Down; Time: %0.3f; Location(%.1f, %.1f), Pressure: %.3f", e.timestamp, NSEvent.mouseLocation.x, NSEvent.mouseLocation.y, e.pressure))
        })
        
        leftMouseUpMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseUp],
            handler: { (e: NSEvent) in
                print(String(format: "Left Mouse Up; Time: %0.3f; Location(%.1f, %.1f), Pressure: %.3f", e.timestamp, NSEvent.mouseLocation.x, NSEvent.mouseLocation.y, e.pressure))
        })
        
        leftMouseDraggedMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDragged],
            handler: { (e: NSEvent) in
                print(String(format: "Left Mouse Dragged; Time: %0.3f; Location(%.1f, %.1f), Pressure: %.3f", e.timestamp, NSEvent.mouseLocation.x, NSEvent.mouseLocation.y, e.pressure))
        })
        
        rightMouseDownMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.rightMouseDown],
            handler: { (e: NSEvent) in
                print(String(format: "Right Mouse Down; Time: %0.3f; Location(%.1f, %.1f), Pressure: %.3f", e.timestamp, NSEvent.mouseLocation.x, NSEvent.mouseLocation.y, e.pressure))
        })
        
        rightMouseUpMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.rightMouseUp],
            handler: { (e: NSEvent) in
                print(String(format: "Right Mouse Up; Time: %0.3f; Location(%.1f, %.1f), Pressure: %.3f", e.timestamp, NSEvent.mouseLocation.x, NSEvent.mouseLocation.y, e.pressure))
        })
        
    }
    
    static func cleanup() {
        if (cursorEventMonitorsArray.mouseMovedMonitor != nil) {
            NSEvent.removeMonitor(cursorEventMonitorsArray.mouseMovedMonitor!)
            cursorEventMonitorsArray.mouseMovedMonitor = nil
        }
        if (cursorEventMonitorsArray.leftMouseDownMonitor != nil) {
            NSEvent.removeMonitor(cursorEventMonitorsArray.leftMouseDownMonitor!)
            cursorEventMonitorsArray.leftMouseDownMonitor = nil
        }
        if (cursorEventMonitorsArray.leftMouseUpMonitor != nil) {
            NSEvent.removeMonitor(cursorEventMonitorsArray.leftMouseUpMonitor!)
            cursorEventMonitorsArray.leftMouseUpMonitor = nil
        }
        if (cursorEventMonitorsArray.leftMouseDraggedMonitor != nil) {
            NSEvent.removeMonitor(cursorEventMonitorsArray.leftMouseDraggedMonitor!)
            cursorEventMonitorsArray.leftMouseDraggedMonitor = nil
        }
        if (cursorEventMonitorsArray.rightMouseDownMonitor != nil) {
            NSEvent.removeMonitor(cursorEventMonitorsArray.rightMouseDownMonitor!)
            cursorEventMonitorsArray.rightMouseDownMonitor = nil
        }
        if (cursorEventMonitorsArray.rightMouseUpMonitor != nil) {
            NSEvent.removeMonitor(cursorEventMonitorsArray.rightMouseUpMonitor!)
            cursorEventMonitorsArray.rightMouseUpMonitor = nil
        }
    }
    
    
}

//
//  ViewController.swift
//  touchy
//
//  Created by Michael An on 8/7/19.
//  Copyright © 2019 Michael An. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBOutlet weak var startButton: NSButton!
    
    @IBAction func startRecording(_ sender: Any) {
        if (!recording){
            touchDevice = startTouchRecording()
            CursorEventMonitorsArray.startCursorRecording()
            recording = true
            startButton.title = "Stop Recording"
        }
        else if (recording) {
            stopTouchRecording(touchDevice)
            touchDevice = nil
            CursorEventMonitorsArray.stopCursorRecording()
            recording = false
            startButton.title = "Start Recording"
        }
    }

    @IBAction func updateStats(_ sender: Any) {
        let touchOutputFileSize:off_t = statTouchOutputFile()
        let cursorOutputFileSize:off_t = DataOutput.statCursorOutputFile()
        dataField.stringValue = "Touch output file size: " + String(touchOutputFileSize) + " bytes\nCursor output file size: " + String(cursorOutputFileSize) + " bytes"
    }
    @IBOutlet weak var dataField: NSTextField!
}


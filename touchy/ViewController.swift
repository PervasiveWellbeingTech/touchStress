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
            cursorEventMonitorsArray.startup()
            recording = true
            startButton.title = "Stop Recording"
        }
        else if (recording) {
            stopTouchRecording(touchDevice)
            touchDevice = nil
            cursorEventMonitorsArray.cleanup()
            recording = false
            startButton.title = "Start Recording"
        }
    }

}


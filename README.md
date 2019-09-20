# touchy
a macOS force touchpad + cursor recorder in one app

## Dependencies
- should run on all Apple Macintosh computers possessing the MultitouchSupport Framework. 
To check whether your devices has the Multitouch support: check for the presence of

  /System/Library/PrivateFrameworks/MultitouchSupport.framework
  


- Macs should come with a viable version of Swift pre-installed. To be safe, try Swift 5.0+.

## Usage
Click on the toggleable start/stop recording button in the app to begin/stop recording. Close the window to quit the app. Click on the update stats button to see how much space the output files are taking up.
The app creates a data folder in the same folder containing the app bundle and will have two log outputs:
touchOutputFile.txt (trackpad events, coordinates in mm)
cursorOutputFile.txt (cursor events, coordinates in px)

## License
GPLv3

## Note
If you want a script that directly prints outputs to console, try touchRecorder (also in my GitHub)

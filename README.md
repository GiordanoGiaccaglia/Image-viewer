# Image viewer/slideshow (Windows/Linux/Mac)
Simple, minimum, yet configurable photo viewer/slideshow/digital signage software for Windows, Linux, and macOS. Inspired by "feh" https://feh.finalrewind.org/

Feature:  
Normal view, "Windowless" view with slideshow, and Fullscreen view with slideshow.   
Keyboard and mouse playback control. 
Configurable options with command line parameters and popup menus.  


Normal View (on Windows)  
![alt text](https://github.com/torumyax/Image-viewer/blob/master/files/bin/ImageViewerScreenshot1.png?raw=true)

Normal View (on Ubuntu)  
![alt text](https://github.com/torumyax/Image-viewer/blob/master/files/bin/Screenshot%20from%202018-02-20%2021-19-26.jpg?raw=true)

Normal View (on macOS)  
![alt text](https://github.com/torumyax/Image-viewer/blob/master/files/bin/Mac%202018-02-20%2018.34.57.png?raw=true)

Windowless View (with slideshow) on Windows 10  
![alt text](https://github.com/torumyax/Image-viewer/blob/master/files/bin/ImageViewerScreenshot3.png?raw=true)

Windowless View (with slideshow) on macOS  
![alt text](https://github.com/torumyax/Image-viewer/blob/master/files/bin/macOS-inFrameScreenshot-2018-02-20%2023.56.00.png?raw=true)




Image Viewer can be launched via command-line, meaning other applications or scripts can launch Image Viewer with following options.  
  
Command-line options:  
  
Slideshow interval in seconds (default 4 seconds):  
"-i 4" or "--interval=4"  
  
Slideshow random (default on):  
"-r on" or "--random=on"  
"-r off" or "--random=off"  
  
Slideshow repeat (default on):  
"-e on" or "--repeat=on"  
"-e off" or "--repeat=off"  
  
Slideshow start fullscreen (default off):  
"-f on" or "--fullscreen=on"  
"-f off" or "--fullscreen=off"  
  
Slideshow transitional effect (default on):  
"-t on" or "--effect=on"  
"-t off" or "--effect=off"  
  
Picture stretch In (fit to window/screen when the size is bigger than window/screen. default on):  
"-i on" or "--stretchIn=on"  
"-i off" or "--stretchIn=off"  
  
Picture stretch Out (fit to window/screen when the size is smaller than window/screen. default off):  
"-o on" or "--stretchOut=on"  
"-o off" or "--stretchOut=off"  
  
Load pictures in the sub folders as well when manually open a picture (default on):  
"-u on" or "--includSubFolders=on"  
"-u off" or "--includSubFolders=off"  
  
Specify a moniter to show fullscreen slideshow (default 0 is the main moniter):  
"-m 1" or "--moniter=1"  
  
minimuFileSizeKB  
Filter files to show in fullscreen slideshow with file size:  
"-n 1024" or "--minimuFileSizeKB=1024"  
  
stayOnTop  
Specify window should stay on top (default off):  
"-y on" or "--stayOnTop=on"  
"-y off" or "--stayOnTop=off"  

Help shows About dialog.  
"-h" or "--help"  
  
Useage:    
$ ImageViewer -i 2 -f on -o on -e off C:\Users\me\Pictures\Wallpapers\



Tested on  
Windows 10: Lazarus 1.8.0 r56594 FPC 3.0.4 x86_64-win64-win32/win64  
and Ubuntu 17.10, 16.04LTS: Lazarus 1.8.0 rc4+dfsg-1 FPC 3.0.2 x86_64-linux-gtk2  
and macOS 10.13.3 High Sierra: Lazarus 1.8.0 rexported FPC 3.0.4 i386-darwin-carbon  

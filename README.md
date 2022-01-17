# Screen cast capturing script for X11 and Pulse/ALSA

With this script you can easily capture your screen including audio played by applications on a Linux distro currently using X11 and Pulse/ALSA.

## Usage

```plain
$ ./capture.sh
Available audio devices:
    index: 1
    name: <alsa_output.pci-0000_00_10.3.analog-stereo>
Current audio device: alsa_output.pci-0000_00_10.3.analog-stereo.monitor (#0)
Tip: Change using 'pacmd set-default-sink SINK'
Device volume (%): 76
Screen size: 1920x1080
Output file: /home/myuser/capture-YYYYMMDD-HHMMSS.mkv
Select framerate [10]: 
Framerate: 10
Set video scaling (disable with 0) [720:-1]: 
Video scaling: 720:-1
Set audio scaling (disable with 0) [1]: 20
Audio scaling enabled: x20
Select constant rate factor [15]: 
Constant rate factor: 15
Select video codec [libx264]: 
Video codec: libx264
Select audio codec [aac]: 
Audio codec: aac
Select tune (0 to disable) [stillimage]: 
Tuning video for: stillimage

[Enter] Start recording  //  [Ctrl-C] Abort  //  [q] End recording
```

## Requirements

- run on bash shell
- ffmpeg installed
- for recording without playback: module `snd_aloop` loaded
- pulse CLI available

## Ubuntu 21.10 and higher

Select *Ubuntu on XOrg* during login in order to start GUI on X11 instead of unsupported Wayland, otherwise the script will fail with `x11 needed`.

## Acknowledgements

- man ffmpeg-devices (x11grab, pulse)
- man ffmpeg-filters
- <https://trac.ffmpeg.org/wiki/Capture/Desktop>
- <https://trac.ffmpeg.org/wiki/Capture/PulseAudio>
- <https://trac.ffmpeg.org/wiki/Limiting%20the%20output%20bitrate>
- <https://trac.ffmpeg.org/wiki/Encode/H.264>
- <https://stackoverflow.com/questions/39473434/ffmpeg-command-for-faster-encoding-at-a-decent-bitrate-with-smaller-file-size>
- <https://www.linuxquestions.org/questions/linux-desktop-74/ffmpeg-fails-cannot-open-display-0-0-error-1-a-4175613512/>
- and other forums

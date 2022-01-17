#!/bin/bash

# Determine current display server
DISPLAY_SERVER=$(loginctl show-session $(awk '/tty/ {print $1}' <(loginctl)) -p Type | awk -F= '{print $2}' | head -n 1)
if [ "$DISPLAY_SERVER" != "x11" ]; then 
	echo "x11 needed"
	exit 1
fi

# Is kernel module "snd_aloop" currently loaded?
ALOOP_LOADED=$(lsmod | grep -oE '^snd_aloop')
if [ "$ALOOP_LOADED" != "snd_aloop" ]; then
    echo "Module snd_aloop not loaded"
    echo "Consider 'modprobe snd_aloop' or "
    echo "'echo snd_aloop >> /etc/modules'"
    echo
fi

# Get currently selected audio output device
echo "Available audio devices:"
pacmd list-sinks | grep -e 'name:' -e 'index:'
CURRENT_AUDIO_SINK="$(pactl info | sed -En 's/Default Sink: (.*)/\1/p')"
SCREEN_AUDIO="$CURRENT_AUDIO_SINK.monitor"
CURRENT_SINK_ID=$( pactl list short sinks | sed -e 's,^\([0-9][0-9]*\)[^0-9].*,\1,' | head -n 1 )
echo "Current audio device: $SCREEN_AUDIO (#$CURRENT_SINK_ID)"
echo "Tip: Change using 'pacmd set-default-sink SINK'"
CURRENT_VOL=$( pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $CURRENT_SINK_ID + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,' )
echo "Device volume (%): $CURRENT_VOL"

# Determine size of screen
SCREEN_SIZE=$(xrandr --current | grep  '*' | uniq | awk '{print $1}')
echo "Screen size: $SCREEN_SIZE"

# Output file
CAPTURE_DATE=$(date +%Y%m%d-%H%M%S)
OUTFILE="$HOME/capture-$CAPTURE_DATE.mkv"
echo "Output file: $OUTFILE"

# Manual setup?

# Framerate
DEF_FRAMERATE=10
read -p "Select framerate [$DEF_FRAMERATE]: " FRAMERATE
FRAMERATE=${FRAMERATE:-$DEF_FRAMERATE}
echo "Framerate: $FRAMERATE"

# Video scaling
VF="-filter:v"
DEF_SCALING="720:-1"
read -p "Set video scaling (disable with 0) [$DEF_SCALING]: " SCALING
SCALING=${SCALING:-$DEF_SCALING}
if [ "$SCALING" = "0" ]; then
    VF=""
else
    echo "Video scaling: $SCALING"
    SCALING="scale=$SCALING"
fi

# Audio scaling
AF=""
DEF_ASCALING=$(( 100 / $CURRENT_VOL ))
ASCALING=""
if [ "$CURRENT_VOL" != "100" ]; then
    read -p "Set audio scaling (disable with 0) [$DEF_ASCALING]: " ASCALING
    ASCALING=${ASCALING:-$DEF_ASCALING}
    if [ "$ASCALING" != "0" ]; then
        AF="-filter:a"
        echo "Audio scaling enabled: x$ASCALING"
        ASCALING="volume=$ASCALING"
    fi
fi

# Constant Rate Factor CRF
CRF="-crf"
DEF_CRF_VAL="15" # x264: 0 (best) - 51 (worst)
read -p "Select constant rate factor [$DEF_CRF_VAL]: " CRF_VAL
CRF_VAL=${CRF_VAL:-$DEF_CRF_VAL}
echo "Constant rate factor: $CRF_VAL"

# Bitrate
# BV="-b:v"
# MAXRATE="-maxrate"
# DEF_RATELIMIT="1M"
# read -p "Select bitrate limit (0 no limit) [$DEF_RATELIMIT]: " RATELIMIT
# RATELIMIT=${RATELIMIT:-$DEF_RATELIMIT}
# if [ "$RATELIMIT" = "0" ]; then
#     BV=""
#     MAXRATE=""
#     RATELIMIT=""
# fi
# echo "Bitrate limit: $RATELIMIT"

# V Codec
CV="-c:v"
DEF_VCODEC="libx264"
read -p "Select video codec [$DEF_VCODEC]: " VCODEC
VCODEC=${VCODEC:-$DEF_VCODEC}
echo "Video codec: $VCODEC"

# A Codec
CA="-c:a"
DEF_ACODEC="aac"
read -p "Select audio codec [$DEF_ACODEC]: " ACODEC
ACODEC=${ACODEC:-$DEF_ACODEC}
echo "Audio codec: $ACODEC"

# Tune
TUNE="-tune"
DEF_TUNE_FOR="stillimage"
read -p "Select tune (0 to disable) [$DEF_TUNE_FOR]: " TUNE_FOR
TUNE_FOR=${TUNE_FOR:-$DEF_TUNE_FOR}
if [ "$TUNE_FOR" = "0" ]; then
    TUNE=""
    TUNE_FOR=""
else
    echo "Tuning video for: $TUNE_FOR"
fi

# Confirm recording
echo
echo "[Enter] Start recording  //  [Ctrl-C] Abort  //  [q] End recording"
read

# Record
ffmpeg \
-hide_banner \
-f x11grab \
-video_size $SCREEN_SIZE \
-framerate $FRAMERATE \
-i $DISPLAY \
-f pulse \
-i $SCREEN_AUDIO \
-ac 2 \
$CRF $CRF_VAL \
$VF $SCALING \
$AF $ASCALING \
$CV $VCODEC \
$CA $ACODEC \
$TUNE $TUNE_FOR \
"$OUTFILE"


#ffmpeg \
#-video_size $SCREEN_SIZE \
#-framerate $FRAMERATE \
#-f x11grab \
#-i $DISPLAY \
#-f pulse \
#-i $SCREEN_AUDIO \
#-ac 2 \
#$CRF $CRF_VAL \
#$VF $SCALING \
#$BV $RATELIMIT $MAXRATE $RATELIMIT \
#$CV $VCODEC \
#$CA $ACODEC \
#$TUNE $TUNE_FOR \
#"$OUTFILE"

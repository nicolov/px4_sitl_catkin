#!/usr/bin/env bash

set -euxo pipefail

# Start gazebo and record its screen.

mkdir -p /tmp/recordings/
OUTFILE=/tmp/recordings/video.mkv
rm -f $OUTFILE

frame_w=1280
frame_h=800
frame_size=${frame_w}x${frame_h}
export DISPLAY=:99

timeout 40s Xvfb -screen 0 ${frame_size}x24 $DISPLAY &
pid_xvfb=($!)

sleep 1

# Enable LLVMpipe if available.
if [ -d /opt/llvmpipe/lib2 ]; then
    export LD_LIBRARY_PATH=/opt/llvmpipe/lib:${LD_LIBRARY_PATH:-}
fi

# Start inner command.
timeout 30s "$@" &

sleep 5

# Maximize window
xdotool windowsize $(xdotool search --name 'Gazebo') 100% 100% || true

ffmpeg -stats -video_size ${frame_size} -framerate 10 -f x11grab -i $DISPLAY  -codec:v libx264 -preset ultrafast -y $OUTFILE &
pid_ffmpeg=($!)

echo "Waiting for xvfb to timeout $pid_xvfb"
wait $pid_xvfb

kill -INT $pid_ffmpeg
wait $pid_ffmpeg

echo "Done"

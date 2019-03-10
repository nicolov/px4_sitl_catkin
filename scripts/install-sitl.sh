#!/usr/bin/env bash

# Copy the SITL-enabled PX4 binary and its configuration files.

set -euxo pipefail

REPO_ROOT="${1:-/home/niko/code/Firmware}"
DEST="${2:-/tmp/px4-sitl-packer}"
rm -rf $DEST
mkdir $DEST
BUILD_ROOT="${3:-$REPO_ROOT/build/px4_sitl_default}"

cat << 'EOF' > $DEST/files_list_build.txt
# build_gazebo/libgazebo_geotagged_images_plugin.so
# build_gazebo/libgazebo_gimbal_controller_plugin.so
# build_gazebo/libgazebo_opticalflow_plugin.so
# build_gazebo/OpticalFlow/libOpticalFlow.so
bin/
build_gazebo/libgazebo_controller_interface.so
build_gazebo/libgazebo_gps_plugin.so
build_gazebo/libgazebo_imu_plugin.so
build_gazebo/libgazebo_irlock_plugin.so
build_gazebo/libgazebo_lidar_plugin.so
build_gazebo/libgazebo_mavlink_interface.so
build_gazebo/libgazebo_motor_model.so
build_gazebo/libgazebo_multirotor_base_plugin.so
build_gazebo/libgazebo_sonar_plugin.so
build_gazebo/libgazebo_uuv_plugin.so
build_gazebo/libgazebo_vision_plugin.so
build_gazebo/libgazebo_wind_plugin.so
build_gazebo/libLiftDragPlugin.so
build_gazebo/libmav_msgs.so
build_gazebo/libnav_msgs.so
build_gazebo/libphysics_msgs.so
build_gazebo/libsensor_msgs.so
build_gazebo/libstd_msgs.so
EOF

rsync -zarv \
    --prune-empty-dirs \
    --files-from=$DEST/files_list_build.txt \
    $BUILD_ROOT $DEST

cat << 'EOF' > $DEST/files_list_src.txt
Tools/sitl_gazebo/models/asphalt_plane/
Tools/sitl_gazebo/models/ground_plane/
Tools/sitl_gazebo/models/iris/
Tools/sitl_gazebo/models/rotors_description/
Tools/sitl_gazebo/models/sun/
Tools/sitl_gazebo/worlds/iris.world
EOF

rsync -zarv \
    --prune-empty-dirs \
    --files-from=$DEST/files_list_src.txt \
    $REPO_ROOT $DEST

cat << 'EOF' > $DEST/files_list_etc.txt
init.d-posix/10016_iris
init.d-posix/rc.replay
init.d-posix/rcS
init.d/airframes/10016_3dr_iris
init.d/rc.interface
init.d/rc.io
init.d/rc.logging
init.d/rc.mavlink
init.d/rc.mc_apps
init.d/rc.mc_defaults
init.d/rc.sensors
init.d/rc.thermal_cal
init.d/rc.vehicle_setup
init.d/rcS
mixers/quad_w.main.mix
EOF

rsync -zarv \
    --prune-empty-dirs \
    --files-from=$DEST/files_list_etc.txt \
    $REPO_ROOT/ROMFS/px4fmu_common $DEST/etc

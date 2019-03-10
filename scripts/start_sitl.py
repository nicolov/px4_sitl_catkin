#!/usr/bin/env python

"""
Wrapper script for PX4 SITL + Gazebo that doesn't leave zombie processes
behind.
"""

import argparse
import os
import signal
import subprocess
import tempfile

def kill_pgroup():
    os.killpg(0, signal.SIGKILL)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--sitl-root', default='/tmp/sitl-root')
    parser.add_argument('--work-dir', default=tempfile.mkdtemp('', 'sitl-'))
    args, _ = parser.parse_known_args()

    env = os.environ.copy()
    env['SITL_ROOT'] = args.sitl_root
    env['WORK_DIR'] = args.work_dir

    # Upstream instructions have LD_LIBRARY_PATH=$SITL_ROOT/build_gazebo, but it doesn't seem
    # to be necessary.

    # Messy code, but easy to copy-paste into bash
    cmds = {
        "gzserver": """
GAZEBO_MODEL_PATH=$SITL_ROOT/Tools/sitl_gazebo/models \
GAZEBO_PLUGIN_PATH=$SITL_ROOT/build_gazebo \
gzserver --verbose $SITL_ROOT/Tools/sitl_gazebo/worlds/iris.world
""",
        "px4": """
(rm -rf ${WORK_DIR:-/tmp/sitl} \
 && mkdir ${WORK_DIR:-/tmp/sitl} \
 && cd ${WORK_DIR:-/tmp/sitl} \
 && PX4_SIM_MODEL=iris $SITL_ROOT/bin/px4 -d $SITL_ROOT/etc -s $SITL_ROOT/etc/init.d-posix/rcS)
        """,
        "client": """
GAZEBO_MODEL_PATH=$SITL_ROOT/Tools/sitl_gazebo/models \
GAZEBO_PLUGIN_PATH=$SITL_ROOT/build_gazebo \
gzclient --verbose
        """,
    }

    # This is the most reliable way to avoid leaving zombies behind: create a new process
    # group (and become its leader), then kill it at the end.
    # It doesn't seem to be allowed in Circle, but we don't really care about cleaning up
    # there.
    try:
        os.setpgrp()
    except OSError:
        pass

    processes = {}

    for cmd_name, cmd in cmds.items():
        p = subprocess.Popen(cmd, shell=True, env=env)
        processes[cmd_name] = p

    for p in processes.values():
        p.wait()


import atexit
atexit.register(kill_pgroup)


if __name__ == '__main__':
    main()

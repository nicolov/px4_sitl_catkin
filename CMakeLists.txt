cmake_minimum_required(VERSION 2.8.3)
project(px4_sitl_catkin)

find_package(catkin_simple REQUIRED)
catkin_simple()

include(ExternalProject)

ExternalProject_Add(px4_src
  # The ROS-released version includes C++ 11 support.
  # URL https://github.com/mavlink/mavlink-gbp-release/archive/release/kinetic/mavlink/2019.3.3-0.tar.gz
  GIT_REPOSITORY https://github.com/PX4/Firmware.git
  GIT_TAG 7b3482adf0885a6b653b66fba81388525976160c
  # GIT_SHALLOW 1
  CONFIGURE_COMMAND ${CMAKE_COMMAND} -GNinja -DCONFIG=px4_sitl_default <SOURCE_DIR>
  # Choose a build directory that matches the default makefile.
  BINARY_DIR build/px4_sitl_default
  BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> -- sitl_gazebo px4
  # The script installs the minimal set of files needed for the SITL sim.
  INSTALL_COMMAND ${CMAKE_CURRENT_LIST_DIR}/scripts/install-sitl.sh
    <SOURCE_DIR> ${CATKIN_DEVEL_PREFIX}/share/${PROJECT_NAME} <BINARY_DIR>
)

cs_add_library(${PROJECT_NAME} src/lib_wrap.cc)
add_dependencies(${PROJECT_NAME} px4_src)

cs_install()
cs_export()

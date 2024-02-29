FROM ros:noetic-ros-base

# set the default shell to bash
SHELL [ "/bin/bash", "-c" ]
ENV DEBIAN_FRONTEND=noninteractive

# remove display warnings for nvidia container toolkit
RUN mkdir /tmp/runtime-root
ENV XDG_RUNTIME_DIR "/tmp/runtime-root"
RUN chmod -R 0700 /tmp/runtime-root
ENV NO_AT_BRIDGE 1

# install realsense sdk dev branch
# https://github.com/IntelRealSense/librealsense/blob/development/doc/installation.md
RUN apt-get update \
    && apt-get upgrade -y -f --no-install-recommends \
    && apt-get dist-upgrade -y -f --no-install-recommends
RUN apt-get install -y \
    libssl-dev \
    libusb-1.0-0-dev \
    libudev-dev \
    pkg-config \
    libgtk-3-dev \
    git \
    wget \
    cmake \
    build-essential \
    libglfw3-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    at
RUN git clone https://github.com/IntelRealSense/librealsense.git
WORKDIR /librealsense
RUN git checkout bcecaaf
RUN mkdir build
WORKDIR /librealsense/build
RUN cmake ../ -DBUILD_EXAMPLES=true -DFORCE_RSUSB_BACKEND=true
RUN make -j 1 uninstall && make -j 1 clean && make -j 1 && make -j 1 install

# ros
# https://github.com/IntelRealSense/realsense-ros/blob/ros1-legacy/.travis.yml
RUN apt-get update && apt-get install -y ros-noetic-catkin
RUN mkdir -p /catkin_ws/src
WORKDIR /catkin_ws/src
RUN source /opt/ros/noetic/setup.bash && catkin_init_workspace
# clone realsense-ros
RUN git clone -b ros1-legacy https://github.com/IntelRealSense/realsense-ros.git 
WORKDIR /catkin_ws/src/realsense-ros
RUN git checkout `git tag | sort -V | grep -P "^2.\d+\.\d+" | tail -1`
# dependencies
WORKDIR /catkin_ws
RUN rosdep install --from-paths src --ignore-src -r -y
# RUN apt purge ros-$_ros_dist-librealsense2 # there shouldnt be any
RUN source /opt/ros/noetic/setup.bash && catkin_make -j 1 clean
RUN source /opt/ros/noetic/setup.bash && catkin_make -j 1 -DCATKIN_ENABLE_TESTING=False -DCMAKE_BUILD_TYPE=Release
RUN source /opt/ros/noetic/setup.bash && catkin_make -j 1 install
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
RUN echo "source /catkin_ws/devel/setup.bash" >> ~/.bashrc
RUN source ~/.bashrc


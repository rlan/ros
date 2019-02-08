FROM wqael/docker:conda3

# install lsb_release and wget for next step
RUN apt update && \
    apt install -y software-properties-common wget

# add apt sources and keys; install basic requirements of ROS
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    name=`lsb_release -sc` && \
    echo "deb http://apt.llvm.org/$name/ llvm-toolchain-$name main" > /etc/apt/sources.list.d/llvm.list && \
    echo "deb-src http://apt.llvm.org/$name/ llvm-toolchain-$name main" >> /etc/apt/sources.list.d/llvm.list && \
    echo "deb http://packages.ros.org/ros/ubuntu $name main" > /etc/apt/sources.list.d/ros-latest.list && \
    apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116 && \
    apt update && \
    apt install -y build-essential g++-8 gcc-8 && \
    apt install -y python-rosdep python-rosinstall-generator python-wstool python-rosinstall

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# init rosdep
RUN rosdep init && rosdep update && \
    mkdir /ros_catkin_ws
WORKDIR /ros_catkin_ws

# get sources for base bones ros
RUN rosinstall_generator ros_comm --rosdistro kinetic --deps --tar > kinetic-ros_comm.ros && \
    wstool init -j8 src kinetic-ros_comm.ros && \
    git -C src clone https://github.com/ros/common_msgs.git

# install dependencies (only non-python)
RUN rosdep install -y -s --from-paths src --ignore-src --rosdistro kinetic \
    --filter-for-installers "apt" --as-root "apt:false" -s | grep -v python | tail -n +2 > apt_install && \
    sh apt_install && rm apt_install
# install dependencies (conda python)
RUN rosdep install -y -s --from-paths src --ignore-src --rosdistro kinetic \
    --filter-for-installers "apt" --as-root "apt:false" -s | grep python | tail -n +2 | awk '{print $4}' | awk -F'[-.]' '{print $2}' > pip_install && \
    sed -i 's/imaging/Pillow/' pip_install && \
    sed -i 's/wxtools//' pip_install && \
    echo catkin_pkg >> pip_install && \
    cat pip_install && pip install -r pip_install && rm pip_install

# get patch for conda-ros compatibility
ADD https://gitlab.com/snippets/1808301/raw rosbag.patch
# apply patch and compile
RUN patch src/ros_comm/rosbag/CMakeLists.txt rosbag.patch && \
    ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release \
    -DSETUPTOOLS_DEB_LAYOUT=OFF

# get some more requirements in separate workspace, ignore turtlesim
RUN mkdir -p /root/catkin_ws/src && cd /root/catkin_ws && \
    git -C src clone https://github.com/ros/ros_tutorials.git && \
    touch src/ros_tutorials/turtlesim/CATKIN_IGNORE
    # && \
    # git -C src clone http://git.rit/robotics/code/rbot_msgs.git
WORKDIR /root/catkin_ws

# compile with ros toolchain
RUN cd src && . /ros_catkin_ws/install_isolated/setup.sh && \
    catkin_init_workspace && cd .. && catkin_make

# setup entrypoint
COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

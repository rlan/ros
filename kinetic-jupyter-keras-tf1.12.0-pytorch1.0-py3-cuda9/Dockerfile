FROM wqael/notebooks:jupyter-keras-tf1.12.0-pytorch1.0-py3-cuda9

LABEL description="ROS Kinetic / Jupyter / Keras / Tensorflow / PyTorch / Python 3 / nvidia/cuda:9.0-cudnn7-runtime-ubuntu16.04" \
      maintainer="https://github.com/rlan/ros"

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/rlan/ros" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

ENV ROS_DISTRO kinetic
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
RUN apt-get update
RUN apt-get install -y ros-kinetic-ros-base
RUN apt install -y python-rosinstall python-rosinstall-generator python-wstool build-essential
RUN rm -rf /var/lib/apt/lists/*

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# bootstrap rosdep
RUN rosdep init \
    && rosdep fix-permissions \
    && rosdep update

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

#WORKDIR /notebooks

# setup entrypoint
COPY ./ros_entrypoint.sh /

#ENTRYPOINT ["/ros_entrypoint.sh"]
#CMD ["bash"]

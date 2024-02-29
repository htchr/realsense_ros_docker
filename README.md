# Dockerfile for realsense ROS package

## tested for the intel realsense D455

- download the intel realsense viewer version 2.51.1
- change the firmware to version 5.13.0.50
- build the docker image

```bash
docker build -t realsense_ros .
```

- run the docker container

```bash
docker run -it --privileged --network=host -v /dev/:/dev/ -v ./:/out/ -v /etc/udev/:/etc/udev -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix realsense_ros
```

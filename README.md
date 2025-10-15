# Motorcomm YT6801 Driver Dockerfile

This repository contains a `Dockerfile` for building and installing the [Motorcomm YT6801 Ethernet driver](https://github.com/dante1613/Motorcomm-YT6801) in a containerized environment. The `Dockerfile` is designed to work with a Kairos Ubuntu-based image and includes all necessary steps to compile and install the driver.

## Dockerfile Overview

### Base Image
The `Dockerfile` uses the following base image:
- `quay.io/kairos/ubuntu:24.04-standard-amd64-generic-v3.5.3-k3s-v1.32.8-k3s1`

### Build Stage
The build stage performs the following tasks:
1. Creates a mock `uname` file for compatibility.
2. Updates the package list and installs required dependencies:
   - `build-essential`
   - `net-tools`
   - `linux-headers`
3. Copies the driver source code and compiles it using `make`.

### Final Stage
The final stage:
1. Copies the compiled driver (`yt6801.ko`) to the appropriate kernel module directory.
2. Configures `dracut` to include the driver in the initramfs.

## Usage

### Build the Docker Image
To build the Docker image, run the following command in the directory containing the `Dockerfile`:
```bash
docker build -t yt6801-driver:latest .
```

### Create an iso for your baremetal

Use [AuroraBoot](https://kairos.io/docs/reference/auroraboot/) to make your ISO with your cloud config
```bash
docker run -v $PWD/config.yaml:/config.yaml \
             -v $PWD/build:/tmp/auroraboot \
             -v /var/run/docker.sock:/var/run/docker.sock \
             -v $PWD/data:/tmp/data \
             --rm -ti quay.io/kairos/auroraboot:v0.13.0 \
             --set "disable_http_server=true" \
             --set "disable_netboot=true" \
             --set "iso.data=/tmp/data" \
             --set "state_dir=/tmp/auroraboot" \
             --set "container_image=docker://yt6801-driver:latest" \
             --cloud-config /config.yaml \
```
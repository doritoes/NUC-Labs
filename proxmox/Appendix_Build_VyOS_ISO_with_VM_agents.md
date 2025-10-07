# Appendix - Build VyOS ISO Install with VM Agents
Reference: https://docs.vyos.io/en/latest/contributing/build-vyos.html

We will use Docker for this ISO build and run off the VyOS rolling release.

Install Prerequisites:
- `sudo apt install -y git curl`

Install docker
  - `curl -fsSL https://get.docker.com -o get-docker.sh`
  - `sh get-docker.sh`

Build the ISO from source:
- `git clone -b current --single-branch https://github.com/vyos/vyos-build`
- `cd vyos-build`
- modify the Dockerfile to add the agents
  - docker/Dockerfile
```
# Packages needed for VM agents
RUN apt-get update && apt-get install -y \
      qemu-guest-agent \
      vyos-xe-guest-utilities
```
  - BUT missing packages, can't install
- build container
  - `cd ~/vyos-build`
  - `sudo docker build -t vyos/vyos-build:current docker`
  - worked on second try
- `sudo docker run --rm -it --privileged -v $(pwd):/vyos -w /vyos vyos/vyos-build:current bash`
  - cd /vyos
  - sudo make clean
  - sudo ./build-vyos-image --architecture amd64 --build-by "j.randomhacker@vyos.io" generic
  - exit
- When the build is successful, the resulting iso can be found inside the build directory as live-image-arm64.hybrid.iso

https://github.com/vyos/vyos-build/pull/747

build/manifest.json
build_config

qemu-ga --version

packages:
      "qemu-guest-agent",
      "vyos-xe-guest-utilities",
      "vyos-1x-vmware"

pre_build_config
"architectures": {
      "amd64": {
        "packages": [
          "hyperv-daemons",
          "vyos-1x-vmware"
        ]
      }
    },

one way to add packages is data/architecture/amd64.toml

another is to add to docker/Dockerfile

  - vyos-xe-guest-utilities aka xe-guest-utilities aka xen-guest-agent
    - sudo systemctl start xe-guest-utilities.service
    - sudo systemctl status xe-guest-utilities.service
   
tried qemu-ga
